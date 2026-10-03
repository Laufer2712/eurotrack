package com.eurotrack.backend.controller;

import com.eurotrack.backend.dto.ProductoDTO;
import com.eurotrack.backend.model.Categoria;
import com.eurotrack.backend.model.Producto;
import com.eurotrack.backend.repository.CategoriaRepository;
import com.eurotrack.backend.repository.ProductoRepository;
import com.eurotrack.backend.util.AuditoriaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/productos")
@CrossOrigin(origins = "*")
public class ProductoController {

    @Autowired
    private ProductoRepository productoRepository;
    
    @Autowired
    private CategoriaRepository categoriaRepository;
    
    @Autowired
    private AuditoriaService auditoriaService;

    // ========== CATÁLOGO PÚBLICO ==========
    @GetMapping("/catalogo")
    public List<ProductoDTO> getCatalogo() {
        List<Producto> productos = productoRepository.findCatalogo();
        return productos.stream()
            .map(ProductoDTO::new)
            .collect(Collectors.toList());
    }
    
    @GetMapping("/catalogo/categoria/{categoriaId}")
    public List<ProductoDTO> getCatalogoByCategoria(@PathVariable Long categoriaId) {
        List<Producto> productos = productoRepository.findCatalogoByCategoria(categoriaId);
        return productos.stream()
            .map(ProductoDTO::new)
            .collect(Collectors.toList());
    }
    
    @GetMapping("/buscar")
    public List<ProductoDTO> buscar(@RequestParam String q) {
        List<Producto> productos = productoRepository.findByNombreContainingIgnoreCase(q);
        return productos.stream()
            .map(ProductoDTO::new)
            .collect(Collectors.toList());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ProductoDTO> getById(@PathVariable Long id) {
        return productoRepository.findById(id)
            .map(producto -> ResponseEntity.ok(new ProductoDTO(producto)))
            .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping
    public List<Producto> getAll() {
        return productoRepository.findAll();
    }

    // ========== ADMINISTRACIÓN ==========
    
    @PostMapping
    public ResponseEntity<?> create(@RequestBody Producto producto, 
                                   @RequestHeader(value = "X-User-Email", required = false) String usuarioEmail) {
        try {
            if (producto.getCategoria() != null && producto.getCategoria().getId() != null) {
                Optional<Categoria> categoriaOpt = categoriaRepository.findById(producto.getCategoria().getId());
                if (categoriaOpt.isEmpty()) {
                    auditoriaService.registrar(
                        usuarioEmail != null ? usuarioEmail : "ANONIMO",
                        "CREATE_PRODUCTO_ERROR",
                        "Intento de crear producto con categoría inexistente: " + producto.getNombre()
                    );
                    return ResponseEntity.badRequest().body("La categoría no existe");
                }
                producto.setCategoria(categoriaOpt.get());
            }
            
            Producto nuevoProducto = productoRepository.save(producto);
            
            auditoriaService.registrarConDatos(
                usuarioEmail != null ? usuarioEmail : "ANONIMO",
                "CREATE_PRODUCTO",
                "Producto creado: " + producto.getNombre(),
                "productos",
                nuevoProducto.getId(),
                null,
                nuevoProducto.toString(),
                true,
                null
            );
            
            return ResponseEntity.status(HttpStatus.CREATED).body(nuevoProducto);
        } catch (Exception e) {
            auditoriaService.registrar(
                usuarioEmail != null ? usuarioEmail : "ANONIMO",
                "CREATE_PRODUCTO_ERROR",
                "Error al crear producto: " + producto.getNombre() + " - " + e.getMessage()
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al crear el producto: " + e.getMessage());
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, 
                                   @RequestBody Producto productoActualizado,
                                   @RequestHeader(value = "X-User-Email", required = false) String usuarioEmail) {
        try {
            Optional<Producto> productoOpt = productoRepository.findById(id);
            
            if (productoOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            Producto producto = productoOpt.get();
            String datosAnteriores = producto.toString();
            
            producto.setNombre(productoActualizado.getNombre());
            producto.setDescripcion(productoActualizado.getDescripcion());
            producto.setCodigo(productoActualizado.getCodigo());
            producto.setNumeroParte(productoActualizado.getNumeroParte());
            producto.setMarca(productoActualizado.getMarca());
            producto.setPrecio(productoActualizado.getPrecio());
            producto.setStock(productoActualizado.getStock());
            producto.setImagenUrl(productoActualizado.getImagenUrl());
            producto.setActivo(productoActualizado.getActivo() != null ? productoActualizado.getActivo() : true);
            
            if (productoActualizado.getCategoria() != null && 
                productoActualizado.getCategoria().getId() != null) {
                Optional<Categoria> categoriaOpt = categoriaRepository.findById(
                    productoActualizado.getCategoria().getId()
                );
                if (categoriaOpt.isPresent()) {
                    producto.setCategoria(categoriaOpt.get());
                } else {
                    producto.setCategoria(null);
                }
            } else {
                producto.setCategoria(null);
            }
            
            Producto productoGuardado = productoRepository.save(producto);
            
            auditoriaService.registrarConDatos(
                usuarioEmail != null ? usuarioEmail : "ANONIMO",
                "UPDATE_PRODUCTO",
                "Producto actualizado ID: " + id,
                "productos",
                id,
                datosAnteriores,
                productoGuardado.toString(),
                true,
                null
            );
            
            return ResponseEntity.ok(productoGuardado);
            
        } catch (Exception e) {
            auditoriaService.registrar(
                usuarioEmail != null ? usuarioEmail : "ANONIMO",
                "UPDATE_PRODUCTO_ERROR",
                "Error al actualizar producto ID: " + id + " - " + e.getMessage()
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al actualizar el producto: " + e.getMessage());
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id,
                                   @RequestHeader(value = "X-User-Email", required = false) String usuarioEmail) {
        try {
            Optional<Producto> productoOpt = productoRepository.findById(id);
            
            if (productoOpt.isEmpty()) {
                auditoriaService.registrar(
                    usuarioEmail != null ? usuarioEmail : "ANONIMO",
                    "DELETE_PRODUCTO_ERROR",
                    "Intento de eliminar producto inexistente ID: " + id
                );
                return ResponseEntity.notFound().build();
            }
            
            Producto producto = productoOpt.get();
            String datosProducto = producto.toString();
            
            productoRepository.deleteById(id);
            
            auditoriaService.registrarConDatos(
                usuarioEmail != null ? usuarioEmail : "ANONIMO",
                "DELETE_PRODUCTO",
                "Producto eliminado ID: " + id,
                "productos",
                id,
                datosProducto,
                null,
                true,
                null
            );
            
            return ResponseEntity.ok().build();
            
        } catch (Exception e) {
            auditoriaService.registrar(
                usuarioEmail != null ? usuarioEmail : "ANONIMO",
                "DELETE_PRODUCTO_ERROR",
                "Error al eliminar producto ID: " + id + " - " + e.getMessage()
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al eliminar el producto: " + e.getMessage());
        }
    }
}