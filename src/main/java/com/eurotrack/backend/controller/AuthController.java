package com.eurotrack.backend.controller;

import com.eurotrack.backend.model.Usuario;
import com.eurotrack.backend.repository.UsuarioRepository;
import com.eurotrack.backend.util.PasswordUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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

    // LOGIN
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginData) {
        String identifier = loginData.get("email");
        String password = loginData.get("password");

        Optional<Usuario> usuarioOpt = usuarioRepository.findByEmail(identifier)
                .or(() -> usuarioRepository.findByUsername(identifier));

        if (usuarioOpt.isPresent()) {
            Usuario user = usuarioOpt.get();
            if (passwordUtil.matches(password, user.getPassword())) {
                Map<String, Object> response = new HashMap<>();
                response.put("id", user.getId());
                response.put("usuario", user.getNombre());
                response.put("username", user.getUsername());
                response.put("cedula", user.getCedula());
                response.put("rol", user.getRol());
                response.put("tipoCliente", user.getTipoCliente());
                response.put("fotoPerfil", user.getFotoPerfil()); 
                
                return ResponseEntity.ok(response);
            }
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Credenciales incorrectas");
    }

    // REGISTRO
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Usuario nuevoUsuario) {
        // Validaciones
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
            // ENCRIPTAR CONTRASEÑA
            nuevoUsuario.setPassword(passwordUtil.encode(nuevoUsuario.getPassword()));
            Usuario usuarioGuardado = usuarioRepository.save(nuevoUsuario);
            usuarioGuardado.setPassword(null); // No devolver la contraseña por seguridad
            return ResponseEntity.status(HttpStatus.CREATED).body(usuarioGuardado);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al guardar el usuario: " + e.getMessage());
        }
    }

    // ACTUALIZAR PERFIL
    @PutMapping("/update-profile/{id}")
    public ResponseEntity<?> updateProfile(@PathVariable Long id, @RequestBody Map<String, String> data) {
        return usuarioRepository.findById(id).map(usuario -> {
            if (data.containsKey("nombre")) {
                usuario.setNombre(data.get("nombre"));
            }
            if (data.containsKey("username")) {
                usuario.setUsername(data.get("username"));
            }
            if (data.containsKey("cedula")) {
                usuario.setCedula(data.get("cedula"));
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

    // OBTENER PERFIL
    @GetMapping("/profile/{id}")
    public ResponseEntity<?> getProfile(@PathVariable Long id) {
        return usuarioRepository.findById(id)
                .map(usuario -> {
                    usuario.setPassword(null);
                    return ResponseEntity.ok(usuario);
                })
                .orElse(ResponseEntity.notFound().build());
    }
}