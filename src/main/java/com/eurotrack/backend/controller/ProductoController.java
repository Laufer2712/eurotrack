package com.eurotrack.backend.controller;

import com.eurotrack.backend.model.Producto;
import com.eurotrack.backend.repository.CategoriaRepository;
import com.eurotrack.backend.repository.ProductoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/productos")
@CrossOrigin(origins = "*")
public class ProductoController {

    @Autowired
    private ProductoRepository productoRepository;
    
    @Autowired
    private CategoriaRepository categoriaRepository;

    // ========== ADMINISTRACIÓN ==========
    
    @GetMapping
    public List<Producto> getAll() {
        return productoRepository.findAll();
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Producto> getById(@PathVariable Long id) {
        return productoRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    public ResponseEntity<?> create(@RequestBody Producto producto) {
        if (producto.getCategoria() != null && producto.getCategoria().getId() != null) {
            var categoria = categoriaRepository.findById(producto.getCategoria().getId());
            if (categoria.isEmpty()) {
                return ResponseEntity.badRequest().body("La categoría no existe");
            }
            producto.setCategoria(categoria.get());
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(productoRepository.save(producto));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Producto productoActualizado) {
        return productoRepository.findById(id).map(producto -> {
            producto.setNombre(productoActualizado.getNombre());
            producto.setDescripcion(productoActualizado.getDescripcion());
            producto.setCodigo(productoActualizado.getCodigo());
            producto.setNumeroParte(productoActualizado.getNumeroParte());
            producto.setMarca(productoActualizado.getMarca());
            producto.setPrecio(productoActualizado.getPrecio());
            producto.setStock(productoActualizado.getStock());
            producto.setImagenUrl(productoActualizado.getImagenUrl());
            producto.setActivo(productoActualizado.getActivo());
            
            if (productoActualizado.getCategoria() != null && productoActualizado.getCategoria().getId() != null) {
                var categoria = categoriaRepository.findById(productoActualizado.getCategoria().getId());
                categoria.ifPresent(producto::setCategoria);
            }
            return ResponseEntity.ok(productoRepository.save(producto));
        }).orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        if (!productoRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        productoRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }
    
    // ========== CATÁLOGO (para la app) ==========
    
    @GetMapping("/catalogo")
    public List<Producto> getCatalogo() {
        return productoRepository.findCatalogo();
    }
    
    @GetMapping("/catalogo/categoria/{categoriaId}")
    public List<Producto> getCatalogoByCategoria(@PathVariable Long categoriaId) {
        return productoRepository.findCatalogoByCategoria(categoriaId);
    }
    
    @GetMapping("/buscar")
    public List<Producto> buscar(@RequestParam String q) {
        return productoRepository.findByNombreContainingIgnoreCase(q);
    }
    
    @GetMapping("/buscar/marca")
    public List<Producto> buscarPorMarca(@RequestParam String marca) {
        return productoRepository.findByMarcaContainingIgnoreCase(marca);
    }
    
    @GetMapping("/categoria/{categoriaId}")
    public List<Producto> getByCategoria(@PathVariable Long categoriaId) {
        return productoRepository.findByCategoriaId(categoriaId);
    }
}