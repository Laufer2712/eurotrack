package com.eurotrack.backend;

import com.eurotrack.backend.repository.CategoriaRepository;
import com.eurotrack.backend.repository.ProductoRepository;
import com.eurotrack.backend.repository.UsuarioRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class BackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(BackendApplication.class, args);
    }

    @Bean
    CommandLineRunner init(UsuarioRepository usuarioRepository,
                          CategoriaRepository categoriaRepository,
                          ProductoRepository productoRepository) {
        return args -> {
            // ✅ Solo mostramos el estado de la base de datos, sin crear nada
            System.out.println("========================================");
            System.out.println("📊 ESTADO DE LA BASE DE DATOS");
            System.out.println("========================================");
            System.out.println("📊 Usuarios: " + usuarioRepository.count());
            System.out.println("📊 Categorías: " + categoriaRepository.count());
            System.out.println("📊 Productos: " + productoRepository.count());
            System.out.println("========================================");
            System.out.println("✅ Backend iniciado correctamente");
        };
    }
}