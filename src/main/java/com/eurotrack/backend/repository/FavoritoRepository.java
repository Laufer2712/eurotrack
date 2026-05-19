// FavoritoRepository
package com.eurotrack.backend.repository;

import com.eurotrack.backend.model.Favorito;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface FavoritoRepository extends JpaRepository<Favorito, Long> {
    List<Favorito> findByUsuarioId(Long usuarioId);
    Optional<Favorito> findByUsuarioIdAndProductoId(Long usuarioId, Long productoId);
    boolean existsByUsuarioIdAndProductoId(Long usuarioId, Long productoId);
    void deleteByUsuarioIdAndProductoId(Long usuarioId, Long productoId);
}