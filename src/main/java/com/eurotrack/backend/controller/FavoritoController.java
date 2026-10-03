package com.eurotrack.backend.controller;

import com.eurotrack.backend.dto.FavoritoDTO;
import com.eurotrack.backend.model.Favorito;
import com.eurotrack.backend.repository.FavoritoRepository;
import com.eurotrack.backend.repository.ProductoRepository;
import com.eurotrack.backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;  // ✅ Importar
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/favoritos")
@CrossOrigin(origins = "*")
public class FavoritoController {

    @Autowired
    private FavoritoRepository favoritoRepository;
    
    @Autowired
    private UsuarioRepository usuarioRepository;
    
    @Autowired
    private ProductoRepository productoRepository;

    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<?> getFavoritosByUsuario(@PathVariable Long usuarioId) {
        if (!usuarioRepository.existsById(usuarioId)) {
            return ResponseEntity.notFound().build();
        }
        
        List<Favorito> favoritos = favoritoRepository.findByUsuarioId(usuarioId);
        List<FavoritoDTO> favoritosDTO = favoritos.stream()
            .map(FavoritoDTO::new)
            .collect(Collectors.toList());
        
        return ResponseEntity.ok(favoritosDTO);
    }
    
    @GetMapping("/check")
    public ResponseEntity<?> checkFavorito(@RequestParam Long usuarioId, @RequestParam Long productoId) {
        boolean existe = favoritoRepository.existsByUsuarioIdAndProductoId(usuarioId, productoId);
        Map<String, Boolean> response = new HashMap<>();
        response.put("esFavorito", existe);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/agregar")
    public ResponseEntity<?> agregarFavorito(@RequestBody Map<String, Long> data) {
        Long usuarioId = data.get("usuarioId");
        Long productoId = data.get("productoId");
        
        if (!usuarioRepository.existsById(usuarioId)) {
            return ResponseEntity.badRequest().body("Usuario no existe");
        }
        
        if (!productoRepository.existsById(productoId)) {
            return ResponseEntity.badRequest().body("Producto no existe");
        }
        
        if (favoritoRepository.existsByUsuarioIdAndProductoId(usuarioId, productoId)) {
            return ResponseEntity.badRequest().body("Ya está en favoritos");
        }
        
        Favorito favorito = new Favorito();
        favorito.setUsuario(usuarioRepository.findById(usuarioId).get());
        favorito.setProducto(productoRepository.findById(productoId).get());
        
        favoritoRepository.save(favorito);
        
        return ResponseEntity.ok().body("Agregado a favoritos");
    }
    
    @DeleteMapping("/eliminar")
    public ResponseEntity<?> eliminarFavorito(@RequestParam Long usuarioId, @RequestParam Long productoId) {
        if (!favoritoRepository.existsByUsuarioIdAndProductoId(usuarioId, productoId)) {
            return ResponseEntity.badRequest().body("No está en favoritos");
        }
        
        favoritoRepository.deleteByUsuarioIdAndProductoId(usuarioId, productoId);
        
        return ResponseEntity.ok().body("Eliminado de favoritos");
    }
    
    // ✅ AGREGAR @Transactional
    @PostMapping("/toggle")
    @Transactional  // ← Esta es la solución
    public ResponseEntity<?> toggleFavorito(@RequestBody Map<String, Long> data) {
        Long usuarioId = data.get("usuarioId");
        Long productoId = data.get("productoId");
        
        if (!usuarioRepository.existsById(usuarioId)) {
            return ResponseEntity.badRequest().body("Usuario no existe");
        }
        
        if (!productoRepository.existsById(productoId)) {
            return ResponseEntity.badRequest().body("Producto no existe");
        }
        
        boolean existe = favoritoRepository.existsByUsuarioIdAndProductoId(usuarioId, productoId);
        
        if (existe) {
            favoritoRepository.deleteByUsuarioIdAndProductoId(usuarioId, productoId);
            return ResponseEntity.ok().body("Eliminado de favoritos");
        } else {
            Favorito favorito = new Favorito();
            favorito.setUsuario(usuarioRepository.findById(usuarioId).get());
            favorito.setProducto(productoRepository.findById(productoId).get());
            favoritoRepository.save(favorito);
            return ResponseEntity.ok().body("Agregado a favoritos");
        }
    }
}