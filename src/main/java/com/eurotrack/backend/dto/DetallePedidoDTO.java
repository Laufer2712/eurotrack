package com.eurotrack.backend.dto;

import com.eurotrack.backend.model.DetallePedido;
import com.eurotrack.backend.model.Producto;

public class DetallePedidoDTO {
    private Long id;
    private Integer cantidad;
    private Double precioUnitario;  // ← Double (coincide con tu entidad)
    private Double subtotal;        // ← Double (coincide con tu entidad)
    private Long productoId;
    private String productoNombre;
    private String productoCodigo;
    private String productoImagenUrl;
    
    public DetallePedidoDTO(DetallePedido detalle) {
        this.id = detalle.getId();
        this.cantidad = detalle.getCantidad();
        this.precioUnitario = detalle.getPrecioUnitario();
        this.subtotal = detalle.getSubtotal();
        
        if (detalle.getProducto() != null) {
            this.productoId = detalle.getProducto().getId();
            this.productoNombre = detalle.getProducto().getNombre();
            this.productoCodigo = detalle.getProducto().getCodigo();
            this.productoImagenUrl = detalle.getProducto().getImagenUrl();
        }
    }
    
    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Integer getCantidad() { return cantidad; }
    public void setCantidad(Integer cantidad) { this.cantidad = cantidad; }
    
    public Double getPrecioUnitario() { return precioUnitario; }
    public void setPrecioUnitario(Double precioUnitario) { this.precioUnitario = precioUnitario; }
    
    public Double getSubtotal() { return subtotal; }
    public void setSubtotal(Double subtotal) { this.subtotal = subtotal; }
    
    public Long getProductoId() { return productoId; }
    public void setProductoId(Long productoId) { this.productoId = productoId; }
    
    public String getProductoNombre() { return productoNombre; }
    public void setProductoNombre(String productoNombre) { this.productoNombre = productoNombre; }
    
    public String getProductoCodigo() { return productoCodigo; }
    public void setProductoCodigo(String productoCodigo) { this.productoCodigo = productoCodigo; }
    
    public String getProductoImagenUrl() { return productoImagenUrl; }
    public void setProductoImagenUrl(String productoImagenUrl) { this.productoImagenUrl = productoImagenUrl; }
}