package ca.uhn.fhir.jpa.starter.auth.controller;

import ca.uhn.fhir.jpa.starter.auth.dto.UserResponse;
import ca.uhn.fhir.jpa.starter.auth.model.Role;
import ca.uhn.fhir.jpa.starter.auth.model.User;
import ca.uhn.fhir.jpa.starter.auth.service.AuthService;
import ca.uhn.fhir.jpa.starter.auth.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller de Gestión de Usuarios
 * Maneja las peticiones HTTP relacionadas con operaciones de usuarios:
 * - GET /api/users - Listar todos los usuarios (solo admin)
 * - GET /api/users/{id} - Obtener un usuario por ID (solo admin)
 * - DELETE /api/users/{id} - Eliminar un usuario (solo admin)
 * - PUT /api/users/{id}/toggle-status - Habilitar/deshabilitar usuario (solo admin)
 */
@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*", maxAge = 3600)
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private AuthService authService;
    
    /**
     * Obtiene todos los usuarios del sistema
     * Requiere permisos de administrador
     * @param authHeader header de autorización con token Bearer
     * @return Lista de usuarios o error si no tiene permisos
     */
    @GetMapping
    public ResponseEntity<?> getAllUsers(@RequestHeader("Authorization") String authHeader) {
        try {
            // Validar token y verificar que es admin
            if (!isAdmin(authHeader)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(createErrorResponse("Access denied. Admin privileges required."));
            }
            
            List<UserResponse> users = userService.getAllUsers();
            return ResponseEntity.ok(users);
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Failed to retrieve users: " + e.getMessage()));
        }
    }
    
    /**
     * Obtiene un usuario específico por su ID
     * Requiere permisos de administrador
     * @param id ID del usuario
     * @param authHeader header de autorización con token Bearer
     * @return Usuario encontrado o error si no existe o no tiene permisos
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getUserById(@PathVariable("id") Long id, @RequestHeader("Authorization") String authHeader) {
        try {
            // Validar token y verificar que es admin
            if (!isAdmin(authHeader)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(createErrorResponse("Access denied. Admin privileges required."));
            }
            
            UserResponse user = userService.getUserById(id)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            return ResponseEntity.ok(user);
            
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Failed to retrieve user: " + e.getMessage()));
        }
    }
    
    /**
     * Elimina un usuario del sistema
     * Requiere permisos de administrador
     * No permite eliminar la propia cuenta del admin
     * @param id ID del usuario a eliminar
     * @param authHeader header de autorización con token Bearer
     * @return Confirmación de eliminación o error
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable("id") Long id, @RequestHeader("Authorization") String authHeader) {
        try {
            // Validar token y verificar que es admin
            if (!isAdmin(authHeader)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(createErrorResponse("Access denied. Admin privileges required."));
            }
            
            // Obtener el usuario a eliminar
            UserResponse userToDelete = userService.getUserById(id)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            // No permitir eliminar al propio usuario admin
            String currentUsername = getUsernameFromToken(authHeader);
            if (userToDelete.getUsername().equals(currentUsername)) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse("Cannot delete your own account"));
            }
            
            // Eliminar usuario
            userService.deleteUser(id);
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "User deleted successfully");
            response.put("userId", id);
            response.put("username", userToDelete.getUsername());
            
            return ResponseEntity.ok(response);
            
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Failed to delete user: " + e.getMessage()));
        }
    }
    
    /**
     * Cambia el estado (habilitado/deshabilitado) de un usuario
     * Requiere permisos de administrador
     * No permite modificar la propia cuenta del admin
     * @param id ID del usuario
     * @param authHeader header de autorización con token Bearer
     * @return Usuario actualizado o error
     */
    @PutMapping("/{id}/toggle-status")
    public ResponseEntity<?> toggleUserStatus(@PathVariable("id") Long id, @RequestHeader("Authorization") String authHeader) {
        try {
            // Validar token y verificar que es admin
            if (!isAdmin(authHeader)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(createErrorResponse("Access denied. Admin privileges required."));
            }
            
            // Obtener el usuario antes de modificar
            UserResponse userToModify = userService.getUserById(id)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            // No permitir desactivar al propio usuario admin
            String currentUsername = getUsernameFromToken(authHeader);
            if (userToModify.getUsername().equals(currentUsername)) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse("Cannot modify your own account status"));
            }
            
            // Cambiar estado
            UserResponse updatedUser = userService.toggleUserStatus(id);
            
            return ResponseEntity.ok(updatedUser);
            
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Failed to update user status: " + e.getMessage()));
        }
    }
    
    /**
     * Verifica si el usuario del token tiene permisos de administrador
     * @param authHeader header de autorización
     * @return true si es admin, false en caso contrario
     */
    private boolean isAdmin(String authHeader) {
        try {
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return false;
            }
            
            String token = authHeader.substring(7);
            
            if (!authService.validateToken(token)) {
                return false;
            }
            
            User user = authService.getUserFromToken(token).orElse(null);
            if (user == null) {
                return false;
            }
            
            return user.getRoles().contains(Role.ADMIN);
            
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * Extrae el username del token JWT
     * @param authHeader header de autorización
     * @return username del usuario autenticado
     */
    private String getUsernameFromToken(String authHeader) {
        String token = authHeader.substring(7);
        User user = authService.getUserFromToken(token).orElse(null);
        return user != null ? user.getUsername() : null;
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
