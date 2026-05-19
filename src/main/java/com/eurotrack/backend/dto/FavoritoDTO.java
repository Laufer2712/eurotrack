package com.eurotrack.backend.dto;

import com.eurotrack.backend.model.Favorito;
import com.eurotrack.backend.model.Usuario;
import com.eurotrack.backend.model.Producto;
import java.math.BigDecimal;  // ← Agrega esta importación

public class FavoritoDTO {
    private Long id;
    private Long usuarioId;
    private String usuarioNombre;
    private Long productoId;
    private String productoNombre;
    private String productoMarca;
    private BigDecimal productoPrecio;  // ← Cambiado a BigDecimal
    private String productoImagenUrl;
    private String productoCodigo;
    
    public FavoritoDTO(Favorito favorito) {
        this.id = favorito.getId();
        
        if (favorito.getUsuario() != null) {
            this.usuarioId = favorito.getUsuario().getId();
            this.usuarioNombre = favorito.getUsuario().getNombre();
        }
        
        if (favorito.getProducto() != null) {
            this.productoId = favorito.getProducto().getId();
            this.productoNombre = favorito.getProducto().getNombre();
            this.productoMarca = favorito.getProducto().getMarca();
            this.productoPrecio = favorito.getProducto().getPrecio();  // BigDecimal
            this.productoImagenUrl = favorito.getProducto().getImagenUrl();
            this.productoCodigo = favorito.getProducto().getCodigo();
        }
    }
    
    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }
    
    public String getUsuarioNombre() { return usuarioNombre; }
    public void setUsuarioNombre(String usuarioNombre) { this.usuarioNombre = usuarioNombre; }
    
    public Long getProductoId() { return productoId; }
    public void setProductoId(Long productoId) { this.productoId = productoId; }
    
    public String getProductoNombre() { return productoNombre; }
    public void setProductoNombre(String productoNombre) { this.productoNombre = productoNombre; }
    
    public String getProductoMarca() { return productoMarca; }
    public void setProductoMarca(String productoMarca) { this.productoMarca = productoMarca; }
    
    public BigDecimal getProductoPrecio() { return productoPrecio; }
    public void setProductoPrecio(BigDecimal productoPrecio) { this.productoPrecio = productoPrecio; }
    
    public String getProductoImagenUrl() { return productoImagenUrl; }
    public void setProductoImagenUrl(String productoImagenUrl) { this.productoImagenUrl = productoImagenUrl; }
    
    public String getProductoCodigo() { return productoCodigo; }
    public void setProductoCodigo(String productoCodigo) { this.productoCodigo = productoCodigo; }
}