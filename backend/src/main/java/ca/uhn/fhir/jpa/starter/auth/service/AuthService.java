package ca.uhn.fhir.jpa.starter.auth.service;

import ca.uhn.fhir.jpa.starter.auth.dto.JwtResponse;
import ca.uhn.fhir.jpa.starter.auth.dto.LoginRequest;
import ca.uhn.fhir.jpa.starter.auth.dto.SignupRequest;
import ca.uhn.fhir.jpa.starter.auth.model.Role;
import ca.uhn.fhir.jpa.starter.auth.model.User;
import ca.uhn.fhir.jpa.starter.auth.repository.UserRepository;
import ca.uhn.fhir.jpa.starter.auth.util.JwtUtil;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

/**
 * Servicio de Autenticación
 * Contiene toda la lógica de negocio relacionada con autenticación:
 * - Login de usuarios
 * - Registro de nuevos usuarios
 * - Validación de tokens JWT
 * - Creación de usuarios admin
 */
@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * Autentica un usuario y genera un token JWT
     * @param loginRequest credenciales del usuario
     * @return JwtResponse con token y datos del usuario
     * @throws RuntimeException si las credenciales son inválidas o la cuenta está deshabilitada
     */
    public JwtResponse login(LoginRequest loginRequest) {
        // Buscar usuario por username
        User user = userRepository.findByUsername(loginRequest.getUsername())
                .orElseThrow(() -> new RuntimeException("Invalid username or password"));

        // Verificar contraseña
        if (!BCrypt.checkpw(loginRequest.getPassword(), user.getPassword())) {
            throw new RuntimeException("Invalid username or password");
        }

        // Verificar que la cuenta esté habilitada
        if (!user.isEnabled()) {
            throw new RuntimeException("Account is disabled");
        }

        // Generar token JWT
        String token = jwtUtil.generateToken(user);

        // Crear respuesta
        return new JwtResponse(
                token,
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getFirstName(),
                user.getLastName(),
                user.getRoles()
        );
    }

    /**
     * Registra un nuevo usuario en el sistema
     * @param signupRequest datos del nuevo usuario
     * @return JwtResponse con token y datos del usuario creado
     * @throws RuntimeException si el username o email ya existen
     */
    public JwtResponse signup(SignupRequest signupRequest) {
        // Validar que el username no exista
        if (userRepository.findByUsername(signupRequest.getUsername()).isPresent()) {
            throw new RuntimeException("Username is already taken");
        }

        // Validar que el email no exista
        if (userRepository.findByEmail(signupRequest.getEmail()).isPresent()) {
            throw new RuntimeException("Email is already in use");
        }

        // Crear nuevo usuario
        User user = new User();
        user.setUsername(signupRequest.getUsername());
        user.setEmail(signupRequest.getEmail());
        user.setPassword(BCrypt.hashpw(signupRequest.getPassword(), BCrypt.gensalt()));
        user.setFirstName(signupRequest.getFirstName());
        user.setLastName(signupRequest.getLastName());
        
        // Configurar roles
        Set<Role> roles = new HashSet<>();
        if (signupRequest.isAdmin()) {
            roles.add(Role.ADMIN);
        }
        roles.add(Role.USER);
        user.setRoles(roles);
        user.setEnabled(true);

        // Guardar en base de datos
        userRepository.save(user);

        // Generar token JWT
        String token = jwtUtil.generateToken(user);

        // Crear respuesta
        return new JwtResponse(
                token,
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getFirstName(),
                user.getLastName(),
                user.getRoles()
        );
    }

    /**
     * Valida un token JWT
     * @param token token JWT a validar
     * @return true si el token es válido, false en caso contrario
     */
    public boolean validateToken(String token) {
        try {
            // Validar el token
            if (!jwtUtil.validateToken(token)) {
                return false;
            }
            
            // Extraer username del token
            String username = jwtUtil.getUsernameFromToken(token);
            
            // Verificar que el usuario exista
            Optional<User> user = userRepository.findByUsername(username);
            return user.isPresent();
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Crea un usuario con rol de ADMIN
     * @param signupRequest datos del nuevo admin
     * @return JwtResponse con token y datos del admin creado
     * @throws RuntimeException si el username o email ya existen
     */
    public JwtResponse createAdmin(SignupRequest signupRequest) {
        // Validar que el username no exista
        if (userRepository.findByUsername(signupRequest.getUsername()).isPresent()) {
            throw new RuntimeException("Username is already taken");
        }

        // Validar que el email no exista
        if (userRepository.findByEmail(signupRequest.getEmail()).isPresent()) {
            throw new RuntimeException("Email is already in use");
        }

        // Crear nuevo usuario ADMIN
        User admin = new User();
        admin.setUsername(signupRequest.getUsername());
        admin.setEmail(signupRequest.getEmail());
        admin.setPassword(BCrypt.hashpw(signupRequest.getPassword(), BCrypt.gensalt()));
        admin.setFirstName(signupRequest.getFirstName());
        admin.setLastName(signupRequest.getLastName());
        
        // Configurar roles ADMIN
        Set<Role> roles = new HashSet<>();
        roles.add(Role.ADMIN);
        roles.add(Role.USER);
        admin.setRoles(roles);
        admin.setEnabled(true);

        // Guardar en base de datos
        userRepository.save(admin);

        // Generar token JWT
        String token = jwtUtil.generateToken(admin);

        // Crear respuesta
        return new JwtResponse(
                token,
                admin.getId(),
                admin.getUsername(),
                admin.getEmail(),
                admin.getFirstName(),
                admin.getLastName(),
                admin.getRoles()
        );
    }

    /**
     * Obtiene información del usuario desde el token
     * @param token token JWT
     * @return Optional<User> usuario si el token es válido
     */
    public Optional<User> getUserFromToken(String token) {
        try {
            String username = jwtUtil.getUsernameFromToken(token);
            return userRepository.findByUsername(username);
        } catch (Exception e) {
            return Optional.empty();
        }
    }
}
