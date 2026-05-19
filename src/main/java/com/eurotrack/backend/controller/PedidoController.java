package com.eurotrack.backend.controller;

import com.eurotrack.backend.model.DetallePedido;
import com.eurotrack.backend.model.Pedido;
import com.eurotrack.backend.model.Producto;
import com.eurotrack.backend.repository.DetallePedidoRepository;
import com.eurotrack.backend.repository.PedidoRepository;
import com.eurotrack.backend.repository.ProductoRepository;
import com.eurotrack.backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/pedidos")
@CrossOrigin(origins = "*")
public class PedidoController {

    @Autowired
    private PedidoRepository pedidoRepository;
    
    @Autowired
    private DetallePedidoRepository detallePedidoRepository;
    
    @Autowired
    private ProductoRepository productoRepository;
    
    @Autowired
    private UsuarioRepository usuarioRepository;

    // ========== CLIENTE ==========
    
    // Obtener todos los pedidos de un usuario
    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<?> getPedidosByUsuario(@PathVariable Long usuarioId) {
        if (!usuarioRepository.existsById(usuarioId)) {
            return ResponseEntity.notFound().build();
        }
        List<Pedido> pedidos = pedidoRepository.findByUsuarioId(usuarioId);
        return ResponseEntity.ok(pedidos);
    }
    
    // Crear un nuevo pedido
    @PostMapping("/crear")
    public ResponseEntity<?> crearPedido(@RequestBody Map<String, Object> pedidoData) {
        try {
            Long usuarioId = ((Number) pedidoData.get("usuarioId")).longValue();
            String direccionEntrega = (String) pedidoData.get("direccionEntrega");
            String metodoPago = (String) pedidoData.get("metodoPago");
            List<Map<String, Object>> items = (List<Map<String, Object>>) pedidoData.get("items");
            
            var usuarioOpt = usuarioRepository.findById(usuarioId);
            if (usuarioOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("Usuario no encontrado");
            }
            
            // Crear pedido
            Pedido pedido = new Pedido();
            pedido.setUsuario(usuarioOpt.get());
            pedido.setFecha(LocalDateTime.now());
            pedido.setEstado("PENDIENTE");
            pedido.setDireccionEntrega(direccionEntrega);
            pedido.setMetodoPago(metodoPago);
            
            double total = 0.0;
            Pedido pedidoGuardado = pedidoRepository.save(pedido);
            
            // Crear detalles del pedido
            for (Map<String, Object> item : items) {
                Long productoId = ((Number) item.get("productoId")).longValue();
                Integer cantidad = (Integer) item.get("cantidad");
                
                var productoOpt = productoRepository.findById(productoId);
                if (productoOpt.isEmpty()) {
                    continue;
                }
                
                Producto producto = productoOpt.get();
                double subtotal = producto.getPrecio().doubleValue() * cantidad;
                total += subtotal;
                
                DetallePedido detalle = new DetallePedido();
                detalle.setPedido(pedidoGuardado);
                detalle.setProducto(producto);
                detalle.setCantidad(cantidad);
                detalle.setPrecioUnitario(producto.getPrecio().doubleValue());
                detalle.setSubtotal(subtotal);
                
                detallePedidoRepository.save(detalle);
                
                // Actualizar stock
                producto.setStock(producto.getStock() - cantidad);
                productoRepository.save(producto);
            }
            
            pedidoGuardado.setTotal(total);
            pedidoRepository.save(pedidoGuardado);
            
            Map<String, Object> response = new HashMap<>();
            response.put("mensaje", "Pedido creado exitosamente");
            response.put("pedidoId", pedidoGuardado.getId());
            response.put("total", total);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al crear pedido: " + e.getMessage());
        }
    }
    
    // Obtener detalle de un pedido específico
    @GetMapping("/{pedidoId}")
    public ResponseEntity<?> getPedidoDetalle(@PathVariable Long pedidoId) {
        var pedidoOpt = pedidoRepository.findById(pedidoId);
        if (pedidoOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        Pedido pedido = pedidoOpt.get();
        List<DetallePedido> detalles = detallePedidoRepository.findByPedidoId(pedidoId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("pedido", pedido);
        response.put("detalles", detalles);
        
        return ResponseEntity.ok(response);
    }
    
    // Cancelar pedido (solo si está pendiente)
    @PutMapping("/cancelar/{pedidoId}")
    public ResponseEntity<?> cancelarPedido(@PathVariable Long pedidoId) {
        var pedidoOpt = pedidoRepository.findById(pedidoId);
        if (pedidoOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        Pedido pedido = pedidoOpt.get();
        if (!"PENDIENTE".equals(pedido.getEstado())) {
            return ResponseEntity.badRequest().body("Solo se pueden cancelar pedidos pendientes");
        }
        
        pedido.setEstado("CANCELADO");
        pedidoRepository.save(pedido);
        
        return ResponseEntity.ok().body("Pedido cancelado exitosamente");
    }
    
    // ========== ADMIN ==========
    
    // Obtener todos los pedidos (admin)
    @GetMapping("/admin/todos")
    public List<Pedido> getAllPedidos() {
        return pedidoRepository.findAll();
    }
    
    // Actualizar estado del pedido (admin)
    @PutMapping("/admin/estado/{pedidoId}")
    public ResponseEntity<?> actualizarEstado(@PathVariable Long pedidoId, @RequestBody Map<String, String> data) {
        var pedidoOpt = pedidoRepository.findById(pedidoId);
        if (pedidoOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        Pedido pedido = pedidoOpt.get();
        String nuevoEstado = data.get("estado");
        
        // Estados válidos: PENDIENTE, PAGADO, ENVIADO, ENTREGADO, CANCELADO
        pedido.setEstado(nuevoEstado);
        pedidoRepository.save(pedido);
        
        return ResponseEntity.ok().body("Estado actualizado a: " + nuevoEstado);
    }
}