
package com.eurotrack.backend.repository;
/**
 *
 * @author Laura Toro
 */
import com.eurotrack.backend.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    Optional<Usuario> findByEmail(String email);
    Optional<Usuario> findByUsername(String username);
    Optional<Usuario> findByCedula(String cedula);
}