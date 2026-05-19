package com.eurotrack.backend.model;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
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
    private String tipoCliente;

    @Column(columnDefinition = "TEXT")
    private String fotoPerfil;
    
    // 🔥 NUEVOS CAMPOS
    @Column(name = "telefono")
    private String telefono;
    
    @Column(name = "activo")
    private Boolean activo = true;
    
    // Código de respaldo (existente)
    @Column(unique = true)
    private String codigoRespaldo;
    
    private Boolean codigoRespaldoUsado = false;
    
    private LocalDateTime codigoRespaldoGeneradoEn;
    
    // Getters y Setters existentes...
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
    
    // 🔥 NUEVOS GETTERS Y SETTERS
    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    
    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
    
    public String getCodigoRespaldo() { return codigoRespaldo; }
    public void setCodigoRespaldo(String codigoRespaldo) { this.codigoRespaldo = codigoRespaldo; }
    
    public Boolean getCodigoRespaldoUsado() { return codigoRespaldoUsado; }
    public void setCodigoRespaldoUsado(Boolean codigoRespaldoUsado) { this.codigoRespaldoUsado = codigoRespaldoUsado; }
    
    public LocalDateTime getCodigoRespaldoGeneradoEn() { return codigoRespaldoGeneradoEn; }
    public void setCodigoRespaldoGeneradoEn(LocalDateTime codigoRespaldoGeneradoEn) { this.codigoRespaldoGeneradoEn = codigoRespaldoGeneradoEn; }
}