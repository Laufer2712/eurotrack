package com.eurotrack.backend.dto;

import com.eurotrack.backend.model.Pedido;
import com.eurotrack.backend.model.Usuario;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

public class PedidoDTO {
    private Long id;
    private LocalDateTime fecha;
    private String estado;
    private Double total;  // ← Double
    private Long usuarioId;
    private String usuarioNombre;
    private String direccionEntrega;
    private String metodoPago;
    private List<DetallePedidoDTO> detalles;
    
    public PedidoDTO(Pedido pedido) {
        this.id = pedido.getId();
        this.fecha = pedido.getFecha();
        this.estado = pedido.getEstado();
        this.total = pedido.getTotal();
        this.direccionEntrega = pedido.getDireccionEntrega();
        this.metodoPago = pedido.getMetodoPago();
        
        if (pedido.getUsuario() != null) {
            this.usuarioId = pedido.getUsuario().getId();
            this.usuarioNombre = pedido.getUsuario().getNombre();
        }
        
        if (pedido.getDetalles() != null && !pedido.getDetalles().isEmpty()) {
            this.detalles = pedido.getDetalles().stream()
                .map(DetallePedidoDTO::new)
                .collect(Collectors.toList());
        }
    }
    
    // Constructor vacío
    public PedidoDTO() {}
    
    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public LocalDateTime getFecha() { return fecha; }
    public void setFecha(LocalDateTime fecha) { this.fecha = fecha; }
    
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    
    public Double getTotal() { return total; }
    public void setTotal(Double total) { this.total = total; }
    
    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }
    
    public String getUsuarioNombre() { return usuarioNombre; }
    public void setUsuarioNombre(String usuarioNombre) { this.usuarioNombre = usuarioNombre; }
    
    public String getDireccionEntrega() { return direccionEntrega; }
    public void setDireccionEntrega(String direccionEntrega) { this.direccionEntrega = direccionEntrega; }
    
    public String getMetodoPago() { return metodoPago; }
    public void setMetodoPago(String metodoPago) { this.metodoPago = metodoPago; }
    
    public List<DetallePedidoDTO> getDetalles() { return detalles; }
    public void setDetalles(List<DetallePedidoDTO> detalles) { this.detalles = detalles; }
}