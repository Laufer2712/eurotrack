package com.eurotrack.backend.controller;

import com.eurotrack.backend.dto.DetallePedidoDTO;
import com.eurotrack.backend.model.DetallePedido;
import com.eurotrack.backend.repository.DetallePedidoRepository;
import com.eurotrack.backend.repository.PedidoRepository;
import com.eurotrack.backend.repository.ProductoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/detalles-pedido")
@CrossOrigin(origins = "*")
public class DetallePedidoController {

    @Autowired
    private DetallePedidoRepository detallePedidoRepository;
    
    @Autowired
    private PedidoRepository pedidoRepository;
    
    @Autowired
    private ProductoRepository productoRepository;

    // 🔥 MODIFICADO: Devuelve DTOs
    @GetMapping("/pedido/{pedidoId}")
    public ResponseEntity<?> getDetallesByPedido(@PathVariable Long pedidoId) {
        if (!pedidoRepository.existsById(pedidoId)) {
            return ResponseEntity.notFound().build();
        }
        List<DetallePedido> detalles = detallePedidoRepository.findByPedidoId(pedidoId);
        List<DetallePedidoDTO> detallesDTO = detalles.stream()
            .map(DetallePedidoDTO::new)
            .collect(Collectors.toList());
        return ResponseEntity.ok(detallesDTO);
    }

    // 🔥 MODIFICADO: Devuelve DTO
    @GetMapping("/{id}")
    public ResponseEntity<?> getDetalleById(@PathVariable Long id) {
        return detallePedidoRepository.findById(id)
                .map(detalle -> ResponseEntity.ok(new DetallePedidoDTO(detalle)))
                .orElse(ResponseEntity.notFound().build());
    }

    // 🔥 MODIFICADO: Devuelve DTOs
    @GetMapping("/producto/{productoId}")
    public ResponseEntity<?> getDetallesByProducto(@PathVariable Long productoId) {
        if (!productoRepository.existsById(productoId)) {
            return ResponseEntity.notFound().build();
        }
        List<DetallePedido> detalles = detallePedidoRepository.findByProductoId(productoId);
        List<DetallePedidoDTO> detallesDTO = detalles.stream()
            .map(DetallePedidoDTO::new)
            .collect(Collectors.toList());
        return ResponseEntity.ok(detallesDTO);
    }

    // 🔥 MODIFICADO: Devuelve DTOs
    @GetMapping("/buscar")
    public ResponseEntity<?> getDetalleByPedidoAndProducto(
            @RequestParam Long pedidoId,
            @RequestParam Long productoId) {
        
        List<DetallePedido> detalles = detallePedidoRepository.findByPedidoIdAndProductoId(pedidoId, productoId);
        List<DetallePedidoDTO> detallesDTO = detalles.stream()
            .map(DetallePedidoDTO::new)
            .collect(Collectors.toList());
        return ResponseEntity.ok(detallesDTO);
    }

    // Actualizar cantidad de un detalle (sin cambios - es operación de administración)
    @PatchMapping("/{id}/cantidad")
    public ResponseEntity<?> updateCantidad(@PathVariable Long id, @RequestBody Map<String, Integer> data) {
        return detallePedidoRepository.findById(id).map(detalle -> {
            Integer nuevaCantidad = data.get("cantidad");
            if (nuevaCantidad == null || nuevaCantidad <= 0) {
                return ResponseEntity.badRequest().body("Cantidad inválida");
            }
            
            double nuevoSubtotal = detalle.getPrecioUnitario() * nuevaCantidad;
            detalle.setCantidad(nuevaCantidad);
            detalle.setSubtotal(nuevoSubtotal);
            
            detallePedidoRepository.save(detalle);
            
            // Actualizar el total del pedido
            var pedido = detalle.getPedido();
            double nuevoTotal = detallePedidoRepository.findByPedidoId(pedido.getId())
                    .stream()
                    .mapToDouble(DetallePedido::getSubtotal)
                    .sum();
            pedido.setTotal(nuevoTotal);
            pedidoRepository.save(pedido);
            
            return ResponseEntity.ok(new DetallePedidoDTO(detalle));
        }).orElse(ResponseEntity.notFound().build());
    }

    // Eliminar un detalle (sin cambios - es operación de administración)
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteDetalle(@PathVariable Long id) {
        return detallePedidoRepository.findById(id).map(detalle -> {
            Long pedidoId = detalle.getPedido().getId();
            detallePedidoRepository.deleteById(id);
            
            // Actualizar el total del pedido
            double nuevoTotal = detallePedidoRepository.findByPedidoId(pedidoId)
                    .stream()
                    .mapToDouble(DetallePedido::getSubtotal)
                    .sum();
            
            var pedido = pedidoRepository.findById(pedidoId).orElse(null);
            if (pedido != null) {
                pedido.setTotal(nuevoTotal);
                pedidoRepository.save(pedido);
            }
            
            return ResponseEntity.ok().body("Detalle eliminado");
        }).orElse(ResponseEntity.notFound().build());
    }
}