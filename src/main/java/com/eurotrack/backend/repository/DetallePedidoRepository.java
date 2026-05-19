package com.eurotrack.backend.repository;

import com.eurotrack.backend.model.DetallePedido;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface DetallePedidoRepository extends JpaRepository<DetallePedido, Long> {
    
    // Obtener todos los detalles de un pedido específico
    List<DetallePedido> findByPedidoId(Long pedidoId);
    
    // Obtener todos los detalles de un producto específico (para reportes)
    List<DetallePedido> findByProductoId(Long productoId);
    
    // Obtener detalles de un pedido con un producto específico
    List<DetallePedido> findByPedidoIdAndProductoId(Long pedidoId, Long productoId);
}