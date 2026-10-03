// com/eurotrack/backend/service/NotificacionService.java

package com.eurotrack.backend.util;

import com.eurotrack.backend.model.Notificacion;
import com.eurotrack.backend.model.Usuario;
import com.eurotrack.backend.repository.NotificacionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class NotificacionService {

    @Autowired
    private NotificacionRepository notificacionRepository;

    // ✅ Crear notificación para un usuario
    public Notificacion crearNotificacion(Usuario usuario, String titulo, String mensaje, String tipo) {
        Notificacion notificacion = new Notificacion(usuario, titulo, mensaje, tipo);
        return notificacionRepository.save(notificacion);
    }

    // ✅ Crear notificación de pedido
    public Notificacion crearNotificacionPedido(Usuario usuario, String titulo, String mensaje, Long pedidoId) {
        Notificacion notificacion = new Notificacion(usuario, titulo, mensaje, "PEDIDO");
        notificacion.setPedidoId(pedidoId);
        return notificacionRepository.save(notificacion);
    }

    // ✅ Crear notificación de pago
    public Notificacion crearNotificacionPago(Usuario usuario, String titulo, String mensaje) {
        Notificacion notificacion = new Notificacion(usuario, titulo, mensaje, "PAGO");
        return notificacionRepository.save(notificacion);
    }

    // ✅ Crear notificación de alerta
    public Notificacion crearNotificacionAlerta(Usuario usuario, String titulo, String mensaje, Long productoId) {
        Notificacion notificacion = new Notificacion(usuario, titulo, mensaje, "ALERTA");
        notificacion.setProductoId(productoId);
        return notificacionRepository.save(notificacion);
    }
}