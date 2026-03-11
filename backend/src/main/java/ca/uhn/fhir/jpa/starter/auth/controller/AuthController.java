package ca.uhn.fhir.jpa.starter.auth.controller;

import ca.uhn.fhir.jpa.starter.auth.dto.JwtResponse;
import ca.uhn.fhir.jpa.starter.auth.dto.LoginRequest;
import ca.uhn.fhir.jpa.starter.auth.dto.SignupRequest;
import ca.uhn.fhir.jpa.starter.auth.model.User;
import ca.uhn.fhir.jpa.starter.auth.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Controller de Autenticación
 * Maneja las peticiones HTTP relacionadas con autenticación:
 * - POST /api/auth/login - Login de usuarios
 * - POST /api/auth/signup - Registro de nuevos usuarios
 * - POST /api/auth/create-admin - Creación de usuarios admin
 * - GET /api/auth/validate - Validación de tokens JWT
 */
@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthController {
    
    @Autowired
    private AuthService authService;
    
    /**
     * Endpoint de login
     * @param loginRequest credenciales del usuario (username y password)
     * @return ResponseEntity con JwtResponse si login exitoso, o error si falla
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        try {
            JwtResponse response = authService.login(loginRequest);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Login failed: " + e.getMessage()));
        }
    }
    
    /**
     * Endpoint de registro de nuevos usuarios
     * @param signupRequest datos del nuevo usuario
     * @return ResponseEntity con JwtResponse si registro exitoso, o error si falla
     */
    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody SignupRequest signupRequest) {
        try {
            JwtResponse response = authService.signup(signupRequest);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Signup failed: " + e.getMessage()));
        }
    }
    
    /**
     * Endpoint de creación de usuarios administradores
     * @param signupRequest datos del nuevo admin
     * @return ResponseEntity con JwtResponse si creación exitosa, o error si falla
     */
    @PostMapping("/create-admin")
    public ResponseEntity<?> createAdmin(@RequestBody SignupRequest signupRequest) {
        try {
            JwtResponse response = authService.createAdmin(signupRequest);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Admin creation failed: " + e.getMessage()));
        }
    }
    
    /**
     * Endpoint de validación de token JWT
     * @param authHeader header de autorización con el token Bearer
     * @return ResponseEntity con información del usuario si token válido, o error si inválido
     */
    @GetMapping("/validate")
    public ResponseEntity<?> validateToken(@RequestHeader("Authorization") String authHeader) {
        try {
            // Verificar formato del header
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(createErrorResponse("Invalid authorization header"));
            }
            
            // Extraer token
            String token = authHeader.substring(7);
            
            // Validar token usando el servicio
            if (!authService.validateToken(token)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(createErrorResponse("Invalid or expired token"));
            }
            
            // Obtener usuario del token
            User user = authService.getUserFromToken(token)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            // Crear respuesta con datos del usuario
            Map<String, Object> response = new HashMap<>();
            response.put("valid", true);
            response.put("username", user.getUsername());
            response.put("email", user.getEmail());
            response.put("roles", user.getRoles());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Token validation failed: " + e.getMessage()));
        }
    }
    
    /**
     * Crea un mapa de respuesta de error
     * @param message mensaje de error
     * @return Map con el mensaje de error
     */
    private Map<String, String> createErrorResponse(String message) {
        Map<String, String> error = new HashMap<>();
        error.put("error", message);
        return error;
    }
}
