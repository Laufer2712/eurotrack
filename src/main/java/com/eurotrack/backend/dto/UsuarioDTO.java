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
    private String telefono;
    private Boolean activo;
    
    // Campos Empresa
    private String razonSocial;
    private String nit;
    private String registroMercantil;
    private String direccionFiscal;
    private Boolean contribuyenteEspecial;
    
    // Campos Transportista
    private String licenciaConducir;
    private Integer aniosExperiencia;
    private String tipoVehiculo;
    
    public UsuarioDTO(Usuario usuario) {
        this.id = usuario.getId();
        this.nombre = usuario.getNombre();
        this.cedula = usuario.getCedula();
        this.username = usuario.getUsername();
        this.email = usuario.getEmail();
        this.rol = usuario.getRol();
        this.tipoCliente = usuario.getTipoCliente();
        this.fotoPerfil = usuario.getFotoPerfil();
        this.telefono = usuario.getTelefono();
        this.activo = usuario.getActivo();
        
        // Campos Empresa
        this.razonSocial = usuario.getRazonSocial();
        this.nit = usuario.getNit();
        this.registroMercantil = usuario.getRegistroMercantil();
        this.direccionFiscal = usuario.getDireccionFiscal();
        this.contribuyenteEspecial = usuario.getContribuyenteEspecial();
        
        // Campos Transportista
        this.licenciaConducir = usuario.getLicenciaConducir();
        this.aniosExperiencia = usuario.getAniosExperiencia();
        this.tipoVehiculo = usuario.getTipoVehiculo();
    }
    
    // Getters y Setters...
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
    
    public String getRazonSocial() { return razonSocial; }
    public void setRazonSocial(String razonSocial) { this.razonSocial = razonSocial; }
    
    public String getNit() { return nit; }
    public void setNit(String nit) { this.nit = nit; }
    
    public String getRegistroMercantil() { return registroMercantil; }
    public void setRegistroMercantil(String registroMercantil) { this.registroMercantil = registroMercantil; }
    
    public String getDireccionFiscal() { return direccionFiscal; }
    public void setDireccionFiscal(String direccionFiscal) { this.direccionFiscal = direccionFiscal; }
    
    public Boolean getContribuyenteEspecial() { return contribuyenteEspecial; }
    public void setContribuyenteEspecial(Boolean contribuyenteEspecial) { this.contribuyenteEspecial = contribuyenteEspecial; }
    
    public String getLicenciaConducir() { return licenciaConducir; }
    public void setLicenciaConducir(String licenciaConducir) { this.licenciaConducir = licenciaConducir; }
    
    public Integer getAniosExperiencia() { return aniosExperiencia; }
    public void setAniosExperiencia(Integer aniosExperiencia) { this.aniosExperiencia = aniosExperiencia; }
    
    public String getTipoVehiculo() { return tipoVehiculo; }
    public void setTipoVehiculo(String tipoVehiculo) { this.tipoVehiculo = tipoVehiculo; }
}