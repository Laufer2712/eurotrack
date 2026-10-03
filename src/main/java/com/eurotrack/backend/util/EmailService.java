package com.eurotrack.backend.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;

@Service
public class EmailService {
    
    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);
    
    @Autowired
    private JavaMailSender mailSender;
    
    @Value("${app.url:http://localhost:8090}")
    private String appUrl;
    
    // ✅ Caracteres permitidos (excluye O, 0, I, 1 para evitar confusiones)
    private static final String CHARACTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final int CODE_LENGTH = 8;
    private static final SecureRandom random = new SecureRandom();
    
   /**
 * Genera un código corto de 8 caracteres
 */
private String generarCodigoCorto() {
    String CHARACTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    int CODE_LENGTH = 8;
    SecureRandom random = new SecureRandom();
    
    StringBuilder sb = new StringBuilder(CODE_LENGTH);
    for (int i = 0; i < CODE_LENGTH; i++) {
        sb.append(CHARACTERS.charAt(random.nextInt(CHARACTERS.length())));
    }
    return sb.toString();
}
    /**
     * Formatea el código en grupos de 4 (ej: 4A2B-8C1D)
     */
    private String formatearCodigo(String codigo) {
        if (codigo.length() < 8) {
            return codigo;
        }
        return codigo.substring(0, 4) + "-" + codigo.substring(4, 8);
    }
    
  public void enviarCodigoRecuperacion(String emailDestino, String codigo) {
    try {
        // 🔥 LOG: Mostrar el código recibido
        System.out.println("📧 EMAIL SERVICE RECIBE: " + codigo);
        
        // Formatear el código
        String codigoFormateado = codigo.substring(0, 4) + "-" + codigo.substring(4, 8);
        
        // 🔥 LOG: Mostrar el código formateado
        System.out.println("📧 CÓDIGO FORMATEADO: " + codigoFormateado);
        
        SimpleMailMessage mensaje = new SimpleMailMessage();
        mensaje.setTo(emailDestino);
        mensaje.setSubject("🔐 Código de recuperación - EuroTrack");
        mensaje.setText(
            "Hola,\n\n" +
            "Has solicitado restablecer tu contraseña en EuroTrack.\n\n" +
            "📋 Tu código de verificación es:\n" +
            "━━━━━━━━━━━━━━━━━━━━━━━━\n" +
            "  " + codigoFormateado + "\n" +
            "━━━━━━━━━━━━━━━━━━━━━━━━\n\n" +
            "⏰ Este código expirará en 15 minutos.\n\n" +
            "🔒 No compartas este código con nadie.\n\n" +
            "Saludos,\n" +
            "Equipo EuroTrack"
        );
        mailSender.send(mensaje);
        System.out.println("✅ CORREO ENVIADO a: " + emailDestino);
        
    } catch (Exception e) {
        System.err.println("❌ Error: " + e.getMessage());
        e.printStackTrace();
        throw new RuntimeException("Error al enviar el código de recuperación", e);
    }
}
}