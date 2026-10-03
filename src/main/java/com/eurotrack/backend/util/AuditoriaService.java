package com.eurotrack.backend.util;

import com.eurotrack.backend.model.Auditoria;
import com.eurotrack.backend.repository.AuditoriaRepository;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class AuditoriaService {
    
    @Autowired
    private AuditoriaRepository auditoriaRepository;
    
    @Autowired(required = false)
    private HttpServletRequest request;
    
    // ========== MÉTODOS PARA REGISTRAR ==========
    
    /**
     * Registra una acción simple (3 parámetros)
     * ✅ CORREGIDO: Ahora solo usa el email/nombre del usuario
     */
    public void registrar(String usuario, String accion, String descripcion) {
        registrar(usuario, accion, descripcion, null, null);
    }
    
    /**
     * Registra una acción con tabla afectada (5 parámetros)
     * ✅ CORREGIDO: Ahora solo usa el email/nombre del usuario
     */
    public void registrar(String usuario, String accion, String descripcion, String tablaAfectada, Long registroId) {
        try {
            Auditoria auditoria = new Auditoria();
            auditoria.setUsuario(usuario != null ? usuario : "ANONIMO");
            auditoria.setAccion(accion);
            auditoria.setDescripcion(descripcion);
            auditoria.setTablaAfectada(tablaAfectada);
            auditoria.setRegistroId(registroId);
            auditoria.setIpOrigen(getClientIp());
            auditoria.setUserAgent(getUserAgent());
            auditoria.setFecha(LocalDateTime.now());
            auditoria.setNivelSeveridad("INFO");
            auditoria.setExitoso(true);
            auditoria.setDatosAnteriores(null);
            auditoria.setDatosNuevos(null);
            auditoria.setMensajeError(null);
            
            auditoriaRepository.save(auditoria);
            System.out.println("✅ Auditoría registrada: " + accion + " - " + usuario);
        } catch (Exception e) {
            System.err.println("❌ Error al registrar auditoría simple: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Registra una acción con todos los datos (9 parámetros)
     * ✅ CORREGIDO: Maneja correctamente todos los campos
     */
    public void registrar(String usuario, String accion, String descripcion,
                          String tablaAfectada, Long registroId,
                          String datosAnteriores, String datosNuevos,
                          Boolean exitoso, String mensajeError) {
        registrarConDatos(usuario, accion, descripcion, tablaAfectada, registroId, 
                         datosAnteriores, datosNuevos, exitoso, mensajeError);
    }
    
    /**
     * Registra una acción con todos los datos (versión completa)
     * ✅ CORREGIDO: Ahora maneja correctamente todos los campos sin depender de objetos complejos
     */
    public void registrarConDatos(String usuario, String accion, String descripcion, 
                                   String tablaAfectada, Long registroId,
                                   String datosAnteriores, String datosNuevos,
                                   Boolean exitoso, String mensajeError) {
        try {
            Auditoria auditoria = new Auditoria();
            auditoria.setUsuario(usuario != null ? usuario : "ANONIMO");
            auditoria.setAccion(accion != null ? accion : "DESCONOCIDO");
            auditoria.setDescripcion(descripcion != null ? descripcion : "Sin descripción");
            auditoria.setTablaAfectada(tablaAfectada);
            auditoria.setRegistroId(registroId);
            auditoria.setDatosAnteriores(datosAnteriores);
            auditoria.setDatosNuevos(datosNuevos);
            auditoria.setIpOrigen(getClientIp());
            auditoria.setUserAgent(getUserAgent());
            auditoria.setFecha(LocalDateTime.now());
            auditoria.setNivelSeveridad(exitoso != null && exitoso ? "INFO" : "ERROR");
            auditoria.setExitoso(exitoso != null ? exitoso : true);
            auditoria.setMensajeError(mensajeError);
            
            auditoriaRepository.save(auditoria);
            System.out.println("✅ Auditoría completa registrada: " + accion + " - " + usuario);
        } catch (Exception e) {
            System.err.println("❌ Error al registrar auditoría completa: " + e.getMessage());
            e.printStackTrace();
            // No lanzamos la excepción para no afectar la operación principal
        }
    }
    
    // ========== MÉTODOS AUXILIARES ==========
    
    private String getClientIp() {
        if (request == null) return "0.0.0.0";
        
        try {
            String ip = request.getHeader("X-Forwarded-For");
            if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
                ip = request.getHeader("Proxy-Client-IP");
            }
            if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
                ip = request.getHeader("WL-Proxy-Client-IP");
            }
            if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
                ip = request.getHeader("HTTP_CLIENT_IP");
            }
            if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
                ip = request.getHeader("HTTP_X_FORWARDED_FOR");
            }
            if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
                ip = request.getRemoteAddr();
            }
            // Si la IP es múltiple (por proxies), tomar la primera
            if (ip != null && ip.contains(",")) {
                ip = ip.split(",")[0].trim();
            }
            return ip != null ? ip : "0.0.0.0";
        } catch (Exception e) {
            return "0.0.0.0";
        }
    }
    
    private String getUserAgent() {
        if (request == null) return "Unknown";
        try {
            return request.getHeader("User-Agent") != null ? 
                   request.getHeader("User-Agent") : "Unknown";
        } catch (Exception e) {
            return "Unknown";
        }
    }
    
    // ========== MÉTODOS PARA CONSULTAR ==========
    
    public List<Auditoria> obtenerTodos() {
        try {
            return auditoriaRepository.findAll();
        } catch (Exception e) {
            System.err.println("❌ Error al obtener auditorías: " + e.getMessage());
            return List.of();
        }
    }
    
    public List<Auditoria> obtenerPorUsuario(String usuario) {
        try {
            return auditoriaRepository.findByUsuario(usuario);
        } catch (Exception e) {
            System.err.println("❌ Error al obtener auditorías por usuario: " + e.getMessage());
            return List.of();
        }
    }
    
    public List<Auditoria> obtenerPorAccion(String accion) {
        try {
            return auditoriaRepository.findByAccion(accion);
        } catch (Exception e) {
            System.err.println("❌ Error al obtener auditorías por acción: " + e.getMessage());
            return List.of();
        }
    }
    
    public List<Auditoria> obtenerPorFechas(LocalDateTime inicio, LocalDateTime fin) {
        try {
            return auditoriaRepository.findByFechaBetween(inicio, fin);
        } catch (Exception e) {
            System.err.println("❌ Error al obtener auditorías por fechas: " + e.getMessage());
            return List.of();
        }
    }
}