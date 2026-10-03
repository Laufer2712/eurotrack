package com.eurotrack.backend.controller;

import com.eurotrack.backend.dto.RestablecerPasswordDTO;
import com.eurotrack.backend.dto.SolicitudRecuperacionDTO;
import com.eurotrack.backend.dto.UsuarioDTO;
import com.eurotrack.backend.model.PasswordResetToken;
import com.eurotrack.backend.model.Usuario;
import com.eurotrack.backend.repository.PasswordResetTokenRepository;
import com.eurotrack.backend.repository.UsuarioRepository;
import com.eurotrack.backend.util.EmailService;
import com.eurotrack.backend.util.PasswordUtil;
import com.eurotrack.backend.util.AuditoriaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*") 
public class AuthController {

    @Autowired
    private AuditoriaService auditoriaService;
     
    @Autowired
    private UsuarioRepository usuarioRepository;
    
    @Autowired
    private PasswordResetTokenRepository tokenRepository;
    
    @Autowired
    private PasswordUtil passwordUtil;
    
    @Autowired
    private EmailService emailService;
    
    private static final String CODIGO_CHARACTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final int CODIGO_LENGTH = 8;
    private static final SecureRandom random = new SecureRandom();

    private String generarCodigoCorto() {
        StringBuilder sb = new StringBuilder(CODIGO_LENGTH);
        for (int i = 0; i < CODIGO_LENGTH; i++) {
            sb.append(CODIGO_CHARACTERS.charAt(random.nextInt(CODIGO_CHARACTERS.length())));
        }
        return sb.toString();
    }

    // ========================================
    // 1. LOGIN
    // ========================================
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginData) {
        String identifier = loginData.get("email");
        String password = loginData.get("password");

        Optional<Usuario> usuarioOpt = usuarioRepository.findByEmail(identifier)
                .or(() -> usuarioRepository.findByUsername(identifier));

        if (usuarioOpt.isPresent()) {
            Usuario user = usuarioOpt.get();
            
            if (user.getActivo() == null || !user.getActivo()) {
                auditoriaService.registrar(identifier, "LOGIN_FALLIDO", 
                    "Intento de login con usuario desactivado: " + identifier);
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body("Usuario desactivado. Contacta al administrador.");
            }
            
            if (passwordUtil.matches(password, user.getPassword())) {
                auditoriaService.registrar(user.getEmail(), "LOGIN_EXITOSO", 
                    "Inicio de sesión exitoso");
                
                Map<String, Object> response = new HashMap<>();
                response.put("id", user.getId());
                response.put("usuario", user.getNombre());
                response.put("username", user.getUsername());
                response.put("cedula", user.getCedula());
                response.put("rol", user.getRol());
                response.put("tipoCliente", user.getTipoCliente());
                response.put("fotoPerfil", user.getFotoPerfil()); 
                response.put("telefono", user.getTelefono());
                response.put("activo", user.getActivo());
                
                return ResponseEntity.ok(response);
            }
            
            auditoriaService.registrar(identifier, "LOGIN_FALLIDO", 
                "Intento de login con credenciales incorrectas");
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Credenciales incorrectas");
    }

   // ========================================
// 2. REGISTRO (MEJORADO)
// ========================================
@PostMapping("/register")
public ResponseEntity<?> register(@RequestBody Map<String, Object> data) {
    try {
        System.out.println("========================================");
        System.out.println("📥 Datos recibidos en backend:");
        for (Map.Entry<String, Object> entry : data.entrySet()) {
            System.out.println("  - " + entry.getKey() + ": " + entry.getValue());
        }
        System.out.println("========================================");

        String nombre = (String) data.get("nombre");
        String cedula = (String) data.get("cedula");
        String username = (String) data.get("username");
        String email = (String) data.get("email");
        String password = (String) data.get("password");
        String rol = (String) data.get("rol");
        String tipoCliente = (String) data.get("tipoCliente");
        String telefono = (String) data.getOrDefault("telefono", "");

        if (password == null || password.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", "La contraseña es requerida"));
        }

        if (usuarioRepository.findByEmail(email).isPresent()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", "El correo electrónico ya está registrado"));
        }

        if (usuarioRepository.findByUsername(username).isPresent()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", "El nombre de usuario ya está en uso"));
        }

        if (usuarioRepository.findByCedula(cedula).isPresent()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", "La identificación (Cédula/RIF) ya está registrada"));
        }

        // ✅ Crear usuario
        Usuario nuevoUsuario = new Usuario();
        nuevoUsuario.setNombre(nombre);
        nuevoUsuario.setCedula(cedula);
        nuevoUsuario.setUsername(username);
        nuevoUsuario.setEmail(email);
        nuevoUsuario.setPassword(passwordUtil.encode(password));
        nuevoUsuario.setRol(rol != null ? rol : "CLIENTE");
        nuevoUsuario.setTipoCliente(tipoCliente != null ? tipoCliente : "NATURAL");
        nuevoUsuario.setTelefono(telefono);
        nuevoUsuario.setActivo(true);

        if ("JURIDICO".equals(tipoCliente)) {
            nuevoUsuario.setRazonSocial((String) data.getOrDefault("razonSocial", ""));
            nuevoUsuario.setNit((String) data.getOrDefault("nit", ""));
            nuevoUsuario.setRegistroMercantil((String) data.getOrDefault("registroMercantil", ""));
            nuevoUsuario.setDireccionFiscal((String) data.getOrDefault("direccionFiscal", ""));
            nuevoUsuario.setContribuyenteEspecial((Boolean) data.getOrDefault("contribuyenteEspecial", false));
        }

        if ("TRANSPORTISTA".equals(tipoCliente)) {
            nuevoUsuario.setLicenciaConducir((String) data.getOrDefault("licenciaConducir", ""));
            nuevoUsuario.setAniosExperiencia((Integer) data.getOrDefault("aniosExperiencia", 0));
            nuevoUsuario.setTipoVehiculo((String) data.getOrDefault("tipoVehiculo", "CAMION"));
        }

        Usuario usuarioGuardado = usuarioRepository.save(nuevoUsuario);
        
        // ✅ AUDITORÍA: Crear una copia SIN LA CONTRASEÑA para la auditoría
        String emailUsuario = usuarioGuardado.getEmail();
        String tipoClienteRegistrado = usuarioGuardado.getTipoCliente();
        
        // ✅ Registrar auditoría con los datos del usuario (sin exponer la contraseña)
        auditoriaService.registrar(
            emailUsuario,
            "REGISTRO",
            "Nuevo usuario registrado: " + emailUsuario + " - Tipo: " + tipoClienteRegistrado
        );

        System.out.println("✅ Usuario registrado exitosamente: " + emailUsuario);

        // ✅ Crear respuesta SIN la contraseña
        Map<String, Object> response = new HashMap<>();
        response.put("id", usuarioGuardado.getId());
        response.put("nombre", usuarioGuardado.getNombre());
        response.put("username", usuarioGuardado.getUsername());
        response.put("email", usuarioGuardado.getEmail());
        response.put("cedula", usuarioGuardado.getCedula());
        response.put("rol", usuarioGuardado.getRol());
        response.put("tipoCliente", usuarioGuardado.getTipoCliente());
        response.put("telefono", usuarioGuardado.getTelefono());
        response.put("activo", usuarioGuardado.getActivo());
        response.put("mensaje", "Usuario registrado exitosamente");

        if ("JURIDICO".equals(tipoCliente)) {
            response.put("razonSocial", usuarioGuardado.getRazonSocial());
            response.put("nit", usuarioGuardado.getNit());
            response.put("registroMercantil", usuarioGuardado.getRegistroMercantil());
            response.put("direccionFiscal", usuarioGuardado.getDireccionFiscal());
            response.put("contribuyenteEspecial", usuarioGuardado.getContribuyenteEspecial());
        }

        if ("TRANSPORTISTA".equals(tipoCliente)) {
            response.put("licenciaConducir", usuarioGuardado.getLicenciaConducir());
            response.put("aniosExperiencia", usuarioGuardado.getAniosExperiencia());
            response.put("tipoVehiculo", usuarioGuardado.getTipoVehiculo());
        }

        return ResponseEntity.status(HttpStatus.CREATED).body(response);

    } catch (Exception e) {
        e.printStackTrace();
        System.err.println("❌ ERROR EN REGISTRO: " + e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Error al registrar usuario: " + e.getMessage()));
    }
}


// ========================================
// 3. ACTUALIZAR PERFIL (CORREGIDO)
// ========================================
@PutMapping("/update-profile/{id}")
public ResponseEntity<?> updateProfile(@PathVariable Long id, @RequestBody Map<String, String> data) {
    return usuarioRepository.findById(id).map(usuario -> {
        String datosAnteriores = usuario.toString();
        
        // ✅ VALIDAR UNICIDAD DEL USERNAME (si se está cambiando)
        if (data.containsKey("username") && data.get("username") != null) {
            String nuevoUsername = data.get("username");
            String usernameActual = usuario.getUsername();
            
            // Solo validar si el username cambió
            if (!nuevoUsername.equals(usernameActual)) {
                Optional<Usuario> usuarioConUsername = usuarioRepository.findByUsername(nuevoUsername);
                if (usuarioConUsername.isPresent() && !usuarioConUsername.get().getId().equals(id)) {
                    return ResponseEntity.status(HttpStatus.CONFLICT)
                            .body(Map.of("error", "El nombre de usuario ya está en uso"));
                }
                usuario.setUsername(nuevoUsername);
            }
        }
        
        // ✅ VALIDAR UNICIDAD DEL EMAIL (si se está cambiando)
        if (data.containsKey("email") && data.get("email") != null) {
            String nuevoEmail = data.get("email");
            String emailActual = usuario.getEmail();
            
            // Solo validar si el email cambió
            if (!nuevoEmail.equals(emailActual)) {
                Optional<Usuario> usuarioConEmail = usuarioRepository.findByEmail(nuevoEmail);
                if (usuarioConEmail.isPresent() && !usuarioConEmail.get().getId().equals(id)) {
                    return ResponseEntity.status(HttpStatus.CONFLICT)
                            .body(Map.of("error", "El correo electrónico ya está registrado"));
                }
                usuario.setEmail(nuevoEmail);
            }
        }
        
        // Actualizar otros campos
        if (data.containsKey("nombre")) {
            usuario.setNombre(data.get("nombre"));
        }
        if (data.containsKey("telefono")) {
            usuario.setTelefono(data.get("telefono"));
        }
        if (data.containsKey("fotoPerfil") && data.get("fotoPerfil") != null) {
            usuario.setFotoPerfil(data.get("fotoPerfil"));
        }
        
        // Actualizar campos específicos para JURIDICO
        if (data.containsKey("razonSocial")) {
            usuario.setRazonSocial(data.get("razonSocial"));
        }
        if (data.containsKey("nit")) {
            usuario.setNit(data.get("nit"));
        }
        if (data.containsKey("registroMercantil")) {
            usuario.setRegistroMercantil(data.get("registroMercantil"));
        }
        if (data.containsKey("direccionFiscal")) {
            usuario.setDireccionFiscal(data.get("direccionFiscal"));
        }
        if (data.containsKey("contribuyenteEspecial")) {
            String value = data.get("contribuyenteEspecial");
            usuario.setContribuyenteEspecial("true".equalsIgnoreCase(value));
        }
        
        // Actualizar campos específicos para TRANSPORTISTA
        if (data.containsKey("licenciaConducir")) {
            usuario.setLicenciaConducir(data.get("licenciaConducir"));
        }
        if (data.containsKey("aniosExperiencia")) {
            try {
                usuario.setAniosExperiencia(Integer.parseInt(data.get("aniosExperiencia")));
            } catch (NumberFormatException e) {
                // Ignorar si no es un número válido
            }
        }
        if (data.containsKey("tipoVehiculo")) {
            usuario.setTipoVehiculo(data.get("tipoVehiculo"));
        }
        
        Usuario usuarioActualizado = usuarioRepository.save(usuario);
        usuarioActualizado.setPassword(null);
        
        auditoriaService.registrarConDatos(
            usuario.getEmail(),
            "UPDATE_PERFIL",
            "Perfil actualizado para usuario: " + usuario.getEmail(),
            "usuarios",
            id,
            datosAnteriores,
            usuarioActualizado.toString(),
            true,
            null
        );
        
        return ResponseEntity.ok(usuarioActualizado);
    }).orElse(ResponseEntity.notFound().build());
}

    // ========================================
    // 4. CAMBIAR CONTRASEÑA
    // ========================================
    @PutMapping("/change-password/{id}")
    public ResponseEntity<?> changePassword(@PathVariable Long id, @RequestBody Map<String, String> data) {
        return usuarioRepository.findById(id).map(usuario -> {
            String oldPassword = data.get("oldPassword");
            String newPassword = data.get("newPassword");
            
            if (!passwordUtil.matches(oldPassword, usuario.getPassword())) {
                auditoriaService.registrar(usuario.getEmail(), "CAMBIO_CONTRASENA_ERROR", 
                    "Intento de cambio de contraseña con contraseña actual incorrecta");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body("Contraseña actual incorrecta");
            }
            
            usuario.setPassword(passwordUtil.encode(newPassword));
            usuarioRepository.save(usuario);
            
            auditoriaService.registrar(usuario.getEmail(), "CAMBIO_CONTRASENA", 
                "Contraseña cambiada exitosamente");
            
            return ResponseEntity.ok().body("Contraseña actualizada correctamente");
        }).orElse(ResponseEntity.notFound().build());
    }

    // ========================================
    // 5. OBTENER PERFIL
    // ========================================
    @GetMapping("/profile/{id}")
    public ResponseEntity<?> getProfile(@PathVariable Long id) {
        return usuarioRepository.findById(id)
                .map(usuario -> ResponseEntity.ok(new UsuarioDTO(usuario)))
                .orElse(ResponseEntity.notFound().build());
    }

    // ========================================
    // 6. VERIFICAR USUARIO
    // ========================================
    @PostMapping("/verificar-usuario")
public ResponseEntity<?> verificarUsuario(@RequestBody Map<String, String> request) {
    String email = request.get("email");
    String cedula = request.get("cedula");
    
    if (email == null || email.isEmpty() || cedula == null || cedula.isEmpty()) {
        return ResponseEntity.badRequest().body(Map.of(
            "error", "Email y cédula son requeridos"
        ));
    }
    
    // ✅ LIMPIAR CÉDULA: eliminar cualquier carácter no numérico
    String cedulaLimpia = cedula.replaceAll("[^0-9]", "");
    
    Optional<Usuario> usuarioOpt = usuarioRepository.findByEmail(email);
    
    if (usuarioOpt.isEmpty()) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
            "existe", false,
            "error", "No existe un usuario con este email"
        ));
    }
    
    Usuario usuario = usuarioOpt.get();
    
    // ✅ LIMPIAR CÉDULA DEL USUARIO para comparar solo números
    String cedulaUsuario = usuario.getCedula().replaceAll("[^0-9]", "");
    
    if (!cedulaUsuario.equals(cedulaLimpia)) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
            "existe", false,
            "error", "Cédula incorrecta"
        ));
    }
    
    return ResponseEntity.ok(Map.of(
        "existe", true,
        "nombre", usuario.getNombre(),
        "email", usuario.getEmail(),
        "id", usuario.getId()
    ));
}


    // ========================================
    // 7. SOLICITAR RECUPERACIÓN
    // ========================================
  @PostMapping("/solicitar-recuperacion")
@Transactional 
public ResponseEntity<?> solicitarRecuperacion(@RequestBody SolicitudRecuperacionDTO dto) {
    try {
        if (dto.getEmail() == null || dto.getEmail().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                "error", "El email es requerido"
            ));
        }
        
        if (dto.getCedula() == null || dto.getCedula().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                "error", "La cédula es requerida"
            ));
        }
        
        // ✅ LIMPIAR CÉDULA
        String cedulaLimpia = dto.getCedula().replaceAll("[^0-9]", "");
        
        Optional<Usuario> usuarioOpt = usuarioRepository.findByEmail(dto.getEmail());
        
        if (usuarioOpt.isEmpty()) {
            return ResponseEntity.ok(Map.of(
                "mensaje", "Si el email y cédula coinciden, recibirás un código de verificación"
            ));
        }
        
        Usuario usuario = usuarioOpt.get();
        
        // ✅ LIMPIAR CÉDULA DEL USUARIO
        String cedulaUsuario = usuario.getCedula().replaceAll("[^0-9]", "");
        
        if (!cedulaUsuario.equals(cedulaLimpia)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                "error", "Cédula incorrecta"
            ));
        }
        
        // ✅ AHORA CONTINÚA EL CÓDIGO (generar código, guardar token, enviar email)
        if (usuario.getActivo() == null || !usuario.getActivo()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of(
                "error", "Usuario desactivado. Contacta al administrador."
            ));
        }
        
        String codigoCorto = generarCodigoCorto();
        
        tokenRepository.deleteByUsuario(usuario);
        
        PasswordResetToken resetToken = new PasswordResetToken();
        resetToken.setToken(codigoCorto);
        resetToken.setUsuario(usuario);
        resetToken.setFechaCreacion(LocalDateTime.now());
        resetToken.setFechaExpiracion(LocalDateTime.now().plusMinutes(15));
        resetToken.setUsado(false);
        tokenRepository.save(resetToken);
        
        emailService.enviarCodigoRecuperacion(usuario.getEmail(), codigoCorto);
        
        auditoriaService.registrar(usuario.getEmail(), "RECUPERACION_ENVIADO", 
            "Código de recuperación enviado a " + usuario.getEmail());
        
        return ResponseEntity.ok(Map.of(
            "mensaje", "Código de verificación enviado correctamente",
            "email", usuario.getEmail()
        ));
        
    } catch (Exception e) {
        auditoriaService.registrar(dto.getEmail(), "RECUPERACION_ERROR", 
            "Error al enviar código: " + e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
            "error", "Error al procesar la solicitud: " + e.getMessage()
        ));
    }
}
    // ========================================
    // 8. VERIFICAR CÓDIGO
    // ========================================
    @PostMapping("/verificar-codigo")
    public ResponseEntity<?> verificarCodigo(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        
        if (token == null || token.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                "valido", false,
                "error", "Código requerido"
            ));
        }
        
        String codigoLimpio = token.replace("-", "").replace(" ", "").trim().toUpperCase();
        
        Optional<PasswordResetToken> tokenOpt = tokenRepository.findByToken(codigoLimpio);
        
        if (tokenOpt.isEmpty()) {
            tokenOpt = tokenRepository.findByToken(token);
        }
        
        if (tokenOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                "valido", false,
                "error", "Código inválido"
            ));
        }
        
        PasswordResetToken resetToken = tokenOpt.get();
        
        if (resetToken.getUsado()) {
            return ResponseEntity.status(HttpStatus.GONE).body(Map.of(
                "valido", false,
                "error", "Código ya utilizado"
            ));
        }
        
        if (resetToken.getFechaExpiracion().isBefore(LocalDateTime.now())) {
            return ResponseEntity.status(HttpStatus.REQUEST_TIMEOUT).body(Map.of(
                "valido", false,
                "error", "Código expirado"
            ));
        }
        
        return ResponseEntity.ok(Map.of(
            "valido", true,
            "mensaje", "Código válido",
            "email", resetToken.getUsuario().getEmail(),
            "usuarioId", resetToken.getUsuario().getId()
        ));
    }

    // ========================================
    // 9. CAMBIAR CONTRASEÑA CON CÓDIGO
    // ========================================
    @PostMapping("/cambiar-con-codigo")
    @Transactional 
    public ResponseEntity<?> cambiarConCodigo(@RequestBody Map<String, String> request) {
        try {
            String token = request.get("token");
            String nuevaPassword = request.get("nuevaPassword");
            
            if (token == null || token.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Código requerido"));
            }
            
            if (nuevaPassword == null || nuevaPassword.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Nueva contraseña requerida"));
            }
            
            if (nuevaPassword.length() < 6) {
                return ResponseEntity.badRequest().body(Map.of(
                    "error", "La contraseña debe tener al menos 6 caracteres"
                ));
            }
            
            String codigoLimpio = token.replace("-", "").replace(" ", "").trim().toUpperCase();
            
            Optional<PasswordResetToken> tokenOpt = tokenRepository.findByToken(codigoLimpio);
            
            if (tokenOpt.isEmpty()) {
                tokenOpt = tokenRepository.findByToken(token);
            }
            
            if (tokenOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                    "error", "Código inválido"
                ));
            }
            
            PasswordResetToken resetToken = tokenOpt.get();
            
            if (resetToken.getUsado()) {
                return ResponseEntity.status(HttpStatus.GONE).body(Map.of(
                    "error", "Código ya utilizado"
                ));
            }
            
            if (resetToken.getFechaExpiracion().isBefore(LocalDateTime.now())) {
                return ResponseEntity.status(HttpStatus.REQUEST_TIMEOUT).body(Map.of(
                    "error", "Código expirado"
                ));
            }
            
            Usuario usuario = resetToken.getUsuario();
            usuario.setPassword(passwordUtil.encode(nuevaPassword));
            usuarioRepository.save(usuario);
            
            resetToken.setUsado(true);
            tokenRepository.save(resetToken);
            
            auditoriaService.registrar(usuario.getEmail(), "RECUPERACION_EXITOSA", 
                "Contraseña restablecida exitosamente con código de verificación");
            
            return ResponseEntity.ok(Map.of(
                "mensaje", "Contraseña actualizada exitosamente",
                "email", usuario.getEmail()
            ));
            
        } catch (Exception e) {
            auditoriaService.registrar(
                request.get("email") != null ? request.get("email") : "ANONIMO", 
                "RECUPERACION_ERROR", 
                "Error al cambiar contraseña: " + e.getMessage()
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                "error", "Error al cambiar la contraseña: " + e.getMessage()
            ));
        }
    }

// ========================================
// 10. VERIFICAR USERNAME (NUEVO)
// ========================================
@PostMapping("/verificar-username")
public ResponseEntity<?> verificarUsername(@RequestBody Map<String, String> request) {
    String username = request.get("username");
    String userIdStr = request.get("userId");
    
    if (username == null || username.isEmpty()) {
        return ResponseEntity.badRequest().body(Map.of("available", false));
    }
    
    try {
        long userId = Long.parseLong(userIdStr);
        Optional<Usuario> usuarioExistente = usuarioRepository.findByUsername(username);
        
        // El username está disponible si:
        // 1. No existe en la base de datos
        // 2. O existe pero es el mismo usuario (está editando su propio username)
        boolean available = !usuarioExistente.isPresent() || 
                            usuarioExistente.get().getId().equals(userId);
        
        return ResponseEntity.ok(Map.of("available", available));
    } catch (NumberFormatException e) {
        return ResponseEntity.badRequest().body(Map.of("available", false));
    }
}

// ========================================
// 11. VERIFICAR EMAIL (NUEVO)
// ========================================
@PostMapping("/verificar-email")
public ResponseEntity<?> verificarEmail(@RequestBody Map<String, String> request) {
    String email = request.get("email");
    String userIdStr = request.get("userId");
    
    if (email == null || email.isEmpty()) {
        return ResponseEntity.badRequest().body(Map.of("available", false));
    }
    
    try {
        long userId = Long.parseLong(userIdStr);
        Optional<Usuario> usuarioExistente = usuarioRepository.findByEmail(email);
        
        // El email está disponible si:
        // 1. No existe en la base de datos
        // 2. O existe pero es el mismo usuario (está editando su propio email)
        boolean available = !usuarioExistente.isPresent() || 
                            usuarioExistente.get().getId().equals(userId);
        
        return ResponseEntity.ok(Map.of("available", available));
    } catch (NumberFormatException e) {
        return ResponseEntity.badRequest().body(Map.of("available", false));
    }
}



}