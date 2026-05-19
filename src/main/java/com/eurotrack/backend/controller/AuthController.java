package com.eurotrack.backend.controller;

import com.eurotrack.backend.dto.UsuarioDTO;
import com.eurotrack.backend.model.Usuario;
import com.eurotrack.backend.repository.UsuarioRepository;
import com.eurotrack.backend.util.PasswordUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
    private UsuarioRepository usuarioRepository;
    
    @Autowired
    private PasswordUtil passwordUtil;

    // Constantes para generar código de respaldo
    private static final String CODIGO_CHARACTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ0123456789";
    private static final int CODIGO_LENGTH = 8;
    private static final SecureRandom random = new SecureRandom();

    // Generar código único (formato XXXX-XXXX)
    private String generarCodigoRespaldo() {
        StringBuilder codigo = new StringBuilder(CODIGO_LENGTH);
        for (int i = 0; i < CODIGO_LENGTH; i++) {
            if (i == 4) codigo.append('-');
            codigo.append(CODIGO_CHARACTERS.charAt(random.nextInt(CODIGO_CHARACTERS.length())));
        }
        return codigo.toString();
    }

    // Asegurar código único
    private String generarCodigoUnico() {
        String codigo;
        do {
            codigo = generarCodigoRespaldo();
        } while (usuarioRepository.findByCodigoRespaldo(codigo).isPresent());
        return codigo;
    }

    // LOGIN
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginData) {
        String identifier = loginData.get("email");
        String password = loginData.get("password");

        Optional<Usuario> usuarioOpt = usuarioRepository.findByEmail(identifier)
                .or(() -> usuarioRepository.findByUsername(identifier));

        if (usuarioOpt.isPresent()) {
            Usuario user = usuarioOpt.get();
            // 🔥 Verificar si el usuario está activo
            if (user.getActivo() == null || !user.getActivo()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Usuario desactivado. Contacta al administrador.");
            }
            
            if (passwordUtil.matches(password, user.getPassword())) {
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
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Credenciales incorrectas");
    }

    // REGISTRO - Genera código de respaldo y teléfono
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Usuario nuevoUsuario) {
        if (usuarioRepository.findByEmail(nuevoUsuario.getEmail()).isPresent()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("El correo electrónico ya está registrado");
        }

        if (usuarioRepository.findByUsername(nuevoUsuario.getUsername()).isPresent()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("El nombre de usuario ya está en uso");
        }

        if (usuarioRepository.findByCedula(nuevoUsuario.getCedula()).isPresent()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("La identificación (Cédula/RIF) ya está registrada");
        }

        try {
            nuevoUsuario.setPassword(passwordUtil.encode(nuevoUsuario.getPassword()));
            
            // Generar código de respaldo
            String codigoRespaldo = generarCodigoUnico();
            nuevoUsuario.setCodigoRespaldo(codigoRespaldo);
            nuevoUsuario.setCodigoRespaldoUsado(false);
            nuevoUsuario.setCodigoRespaldoGeneradoEn(LocalDateTime.now());
            
            // 🔥 Por defecto, el usuario está activo
            nuevoUsuario.setActivo(true);
            
            Usuario usuarioGuardado = usuarioRepository.save(nuevoUsuario);
            usuarioGuardado.setPassword(null);
            
            // Devolver el código en la respuesta
            Map<String, Object> response = new HashMap<>();
            response.put("usuario", usuarioGuardado);
            response.put("codigoRespaldo", codigoRespaldo);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al guardar el usuario: " + e.getMessage());
        }
    }

    // ACTUALIZAR PERFIL (NO permite editar cédula)
    @PutMapping("/update-profile/{id}")
    public ResponseEntity<?> updateProfile(@PathVariable Long id, @RequestBody Map<String, String> data) {
        return usuarioRepository.findById(id).map(usuario -> {
            if (data.containsKey("nombre")) {
                usuario.setNombre(data.get("nombre"));
            }
            if (data.containsKey("username")) {
                usuario.setUsername(data.get("username"));
            }
            // 🔥 NO permitir editar cédula - eliminado
            if (data.containsKey("telefono")) {
                usuario.setTelefono(data.get("telefono"));
            }
            if (data.containsKey("fotoPerfil") && data.get("fotoPerfil") != null) {
                usuario.setFotoPerfil(data.get("fotoPerfil"));
            }
            usuarioRepository.save(usuario);
            usuario.setPassword(null);
            return ResponseEntity.ok(usuario);
        }).orElse(ResponseEntity.notFound().build());
    }

    // ACTUALIZAR CONTRASEÑA
    @PutMapping("/change-password/{id}")
    public ResponseEntity<?> changePassword(@PathVariable Long id, @RequestBody Map<String, String> data) {
        return usuarioRepository.findById(id).map(usuario -> {
            String oldPassword = data.get("oldPassword");
            String newPassword = data.get("newPassword");
            
            if (!passwordUtil.matches(oldPassword, usuario.getPassword())) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Contraseña actual incorrecta");
            }
            
            usuario.setPassword(passwordUtil.encode(newPassword));
            usuarioRepository.save(usuario);
            return ResponseEntity.ok().body("Contraseña actualizada correctamente");
        }).orElse(ResponseEntity.notFound().build());
    }

    // OBTENER PERFIL - Devuelve DTO
    @GetMapping("/profile/{id}")
    public ResponseEntity<?> getProfile(@PathVariable Long id) {
        return usuarioRepository.findById(id)
                .map(usuario -> {
                    UsuarioDTO usuarioDTO = new UsuarioDTO(usuario);
                    return ResponseEntity.ok(usuarioDTO);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // ========== MÉTODOS PARA CÓDIGO DE RESPALDO ==========

    // OBTENER CÓDIGO DE RESPALDO DEL USUARIO
    @GetMapping("/mi-codigo-respaldo/{userId}")
    public ResponseEntity<?> getMiCodigoRespaldo(@PathVariable Long userId) {
        return usuarioRepository.findById(userId).map(usuario -> {
            Map<String, Object> response = new HashMap<>();
            response.put("codigoRespaldo", usuario.getCodigoRespaldo());
            response.put("usado", usuario.getCodigoRespaldoUsado());
            response.put("generadoEn", usuario.getCodigoRespaldoGeneradoEn());
            return ResponseEntity.ok(response);
        }).orElse(ResponseEntity.notFound().build());
    }

    // VALIDAR CÓDIGO DE RESPALDO (antes de cambiar contraseña)
    @PostMapping("/validar-codigo-respaldo")
    public ResponseEntity<?> validarCodigoRespaldo(@RequestBody Map<String, String> request) {
        String codigoRespaldo = request.get("codigoRespaldo");
        
        if (codigoRespaldo == null || codigoRespaldo.isEmpty()) {
            return ResponseEntity.badRequest().body("Código requerido");
        }
        
        Optional<Usuario> usuarioOpt = usuarioRepository.findByCodigoRespaldo(codigoRespaldo);
        
        if (usuarioOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Código de respaldo inválido");
        }
        
        Usuario usuario = usuarioOpt.get();
        
        if (usuario.getCodigoRespaldoUsado()) {
            return ResponseEntity.badRequest().body("Este código de respaldo ya fue utilizado");
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("valido", true);
        response.put("usuarioId", usuario.getId());
        response.put("usuarioNombre", usuario.getNombre());
        response.put("usuarioEmail", usuario.getEmail());
        return ResponseEntity.ok(response);
    }

    // RECUPERAR CONTRASEÑA USANDO CÓDIGO DE RESPALDO
    @PostMapping("/recuperar-con-codigo")
    public ResponseEntity<?> recuperarConCodigo(@RequestBody Map<String, String> request) {
        String codigoRespaldo = request.get("codigoRespaldo");
        String nuevaPassword = request.get("nuevaPassword");
        
        if (codigoRespaldo == null || nuevaPassword == null) {
            return ResponseEntity.badRequest().body("Código y nueva contraseña requeridos");
        }
        
        Optional<Usuario> usuarioOpt = usuarioRepository.findByCodigoRespaldo(codigoRespaldo);
        
        if (usuarioOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Código de respaldo inválido");
        }
        
        Usuario usuario = usuarioOpt.get();
        
        if (usuario.getCodigoRespaldoUsado()) {
            return ResponseEntity.badRequest().body("Este código de respaldo ya fue utilizado");
        }
        
        // Actualizar contraseña
        usuario.setPassword(passwordUtil.encode(nuevaPassword));
        usuario.setCodigoRespaldoUsado(true);
        usuarioRepository.save(usuario);
        
        Map<String, String> response = new HashMap<>();
        response.put("mensaje", "Contraseña actualizada exitosamente");
        response.put("usuarioId", usuario.getId().toString());
        return ResponseEntity.ok(response);
    }
}