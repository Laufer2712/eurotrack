// com/eurotrack/backend/repository/NotificacionRepository.java

package com.eurotrack.backend.repository;

import com.eurotrack.backend.model.Notificacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface NotificacionRepository extends JpaRepository<Notificacion, Long> {

    // ✅ Obtener notificaciones de un usuario (ordenadas por fecha descendente)
    List<Notificacion> findByUsuarioIdOrderByFechaCreacionDesc(Long usuarioId);

    // ✅ Obtener notificaciones no leídas de un usuario
    List<Notificacion> findByUsuarioIdAndLeidoFalseOrderByFechaCreacionDesc(Long usuarioId);

    // ✅ Contar notificaciones no leídas
    long countByUsuarioIdAndLeidoFalse(Long usuarioId);

    // ✅ Marcar todas las notificaciones de un usuario como leídas
    @Modifying
    @Transactional
    @Query("UPDATE Notificacion n SET n.leido = true WHERE n.usuario.id = :usuarioId AND n.leido = false")
    void marcarTodasComoLeidas(@Param("usuarioId") Long usuarioId);

    // ✅ Eliminar notificaciones de un usuario
    @Modifying
    @Transactional
    void deleteByUsuarioId(Long usuarioId);
}