package com.eurotrack.backend.dto;

public class RestablecerPasswordDTO {
    private String token;
    private String nuevaPassword;
    
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    
    public String getNuevaPassword() { return nuevaPassword; }
    public void setNuevaPassword(String nuevaPassword) { this.nuevaPassword = nuevaPassword; }
}