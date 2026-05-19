package com.eurotrack.backend.dto;

import com.eurotrack.backend.model.Usuario;

public class UsuarioDTO {
    private Long id;
    private String nombre;
    private String cedula;
    private String username;
    private String email;
    private String rol;
    private String tipoCliente;
    private String fotoPerfil;
    private String telefono;  // 🔥 NUEVO
    private Boolean activo;    // 🔥 NUEVO
    
    public UsuarioDTO(Usuario usuario) {
        this.id = usuario.getId();
        this.nombre = usuario.getNombre();
        this.cedula = usuario.getCedula();
        this.username = usuario.getUsername();
        this.email = usuario.getEmail();
        this.rol = usuario.getRol();
        this.tipoCliente = usuario.getTipoCliente();
        this.fotoPerfil = usuario.getFotoPerfil();
        this.telefono = usuario.getTelefono();  // 🔥 NUEVO
        this.activo = usuario.getActivo();      // 🔥 NUEVO
    }
    
    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    
    public String getCedula() { return cedula; }
    public void setCedula(String cedula) { this.cedula = cedula; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getRol() { return rol; }
    public void setRol(String rol) { this.rol = rol; }
    
    public String getTipoCliente() { return tipoCliente; }
    public void setTipoCliente(String tipoCliente) { this.tipoCliente = tipoCliente; }
    
    public String getFotoPerfil() { return fotoPerfil; }
    public void setFotoPerfil(String fotoPerfil) { this.fotoPerfil = fotoPerfil; }
    
    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    
    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
}