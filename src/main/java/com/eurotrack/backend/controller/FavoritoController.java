package com.eurotrack.backend.controller;

import com.eurotrack.backend.model.Favorito;
import com.eurotrack.backend.model.Producto;
import com.eurotrack.backend.repository.FavoritoRepository;
import com.eurotrack.backend.repository.ProductoRepository;
import com.eurotrack.backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
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

    // Obtener todos los favoritos de un usuario
    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<?> getFavoritosByUsuario(@PathVariable Long usuarioId) {
        if (!usuarioRepository.existsById(usuarioId)) {
            return ResponseEntity.notFound().build();
        }
        
        List<Favorito> favoritos = favoritoRepository.findByUsuarioId(usuarioId);
        List<Producto> productos = favoritos.stream()
                .map(Favorito::getProducto)
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(productos);
    }
    
    // Verificar si un producto está en favoritos
    @GetMapping("/check")
    public ResponseEntity<?> checkFavorito(@RequestParam Long usuarioId, @RequestParam Long productoId) {
        boolean existe = favoritoRepository.existsByUsuarioIdAndProductoId(usuarioId, productoId);
        Map<String, Boolean> response = new HashMap<>();
        response.put("esFavorito", existe);
        return ResponseEntity.ok(response);
    }
    
    // Agregar a favoritos
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
    
    // Eliminar de favoritos
    @DeleteMapping("/eliminar")
    public ResponseEntity<?> eliminarFavorito(@RequestParam Long usuarioId, @RequestParam Long productoId) {
        if (!favoritoRepository.existsByUsuarioIdAndProductoId(usuarioId, productoId)) {
            return ResponseEntity.badRequest().body("No está en favoritos");
        }
        
        favoritoRepository.deleteByUsuarioIdAndProductoId(usuarioId, productoId);
        
        return ResponseEntity.ok().body("Eliminado de favoritos");
    }
    
    // Alternar favorito (toggle)
    @PostMapping("/toggle")
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