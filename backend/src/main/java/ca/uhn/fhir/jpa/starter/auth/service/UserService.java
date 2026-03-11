package ca.uhn.fhir.jpa.starter.auth.service;

import ca.uhn.fhir.jpa.starter.auth.dto.UserResponse;
import ca.uhn.fhir.jpa.starter.auth.model.User;
import ca.uhn.fhir.jpa.starter.auth.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Servicio de Gestión de Usuarios
 * Contiene toda la lógica de negocio relacionada con operaciones de usuarios:
 * - Listado de usuarios
 * - Obtener usuario por ID
 * - Actualizar usuarios
 * - Eliminar usuarios
 * - Habilitar/deshabilitar usuarios
 */
@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    /**
     * Obtiene todos los usuarios del sistema
     * @return Lista de UserResponse con los datos de los usuarios
     */
    public List<UserResponse> getAllUsers() {
        return userRepository.findAll().stream()
                .map(UserResponse::new)
                .collect(Collectors.toList());
    }

    /**
     * Obtiene un usuario por su ID
     * @param id ID del usuario
     * @return Optional<UserResponse> con los datos del usuario si existe
     */
    public Optional<UserResponse> getUserById(Long id) {
        return userRepository.findById(id)
                .map(UserResponse::new);
    }

    /**
     * Obtiene un usuario por su username
     * @param username username del usuario
     * @return Optional<User> con el usuario si existe
     */
    public Optional<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    /**
     * Cambia el estado (habilitado/deshabilitado) de un usuario
     * @param id ID del usuario
     * @return UserResponse con los datos actualizados del usuario
     * @throws RuntimeException si el usuario no existe
     */
    public UserResponse toggleUserStatus(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + id));

        // Cambiar el estado
        user.setEnabled(!user.isEnabled());
        
        // Guardar cambios
        userRepository.save(user);

        return new UserResponse(user);
    }

    /**
     * Actualiza los datos de un usuario
     * @param id ID del usuario a actualizar
     * @param updatedUser datos actualizados del usuario
     * @return UserResponse con los datos actualizados
     * @throws RuntimeException si el usuario no existe
     */
    public UserResponse updateUser(Long id, User updatedUser) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + id));

        // Actualizar campos permitidos
        if (updatedUser.getEmail() != null) {
            // Verificar que el email no esté en uso por otro usuario
            Optional<User> existingUser = userRepository.findByEmail(updatedUser.getEmail());
            if (existingUser.isPresent() && !existingUser.get().getId().equals(id)) {
                throw new RuntimeException("Email is already in use by another user");
            }
            user.setEmail(updatedUser.getEmail());
        }

        if (updatedUser.getFirstName() != null) {
            user.setFirstName(updatedUser.getFirstName());
        }

        if (updatedUser.getLastName() != null) {
            user.setLastName(updatedUser.getLastName());
        }

        if (updatedUser.getRoles() != null && !updatedUser.getRoles().isEmpty()) {
            user.setRoles(updatedUser.getRoles());
        }

        // Guardar cambios
        userRepository.save(user);

        return new UserResponse(user);
    }

    /**
     * Elimina un usuario del sistema
     * @param id ID del usuario a eliminar
     * @throws RuntimeException si el usuario no existe
     */
    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("User not found with id: " + id);
        }
        userRepository.deleteById(id);
    }

    /**
     * Verifica si un usuario existe por su ID
     * @param id ID del usuario
     * @return true si el usuario existe, false en caso contrario
     */
    public boolean userExists(Long id) {
        return userRepository.existsById(id);
    }

    /**
     * Cuenta el número total de usuarios en el sistema
     * @return número total de usuarios
     */
    public long countUsers() {
        return userRepository.count();
    }

    /**
     * Obtiene todos los usuarios habilitados
     * @return Lista de UserResponse con usuarios habilitados
     */
    public List<UserResponse> getEnabledUsers() {
        return userRepository.findAll().stream()
                .filter(User::isEnabled)
                .map(UserResponse::new)
                .collect(Collectors.toList());
    }

    /**
     * Obtiene todos los usuarios deshabilitados
     * @return Lista de UserResponse con usuarios deshabilitados
     */
    public List<UserResponse> getDisabledUsers() {
        return userRepository.findAll().stream()
                .filter(user -> !user.isEnabled())
                .map(UserResponse::new)
                .collect(Collectors.toList());
    }
}
