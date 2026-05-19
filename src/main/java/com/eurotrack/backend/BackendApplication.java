package com.eurotrack.backend;

import com.eurotrack.backend.model.Categoria;
import com.eurotrack.backend.model.Producto;
import com.eurotrack.backend.model.Usuario;
import com.eurotrack.backend.repository.CategoriaRepository;
import com.eurotrack.backend.repository.ProductoRepository;
import com.eurotrack.backend.repository.UsuarioRepository;
import com.eurotrack.backend.util.PasswordUtil;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import java.math.BigDecimal;

@SpringBootApplication
public class BackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(BackendApplication.class, args);
    }

    @Bean
    CommandLineRunner init(UsuarioRepository usuarioRepository, 
                          CategoriaRepository categoriaRepository,
                          ProductoRepository productoRepository,
                          PasswordUtil passwordUtil) {
        return args -> {
            
            // ========== 1. CREAR USUARIO ADMIN ==========
            if (usuarioRepository.findByEmail("admin@eurotrack.com").isEmpty()) {
                Usuario admin = new Usuario();
                admin.setNombre("Admin Eurotrack");
                admin.setEmail("admin@eurotrack.com");
                admin.setUsername("admin");
                admin.setPassword(passwordUtil.encode("123456"));
                admin.setRol("ADMIN");
                usuarioRepository.save(admin);
                System.out.println("Usuario administrador creado");
            }
            
            // ========== 2. CREAR CATEGORÍAS (Tipos de camión) ==========
            if (categoriaRepository.count() == 0) {
                
                Categoria volvo = new Categoria();
                volvo.setNombre("Volvo");
                volvo.setDescripcion("Repuestos para camiones Volvo");
                categoriaRepository.save(volvo);
                
                Categoria scania = new Categoria();
                scania.setNombre("Scania");
                scania.setDescripcion("Repuestos para camiones Scania");
                categoriaRepository.save(scania);
                
                Categoria mercedes = new Categoria();
                mercedes.setNombre("Mercedes Benz");
                mercedes.setDescripcion("Repuestos para camiones Mercedes Benz");
                categoriaRepository.save(mercedes);
                
                Categoria international = new Categoria();
                international.setNombre("International");
                international.setDescripcion("Repuestos para camiones International");
                categoriaRepository.save(international);
                
                Categoria kenworth = new Categoria();
                kenworth.setNombre("Kenworth");
                kenworth.setDescripcion("Repuestos para camiones Kenworth");
                categoriaRepository.save(kenworth);
                
                System.out.println("5 categorías (tipos de camión) creadas");
                
                // ========== 3. CREAR PRODUCTOS (Repuestos de ejemplo) ==========
                
                // Productos para Volvo
                Producto filtroVolvo = new Producto();
                filtroVolvo.setNombre("Filtro de aceite");
                filtroVolvo.setDescripcion("Filtro de aceite original para Volvo FH12");
                filtroVolvo.setCodigo("VOL-FIL-001");
                filtroVolvo.setNumeroParte("VOE 123456");
                filtroVolvo.setMarca("Volvo Original");
                filtroVolvo.setPrecio(new BigDecimal("45.99"));
                filtroVolvo.setStock(15);
                filtroVolvo.setActivo(true);
                filtroVolvo.setCategoria(volvo);
                productoRepository.save(filtroVolvo);
                
                Producto frenoVolvo = new Producto();
                frenoVolvo.setNombre("Pastillas de freno");
                frenoVolvo.setDescripcion("Juego de pastillas de freno delanteras");
                frenoVolvo.setCodigo("VOL-FRE-002");
                frenoVolvo.setNumeroParte("VOE 789012");
                frenoVolvo.setMarca("Volvo Original");
                frenoVolvo.setPrecio(new BigDecimal("89.99"));
                frenoVolvo.setStock(8);
                frenoVolvo.setActivo(true);
                frenoVolvo.setCategoria(volvo);
                productoRepository.save(frenoVolvo);
                
                // Productos para Scania
                Producto filtroScania = new Producto();
                filtroScania.setNombre("Filtro de combustible");
                filtroScania.setDescripcion("Filtro de combustible para Scania R-Series");
                filtroScania.setCodigo("SCA-FIL-001");
                filtroScania.setNumeroParte("SCA 234567");
                filtroScania.setMarca("Scania Original");
                filtroScania.setPrecio(new BigDecimal("55.50"));
                filtroScania.setStock(12);
                filtroScania.setActivo(true);
                filtroScania.setCategoria(scania);
                productoRepository.save(filtroScania);
                
                Producto correaScania = new Producto();
                correaScania.setNombre("Correa de distribución");
                correaScania.setDescripcion("Correa de distribución para motor Scania DC13");
                correaScania.setCodigo("SCA-COR-002");
                correaScania.setNumeroParte("SCA 345678");
                correaScania.setMarca("Scania Original");
                correaScania.setPrecio(new BigDecimal("67.30"));
                correaScania.setStock(5);
                correaScania.setActivo(true);
                correaScania.setCategoria(scania);
                productoRepository.save(correaScania);
                
                // Productos para Mercedes
                Producto bombaMercedes = new Producto();
                bombaMercedes.setNombre("Bomba de agua");
                bombaMercedes.setDescripcion("Bomba de agua para Mercedes Actros");
                bombaMercedes.setCodigo("MER-BOM-001");
                bombaMercedes.setNumeroParte("MER 456789");
                bombaMercedes.setMarca("Mercedes Original");
                bombaMercedes.setPrecio(new BigDecimal("125.00"));
                bombaMercedes.setStock(3);
                bombaMercedes.setActivo(true);
                bombaMercedes.setCategoria(mercedes);
                productoRepository.save(bombaMercedes);
                
                Producto radiadorMercedes = new Producto();
                radiadorMercedes.setNombre("Radiador");
                radiadorMercedes.setDescripcion("Radiador completo para Mercedes Axor");
                radiadorMercedes.setCodigo("MER-RAD-002");
                radiadorMercedes.setNumeroParte("MER 567890");
                radiadorMercedes.setMarca("Mercedes Original");
                radiadorMercedes.setPrecio(new BigDecimal("299.99"));
                radiadorMercedes.setStock(2);
                radiadorMercedes.setActivo(true);
                radiadorMercedes.setCategoria(mercedes);
                productoRepository.save(radiadorMercedes);
                
                // Productos para International
                Producto alternadorInternational = new Producto();
                alternadorInternational.setNombre("Alternador");
                alternadorInternational.setDescripcion("Alternador 140A para International LT");
                alternadorInternational.setCodigo("INT-ALT-001");
                alternadorInternational.setNumeroParte("INT 678901");
                alternadorInternational.setMarca("International Original");
                alternadorInternational.setPrecio(new BigDecimal("189.50"));
                alternadorInternational.setStock(4);
                alternadorInternational.setActivo(true);
                alternadorInternational.setCategoria(international);
                productoRepository.save(alternadorInternational);
                
                // Productos para Kenworth
                Producto turboKenworth = new Producto();
                turboKenworth.setNombre("Turbo cargador");
                turboKenworth.setDescripcion("Turbo para Kenworth T680");
                turboKenworth.setCodigo("KEN-TUR-001");
                turboKenworth.setNumeroParte("KEN 789012");
                turboKenworth.setMarca("Kenworth Original");
                turboKenworth.setPrecio(new BigDecimal("450.00"));
                turboKenworth.setStock(1);
                turboKenworth.setActivo(true);
                turboKenworth.setCategoria(kenworth);
                productoRepository.save(turboKenworth);
                
                System.out.println("8 productos (repuestos) de ejemplo creados");
            }
            
            System.out.println("========================================");
            System.out.println("BASE DE DATOS INICIALIZADA COMPLETAMENTE");
            System.out.println("========================================");
            System.out.println("Categorías: " + categoriaRepository.count());
            System.out.println("Productos: " + productoRepository.count());
            System.out.println("Usuarios: " + usuarioRepository.count());
            System.out.println("========================================");
        };
    }
}