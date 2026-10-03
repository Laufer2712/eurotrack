// com/eurotrack/backend/dto/NotificacionDTO.java

package com.eurotrack.backend.dto;

import com.eurotrack.backend.model.Notificacion;
import java.time.LocalDateTime;

public class NotificacionDTO {
    private Long id;
    private Long usuarioId;  // ✅ Este campo es importante
    private String titulo;
    private String mensaje;
    private String tipo;
    private Boolean leido;
    private LocalDateTime fecha;
    private Long pedidoId;
    private Long productoId;
    private String imagenUrl;

    public NotificacionDTO() {}

    public NotificacionDTO(Notificacion notificacion) {
        this.id = notificacion.getId();
        this.usuarioId = notificacion.getUsuario() != null ? notificacion.getUsuario().getId() : null;
        this.titulo = notificacion.getTitulo();
        this.mensaje = notificacion.getMensaje();
        this.tipo = notificacion.getTipo();
        this.leido = notificacion.getLeido();
        this.fecha = notificacion.getFechaCreacion();
        this.pedidoId = notificacion.getPedidoId();
        this.productoId = notificacion.getProductoId();
        this.imagenUrl = notificacion.getImagenUrl();
    }

    // ✅ Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getMensaje() { return mensaje; }
    public void setMensaje(String mensaje) { this.mensaje = mensaje; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public Boolean getLeido() { return leido; }
    public void setLeido(Boolean leido) { this.leido = leido; }

    public LocalDateTime getFecha() { return fecha; }
    public void setFecha(LocalDateTime fecha) { this.fecha = fecha; }

    public Long getPedidoId() { return pedidoId; }
    public void setPedidoId(Long pedidoId) { this.pedidoId = pedidoId; }

    public Long getProductoId() { return productoId; }
    public void setProductoId(Long productoId) { this.productoId = productoId; }

    public String getImagenUrl() { return imagenUrl; }
    public void setImagenUrl(String imagenUrl) { this.imagenUrl = imagenUrl; }
}