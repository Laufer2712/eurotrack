package com.eurotrack.backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "usuarios")
public class Usuario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(unique = true)
    private String username;

    @Column(unique = true)
    private String cedula; 

    @Column(nullable = false)
    private String password;

    private String nombre;
    private String rol;
    
    @Column(name = "tipo_cliente")
    private String tipoCliente; // NATURAL, JURIDICO, TRANSPORTISTA

    @Column(columnDefinition = "TEXT")
    private String fotoPerfil;
    
    @Column(name = "telefono")
    private String telefono;
    
    @Column(name = "activo")
    private Boolean activo = true;

    // ========== CAMPOS PARA EMPRESAS (JURIDICO) ==========
    @Column(name = "razon_social")
    private String razonSocial;
    
    @Column(name = "nit")
    private String nit;
    
    @Column(name = "registro_mercantil")
    private String registroMercantil;
    
    @Column(name = "direccion_fiscal")
    private String direccionFiscal;
    
    @Column(name = "contribuyente_especial")
    private Boolean contribuyenteEspecial = false; // Si es contribuyente especial (impuesto diferenciado)

    // ========== CAMPOS PARA TRANSPORTISTA ==========
    @Column(name = "licencia_conducir")
    private String licenciaConducir;
    
    @Column(name = "anios_experiencia")
    private Integer aniosExperiencia;
    
    @Column(name = "tipo_vehiculo")
    private String tipoVehiculo; // CAMION, FURGON, TRAILER, etc.

    // Getters y Setters...
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getCedula() { return cedula; }
    public void setCedula(String cedula) { this.cedula = cedula; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    
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
    
    // Campos Empresa
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
    
    // Campos Transportista
    public String getLicenciaConducir() { return licenciaConducir; }
    public void setLicenciaConducir(String licenciaConducir) { this.licenciaConducir = licenciaConducir; }
    
    public Integer getAniosExperiencia() { return aniosExperiencia; }
    public void setAniosExperiencia(Integer aniosExperiencia) { this.aniosExperiencia = aniosExperiencia; }
    
    public String getTipoVehiculo() { return tipoVehiculo; }
    public void setTipoVehiculo(String tipoVehiculo) { this.tipoVehiculo = tipoVehiculo; }
}