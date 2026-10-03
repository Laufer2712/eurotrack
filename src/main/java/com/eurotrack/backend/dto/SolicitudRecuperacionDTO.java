package com.eurotrack.backend.dto;

public class SolicitudRecuperacionDTO {
    private String email;
    private String cedula;
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getCedula() { return cedula; }
    public void setCedula(String cedula) { this.cedula = cedula; }
}