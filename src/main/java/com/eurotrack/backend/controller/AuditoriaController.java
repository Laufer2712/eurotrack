package com.eurotrack.backend.controller;

import com.eurotrack.backend.model.Auditoria;
import com.eurotrack.backend.util.AuditoriaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/auditoria")
@CrossOrigin(origins = "*")
public class AuditoriaController {
    
    @Autowired
    private AuditoriaService auditoriaService;
    
    @GetMapping
    public ResponseEntity<List<Auditoria>> obtenerTodos() {
        return ResponseEntity.ok(auditoriaService.obtenerTodos());
    }
    
    @GetMapping("/usuario/{usuario}")
    public ResponseEntity<List<Auditoria>> obtenerPorUsuario(@PathVariable String usuario) {
        return ResponseEntity.ok(auditoriaService.obtenerPorUsuario(usuario));
    }
    
    @GetMapping("/accion/{accion}")
    public ResponseEntity<List<Auditoria>> obtenerPorAccion(@PathVariable String accion) {
        return ResponseEntity.ok(auditoriaService.obtenerPorAccion(accion));
    }
}