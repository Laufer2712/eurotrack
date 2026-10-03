// com/eurotrack/backend/controller/NotificacionController.java

package com.eurotrack.backend.controller;

import com.eurotrack.backend.dto.NotificacionDTO;
import com.eurotrack.backend.model.Notificacion;
import com.eurotrack.backend.model.Usuario;
import com.eurotrack.backend.repository.NotificacionRepository;
import com.eurotrack.backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/notificaciones")
@CrossOrigin(origins = "*")
public class NotificacionController {

    @Autowired
    private NotificacionRepository notificacionRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    // ✅ Obtener todas las notificaciones de un usuario
    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<?> getNotificacionesByUsuario(@PathVariable Long usuarioId) {
        if (!usuarioRepository.existsById(usuarioId)) {
            return ResponseEntity.notFound().build();
        }

        List<Notificacion> notificaciones = notificacionRepository
                .findByUsuarioIdOrderByFechaCreacionDesc(usuarioId);

        List<NotificacionDTO> notificacionesDTO = notificaciones.stream()
                .map(NotificacionDTO::new)
                .collect(Collectors.toList());

        return ResponseEntity.ok(notificacionesDTO);
    }

    // ✅ Obtener solo notificaciones no leídas
    @GetMapping("/usuario/{usuarioId}/no-leidas")
    public ResponseEntity<?> getNotificacionesNoLeidas(@PathVariable Long usuarioId) {
        if (!usuarioRepository.existsById(usuarioId)) {
            return ResponseEntity.notFound().build();
        }

        List<Notificacion> notificaciones = notificacionRepository
                .findByUsuarioIdAndLeidoFalseOrderByFechaCreacionDesc(usuarioId);

        List<NotificacionDTO> notificacionesDTO = notificaciones.stream()
                .map(NotificacionDTO::new)
                .collect(Collectors.toList());

        return ResponseEntity.ok(notificacionesDTO);
    }

    // ✅ Obtener conteo de notificaciones no leídas
    @GetMapping("/usuario/{usuarioId}/contador")
    public ResponseEntity<?> getContadorNoLeidas(@PathVariable Long usuarioId) {
        if (!usuarioRepository.existsById(usuarioId)) {
            return ResponseEntity.notFound().build();
        }

        long count = notificacionRepository.countByUsuarioIdAndLeidoFalse(usuarioId);
        return ResponseEntity.ok(count);
    }

    // ✅ Crear una notificación (CORREGIDO)
    @PostMapping
    public ResponseEntity<?> crearNotificacion(@RequestBody NotificacionDTO notificacionDTO) {
        // ✅ CORRECCIÓN: usar getUsuarioId() en lugar de getId()
        Long usuarioId = notificacionDTO.getUsuarioId();
        
        if (usuarioId == null) {
            return ResponseEntity.badRequest().body("Usuario ID no puede ser nulo");
        }
        
        if (!usuarioRepository.existsById(usuarioId)) {
            return ResponseEntity.badRequest().body("Usuario no existe");
        }

        Usuario usuario = usuarioRepository.findById(usuarioId).get();

        Notificacion notificacion = new Notificacion();
        notificacion.setUsuario(usuario);
        notificacion.setTitulo(notificacionDTO.getTitulo());
        notificacion.setMensaje(notificacionDTO.getMensaje());
        notificacion.setTipo(notificacionDTO.getTipo());
        notificacion.setPedidoId(notificacionDTO.getPedidoId());
        notificacion.setProductoId(notificacionDTO.getProductoId());
        notificacion.setImagenUrl(notificacionDTO.getImagenUrl());
        notificacion.setLeido(false);

        Notificacion saved = notificacionRepository.save(notificacion);
        return ResponseEntity.ok(new NotificacionDTO(saved));
    }

    // ✅ Marcar una notificación como leída
    @PutMapping("/{notificacionId}/leer")
    public ResponseEntity<?> marcarComoLeido(@PathVariable Long notificacionId) {
        Notificacion notificacion = notificacionRepository.findById(notificacionId)
                .orElseThrow(() -> new RuntimeException("Notificación no encontrada"));

        notificacion.setLeido(true);
        notificacionRepository.save(notificacion);

        return ResponseEntity.ok(new NotificacionDTO(notificacion));
    }

    // ✅ Marcar todas las notificaciones de un usuario como leídas
    @PutMapping("/usuario/{usuarioId}/leer-todas")
    public ResponseEntity<?> marcarTodasComoLeidas(@PathVariable Long usuarioId) {
        if (!usuarioRepository.existsById(usuarioId)) {
            return ResponseEntity.notFound().build();
        }

        notificacionRepository.marcarTodasComoLeidas(usuarioId);
        return ResponseEntity.ok().body("Todas las notificaciones marcadas como leídas");
    }

    // ✅ Eliminar una notificación
    @DeleteMapping("/{notificacionId}")
    public ResponseEntity<?> eliminarNotificacion(@PathVariable Long notificacionId) {
        if (!notificacionRepository.existsById(notificacionId)) {
            return ResponseEntity.notFound().build();
        }

        notificacionRepository.deleteById(notificacionId);
        return ResponseEntity.ok().body("Notificación eliminada");
    }

    // ✅ Eliminar todas las notificaciones de un usuario
    @DeleteMapping("/usuario/{usuarioId}")
    public ResponseEntity<?> eliminarNotificacionesByUsuario(@PathVariable Long usuarioId) {
        if (!usuarioRepository.existsById(usuarioId)) {
            return ResponseEntity.notFound().build();
        }

        notificacionRepository.deleteByUsuarioId(usuarioId);
        return ResponseEntity.ok().body("Notificaciones eliminadas");
    }
}