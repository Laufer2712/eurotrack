package com.eurotrack.backend.repository;

import com.eurotrack.backend.model.Producto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ProductoRepository extends JpaRepository<Producto, Long> {
    List<Producto> findByCategoriaId(Long categoriaId);
    List<Producto> findByActivoTrue();
    List<Producto> findByNombreContainingIgnoreCase(String nombre);
    List<Producto> findByMarcaContainingIgnoreCase(String marca);
    List<Producto> findByNumeroParteContainingIgnoreCase(String numeroParte);
    
    @Query("SELECT p FROM Producto p WHERE p.activo = true ORDER BY p.nombre ASC")
    List<Producto> findCatalogo();
    
    @Query("SELECT p FROM Producto p WHERE p.activo = true AND p.categoria.id = :categoriaId")
    List<Producto> findCatalogoByCategoria(@Param("categoriaId") Long categoriaId);
}