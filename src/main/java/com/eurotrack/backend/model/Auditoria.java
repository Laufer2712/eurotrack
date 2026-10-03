package com.eurotrack.backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "auditoria")
public class Auditoria {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 255)
    private String usuario;
    
    @Column(nullable = false, length = 50)
    private String accion;
    
    @Column(nullable = false, length = 1000)
    private String descripcion;
    
    @Column(name = "tabla_afectada", length = 100)
    private String tablaAfectada;
    
    @Column(name = "registro_id")
    private Long registroId;
    
    @Column(name = "datos_anteriores", columnDefinition = "TEXT")
    private String datosAnteriores;
    
    @Column(name = "datos_nuevos", columnDefinition = "TEXT")
    private String datosNuevos;
    
    @Column(name = "ip_origen", length = 45)
    private String ipOrigen;
    
    @Column(name = "user_agent", length = 255)
    private String userAgent;
    
    @Column(nullable = false)
    private LocalDateTime fecha;
    
    @Column(name = "nivel_severidad", length = 20)
    private String nivelSeveridad;
    
    private Boolean exitoso = true;
    
    @Column(name = "mensaje_error", columnDefinition = "TEXT")
    private String mensajeError;
    
    // ========== CONSTRUCTORES ==========
    
    public Auditoria() {
        this.fecha = LocalDateTime.now();
        this.exitoso = true;
        this.nivelSeveridad = "INFO";
    }
    
    // ========== GETTERS Y SETTERS ==========
    
    public Long getId() { 
        return id; 
    }
    
    public void setId(Long id) { 
        this.id = id; 
    }
    
    public String getUsuario() { 
        return usuario; 
    }
    
    public void setUsuario(String usuario) { 
        this.usuario = usuario; 
    }
    
    public String getAccion() { 
        return accion; 
    }
    
    public void setAccion(String accion) { 
        this.accion = accion; 
    }
    
    public String getDescripcion() { 
        return descripcion; 
    }
    
    public void setDescripcion(String descripcion) { 
        this.descripcion = descripcion; 
    }
    
    public String getTablaAfectada() { 
        return tablaAfectada; 
    }
    
    public void setTablaAfectada(String tablaAfectada) { 
        this.tablaAfectada = tablaAfectada; 
    }
    
    public Long getRegistroId() { 
        return registroId; 
    }
    
    public void setRegistroId(Long registroId) { 
        this.registroId = registroId; 
    }
    
    public String getDatosAnteriores() { 
        return datosAnteriores; 
    }
    
    public void setDatosAnteriores(String datosAnteriores) { 
        this.datosAnteriores = datosAnteriores; 
    }
    
    public String getDatosNuevos() { 
        return datosNuevos; 
    }
    
    public void setDatosNuevos(String datosNuevos) { 
        this.datosNuevos = datosNuevos; 
    }
    
    public String getIpOrigen() { 
        return ipOrigen; 
    }
    
    public void setIpOrigen(String ipOrigen) { 
        this.ipOrigen = ipOrigen; 
    }
    
    public String getUserAgent() { 
        return userAgent; 
    }
    
    public void setUserAgent(String userAgent) { 
        this.userAgent = userAgent; 
    }
    
    public LocalDateTime getFecha() { 
        return fecha; 
    }
    
    public void setFecha(LocalDateTime fecha) { 
        this.fecha = fecha; 
    }
    
    public String getNivelSeveridad() { 
        return nivelSeveridad; 
    }
    
    public void setNivelSeveridad(String nivelSeveridad) { 
        this.nivelSeveridad = nivelSeveridad; 
    }
    
    public Boolean getExitoso() { 
        return exitoso; 
    }
    
    public void setExitoso(Boolean exitoso) { 
        this.exitoso = exitoso; 
    }
    
    public String getMensajeError() { 
        return mensajeError; 
    }
    
    public void setMensajeError(String mensajeError) { 
        this.mensajeError = mensajeError; 
    }
    
    // ========== MÉTODOS ADICIONALES ==========
    
    @Override
    public String toString() {
        return "Auditoria{" +
                "id=" + id +
                ", usuario='" + usuario + '\'' +
                ", accion='" + accion + '\'' +
                ", fecha=" + fecha +
                ", exitoso=" + exitoso +
                '}';
    }
}