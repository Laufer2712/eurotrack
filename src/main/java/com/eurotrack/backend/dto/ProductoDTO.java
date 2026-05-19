package com.eurotrack.backend.dto;

import com.eurotrack.backend.model.Producto;
import java.math.BigDecimal;  // ← Agrega esto

public class ProductoDTO {
    private Long id;
    private String nombre;
    private String descripcion;
    private String codigo;
    private String numeroParte;
    private String marca;
    private BigDecimal precio;  // ← Cambiado a BigDecimal
    private Integer stock;
    private String imagenUrl;
    private Boolean activo;
    private Long categoriaId;
    private String categoriaNombre;
    
    public ProductoDTO(Producto producto) {
        this.id = producto.getId();
        this.nombre = producto.getNombre();
        this.descripcion = producto.getDescripcion();
        this.codigo = producto.getCodigo();
        this.numeroParte = producto.getNumeroParte();
        this.marca = producto.getMarca();
        this.precio = producto.getPrecio();  // BigDecimal
        this.stock = producto.getStock();
        this.imagenUrl = producto.getImagenUrl();
        this.activo = producto.getActivo();
        
        if (producto.getCategoria() != null) {
            this.categoriaId = producto.getCategoria().getId();
            this.categoriaNombre = producto.getCategoria().getNombre();
        }
    }
    
    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    
    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }
    
    public String getNumeroParte() { return numeroParte; }
    public void setNumeroParte(String numeroParte) { this.numeroParte = numeroParte; }
    
    public String getMarca() { return marca; }
    public void setMarca(String marca) { this.marca = marca; }
    
    public BigDecimal getPrecio() { return precio; }
    public void setPrecio(BigDecimal precio) { this.precio = precio; }
    
    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
    
    public String getImagenUrl() { return imagenUrl; }
    public void setImagenUrl(String imagenUrl) { this.imagenUrl = imagenUrl; }
    
    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
    
    public Long getCategoriaId() { return categoriaId; }
    public void setCategoriaId(Long categoriaId) { this.categoriaId = categoriaId; }
    
    public String getCategoriaNombre() { return categoriaNombre; }
    public void setCategoriaNombre(String categoriaNombre) { this.categoriaNombre = categoriaNombre; }
}