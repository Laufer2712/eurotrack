package com.eurotrack.backend.repository;

import com.eurotrack.backend.model.Auditoria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AuditoriaRepository extends JpaRepository<Auditoria, Long> {
    List<Auditoria> findByUsuario(String usuario);
    List<Auditoria> findByAccion(String accion);
    List<Auditoria> findByTablaAfectada(String tablaAfectada);
    
    // ✅ Buscar por fechas con LocalDateTime
    List<Auditoria> findByFechaBetween(LocalDateTime fechaInicio, LocalDateTime fechaFin);
    
    // ✅ Buscar por fechas usando String (con consulta personalizada)
    @Query("SELECT a FROM Auditoria a WHERE a.fecha BETWEEN :inicio AND :fin")
    List<Auditoria> buscarPorFechas(@Param("inicio") String inicio, @Param("fin") String fin);
    
   
}