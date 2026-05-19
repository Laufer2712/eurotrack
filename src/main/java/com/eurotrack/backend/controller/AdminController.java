package com.eurotrack.backend.controller;

import com.eurotrack.backend.dto.CategoriaDTO;
import com.eurotrack.backend.dto.ProductoDTO;
import com.eurotrack.backend.model.Categoria;
import com.eurotrack.backend.model.Producto;
import com.eurotrack.backend.model.Usuario;
import com.eurotrack.backend.repository.CategoriaRepository;
import com.eurotrack.backend.repository.ProductoRepository;
import com.eurotrack.backend.repository.UsuarioRepository;
import com.eurotrack.backend.util.PasswordUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    @Autowired
    private UsuarioRepository usuarioRepository;
    
    @Autowired
    private ProductoRepository productoRepository;
    
    @Autowired
    private CategoriaRepository categoriaRepository;
    
    @Autowired
    private PasswordUtil passwordUtil;

    // ========== GESTIÓN DE USUARIOS ==========
    
    @GetMapping("/usuarios")
    public List<Usuario> getAllUsuarios() {
        List<Usuario> usuarios = usuarioRepository.findAll();
        usuarios.forEach(u -> u.setPassword(null));
        return usuarios;
    }
    
    @GetMapping("/usuarios/{id}")
    public ResponseEntity<?> getUsuarioById(@PathVariable Long id) {
        return usuarioRepository.findById(id)
                .map(usuario -> {
                    usuario.setPassword(null);
                    return ResponseEntity.ok(usuario);
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PostMapping("/usuarios")
    public ResponseEntity<?> createUsuario(@RequestBody Usuario nuevoUsuario) {
        if (usuarioRepository.findByEmail(nuevoUsuario.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("El email ya existe");
        }
        if (usuarioRepository.findByUsername(nuevoUsuario.getUsername()).isPresent()) {
            return ResponseEntity.badRequest().body("El username ya existe");
        }
        
        nuevoUsuario.setPassword(passwordUtil.encode(nuevoUsuario.getPassword()));
        nuevoUsuario.setActivo(true);
        Usuario saved = usuarioRepository.save(nuevoUsuario);
        saved.setPassword(null);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }
    
    @PutMapping("/usuarios/{id}")
    public ResponseEntity<?> updateUsuario(@PathVariable Long id, @RequestBody Usuario usuarioActualizado) {
        return usuarioRepository.findById(id).map(usuario -> {
            if (usuarioActualizado.getNombre() != null) usuario.setNombre(usuarioActualizado.getNombre());
            if (usuarioActualizado.getEmail() != null) usuario.setEmail(usuarioActualizado.getEmail());
            if (usuarioActualizado.getUsername() != null) usuario.setUsername(usuarioActualizado.getUsername());
            if (usuarioActualizado.getCedula() != null) usuario.setCedula(usuarioActualizado.getCedula());
            if (usuarioActualizado.getRol() != null) usuario.setRol(usuarioActualizado.getRol());
            if (usuarioActualizado.getTipoCliente() != null) usuario.setTipoCliente(usuarioActualizado.getTipoCliente());
            if (usuarioActualizado.getTelefono() != null) usuario.setTelefono(usuarioActualizado.getTelefono());
            if (usuarioActualizado.getPassword() != null && !usuarioActualizado.getPassword().isEmpty()) {
                usuario.setPassword(passwordUtil.encode(usuarioActualizado.getPassword()));
            }
            
            usuarioRepository.save(usuario);
            usuario.setPassword(null);
            return ResponseEntity.ok(usuario);
        }).orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/usuarios/{id}")
    public ResponseEntity<?> deleteUsuario(@PathVariable Long id) {
        if (!usuarioRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        usuarioRepository.deleteById(id);
        return ResponseEntity.ok().body("Usuario eliminado");
    }
    
    @PatchMapping("/usuarios/{id}/rol")
    public ResponseEntity<?> cambiarRol(@PathVariable Long id, @RequestBody Map<String, String> data, 
                                        @RequestHeader(value = "adminId", required = false) Long adminId) {
        return usuarioRepository.findById(id).map(usuario -> {
            String nuevoRol = data.get("rol");
            
            if (adminId != null && adminId.equals(id) && !nuevoRol.equals("ADMIN")) {
                return ResponseEntity.badRequest().body("No puedes cambiar tu propio rol de administrador");
            }
            
            usuario.setRol(nuevoRol);
            usuarioRepository.save(usuario);
            return ResponseEntity.ok().body("Rol actualizado a: " + nuevoRol);
        }).orElse(ResponseEntity.notFound().build());
    }
    
    @PatchMapping("/usuarios/{id}/toggle-activo")
    public ResponseEntity<?> toggleUsuarioActivo(@PathVariable Long id, @RequestHeader(value = "adminId", required = false) Long adminId) {
        return usuarioRepository.findById(id).map(usuario -> {
            if (adminId != null && adminId.equals(id)) {
                return ResponseEntity.badRequest().body("No puedes desactivar tu propia cuenta");
            }
            
            usuario.setActivo(!usuario.getActivo());
            usuarioRepository.save(usuario);
            String estado = usuario.getActivo() ? "activado" : "desactivado";
            return ResponseEntity.ok().body("Usuario " + estado);
        }).orElse(ResponseEntity.notFound().build());
    }
    
    // ========== GESTIÓN DE PRODUCTOS (ADMIN) con DTO ==========
    
    @GetMapping("/productos")
    public List<ProductoDTO> getAllProductos() {
        List<Producto> productos = productoRepository.findAll();
        return productos.stream()
            .map(ProductoDTO::new)
            .collect(Collectors.toList());
    }
    
    @PostMapping("/productos")
    public ResponseEntity<?> createProducto(@RequestBody Producto producto) {
        if (producto.getCategoria() != null && producto.getCategoria().getId() != null) {
            var categoria = categoriaRepository.findById(producto.getCategoria().getId());
            if (categoria.isEmpty()) {
                return ResponseEntity.badRequest().body("Categoría no existe");
            }
            producto.setCategoria(categoria.get());
        }
        
        if (producto.getPrecio() == null) producto.setPrecio(BigDecimal.ZERO);
        if (producto.getStock() == null) producto.setStock(0);
        if (producto.getActivo() == null) producto.setActivo(true);
        
        Producto saved = productoRepository.save(producto);
        return ResponseEntity.status(HttpStatus.CREATED).body(new ProductoDTO(saved));
    }
    
    @PutMapping("/productos/{id}")
    public ResponseEntity<?> updateProducto(@PathVariable Long id, @RequestBody Producto productoActualizado) {
        return productoRepository.findById(id).map(producto -> {
            if (productoActualizado.getNombre() != null) producto.setNombre(productoActualizado.getNombre());
            if (productoActualizado.getDescripcion() != null) producto.setDescripcion(productoActualizado.getDescripcion());
            if (productoActualizado.getCodigo() != null) producto.setCodigo(productoActualizado.getCodigo());
            if (productoActualizado.getNumeroParte() != null) producto.setNumeroParte(productoActualizado.getNumeroParte());
            if (productoActualizado.getMarca() != null) producto.setMarca(productoActualizado.getMarca());
            if (productoActualizado.getPrecio() != null) producto.setPrecio(productoActualizado.getPrecio());
            if (productoActualizado.getStock() != null) producto.setStock(productoActualizado.getStock());
            if (productoActualizado.getImagenUrl() != null) producto.setImagenUrl(productoActualizado.getImagenUrl());
            if (productoActualizado.getActivo() != null) producto.setActivo(productoActualizado.getActivo());
            
            if (productoActualizado.getCategoria() != null && productoActualizado.getCategoria().getId() != null) {
                var categoria = categoriaRepository.findById(productoActualizado.getCategoria().getId());
                categoria.ifPresent(producto::setCategoria);
            }
            
            return ResponseEntity.ok(new ProductoDTO(productoRepository.save(producto)));
        }).orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/productos/{id}")
    public ResponseEntity<?> deleteProducto(@PathVariable Long id) {
        if (!productoRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        productoRepository.deleteById(id);
        return ResponseEntity.ok().body("Producto eliminado");
    }
    
    @PatchMapping("/productos/{id}/toggle")
    public ResponseEntity<?> toggleProductoActivo(@PathVariable Long id) {
        return productoRepository.findById(id).map(producto -> {
            producto.setActivo(!producto.getActivo());
            productoRepository.save(producto);
            String estado = producto.getActivo() ? "activado" : "desactivado";
            return ResponseEntity.ok().body("Producto " + estado);
        }).orElse(ResponseEntity.notFound().build());
    }
    
    // ========== GESTIÓN DE CATEGORÍAS (ADMIN) con DTO ==========
    
    @GetMapping("/categorias")
    public List<CategoriaDTO> getCategorias() {
        List<Categoria> categorias = categoriaRepository.findAll();
        return categorias.stream()
            .map(CategoriaDTO::new)
            .collect(Collectors.toList());
    }
    
    @PostMapping("/categorias")
    public ResponseEntity<?> createCategoria(@RequestBody Categoria categoria) {
        if (categoriaRepository.findByNombre(categoria.getNombre()).isPresent()) {
            return ResponseEntity.badRequest().body("La categoría ya existe");
        }
        Categoria saved = categoriaRepository.save(categoria);
        return ResponseEntity.status(HttpStatus.CREATED).body(new CategoriaDTO(saved));
    }
    
    @PutMapping("/categorias/{id}")
    public ResponseEntity<?> updateCategoria(@PathVariable Long id, @RequestBody Categoria categoriaActualizada) {
        return categoriaRepository.findById(id).map(categoria -> {
            if (categoriaActualizada.getNombre() != null) categoria.setNombre(categoriaActualizada.getNombre());
            if (categoriaActualizada.getDescripcion() != null) categoria.setDescripcion(categoriaActualizada.getDescripcion());
            if (categoriaActualizada.getImagenUrl() != null) categoria.setImagenUrl(categoriaActualizada.getImagenUrl());
            return ResponseEntity.ok(new CategoriaDTO(categoriaRepository.save(categoria)));
        }).orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/categorias/{id}")
    public ResponseEntity<?> deleteCategoria(@PathVariable Long id) {
        if (!categoriaRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        categoriaRepository.deleteById(id);
        return ResponseEntity.ok().body("Categoría eliminada");
    }
    
    // ========== ESTADÍSTICAS ==========
    
    @GetMapping("/stats")
    public ResponseEntity<?> getStats() {
        Map<String, Object> stats = Map.of(
            "totalUsuarios", usuarioRepository.count(),
            "totalProductos", productoRepository.count(),
            "totalCategorias", categoriaRepository.count(),
            "productosActivos", productoRepository.findByActivoTrue().size()
        );
        return ResponseEntity.ok(stats);
    }
}