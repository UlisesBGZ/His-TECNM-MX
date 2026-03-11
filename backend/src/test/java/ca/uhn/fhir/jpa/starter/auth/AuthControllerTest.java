package ca.uhn.fhir.jpa.starter.auth;

import ca.uhn.fhir.jpa.starter.auth.controller.AuthController;
import ca.uhn.fhir.jpa.starter.auth.dto.JwtResponse;
import ca.uhn.fhir.jpa.starter.auth.dto.LoginRequest;
import ca.uhn.fhir.jpa.starter.auth.dto.SignupRequest;
import ca.uhn.fhir.jpa.starter.auth.model.Role;
import ca.uhn.fhir.jpa.starter.auth.model.User;
import ca.uhn.fhir.jpa.starter.auth.repository.UserRepository;
import ca.uhn.fhir.jpa.starter.auth.util.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mindrot.jbcrypt.BCrypt;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * Tests unitarios para AuthController
 * Verifica el correcto funcionamiento de login, signup y creación de administradores
 */
@ExtendWith(MockitoExtension.class)
class AuthControllerTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private JwtUtil jwtUtil;

    @InjectMocks
    private AuthController authController;

    private User testUser;
    private LoginRequest loginRequest;
    private SignupRequest signupRequest;
    private String hashedPassword;

    @BeforeEach
    void setUp() {
        // Crear usuario de prueba
        testUser = new User();
        testUser.setId(1L);
        testUser.setUsername("testuser");
        testUser.setEmail("test@example.com");
        testUser.setFirstName("Test");
        testUser.setLastName("User");
        hashedPassword = BCrypt.hashpw("password123", BCrypt.gensalt());
        testUser.setPassword(hashedPassword);
        testUser.setEnabled(true);
        
        Set<Role> roles = new HashSet<>();
        roles.add(Role.USER);
        testUser.setRoles(roles);

        // Request de login
        loginRequest = new LoginRequest();
        loginRequest.setUsername("testuser");
        loginRequest.setPassword("password123");

        // Request de signup
        signupRequest = new SignupRequest();
        signupRequest.setUsername("newuser");
        signupRequest.setEmail("newuser@example.com");
        signupRequest.setPassword("password123");
        signupRequest.setFirstName("New");
        signupRequest.setLastName("User");
        signupRequest.setAdmin(false);
    }

    // ==================== TESTS DE LOGIN ====================

    @Test
    void testLoginSuccess() {
        // Given
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(testUser));
        when(jwtUtil.generateToken(any(User.class))).thenReturn("mock-jwt-token");

        // When
        ResponseEntity<?> response = authController.login(loginRequest);

        // Then
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody() instanceof JwtResponse);
        
        JwtResponse jwtResponse = (JwtResponse) response.getBody();
        assertEquals("mock-jwt-token", jwtResponse.getToken());
        assertEquals("testuser", jwtResponse.getUsername());
        assertEquals("test@example.com", jwtResponse.getEmail());
        
        verify(userRepository, times(1)).findByUsername("testuser");
        verify(jwtUtil, times(1)).generateToken(testUser);
    }

    @Test
    void testLoginWithInvalidUsername() {
        // Given
        when(userRepository.findByUsername("invaliduser")).thenReturn(Optional.empty());
        loginRequest.setUsername("invaliduser");

        // When
        ResponseEntity<?> response = authController.login(loginRequest);

        // Then
        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode());
        verify(userRepository, times(1)).findByUsername("invaliduser");
        verify(jwtUtil, never()).generateToken(any());
    }

    @Test
    void testLoginWithInvalidPassword() {
        // Given
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(testUser));
        loginRequest.setPassword("wrongpassword");

        // When
        ResponseEntity<?> response = authController.login(loginRequest);

        // Then
        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode());
        verify(userRepository, times(1)).findByUsername("testuser");
        verify(jwtUtil, never()).generateToken(any());
    }

    @Test
    void testLoginWithDisabledAccount() {
        // Given
        testUser.setEnabled(false);
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(testUser));

        // When
        ResponseEntity<?> response = authController.login(loginRequest);

        // Then
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        verify(userRepository, times(1)).findByUsername("testuser");
        verify(jwtUtil, never()).generateToken(any());
    }

    // ==================== TESTS DE SIGNUP ====================

    @Test
    void testSignupSuccess() {
        // Given
        when(userRepository.existsByUsername("newuser")).thenReturn(false);
        when(userRepository.existsByEmail("newuser@example.com")).thenReturn(false);
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User user = invocation.getArgument(0);
            user.setId(2L);
            return user;
        });
        when(jwtUtil.generateToken(any(User.class))).thenReturn("new-jwt-token");

        // When
        ResponseEntity<?> response = authController.signup(signupRequest);

        // Then
        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody() instanceof JwtResponse);
        
        JwtResponse jwtResponse = (JwtResponse) response.getBody();
        assertEquals("new-jwt-token", jwtResponse.getToken());
        assertEquals("newuser", jwtResponse.getUsername());
        
        verify(userRepository, times(1)).existsByUsername("newuser");
        verify(userRepository, times(1)).existsByEmail("newuser@example.com");
        verify(userRepository, times(1)).save(any(User.class));
        verify(jwtUtil, times(1)).generateToken(any(User.class));
    }

    @Test
    void testSignupWithExistingUsername() {
        // Given
        when(userRepository.existsByUsername("newuser")).thenReturn(true);

        // When
        ResponseEntity<?> response = authController.signup(signupRequest);

        // Then
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        verify(userRepository, times(1)).existsByUsername("newuser");
        verify(userRepository, never()).save(any());
    }

    @Test
    void testSignupWithExistingEmail() {
        // Given
        when(userRepository.existsByUsername("newuser")).thenReturn(false);
        when(userRepository.existsByEmail("newuser@example.com")).thenReturn(true);

        // When
        ResponseEntity<?> response = authController.signup(signupRequest);

        // Then
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        verify(userRepository, times(1)).existsByEmail("newuser@example.com");
        verify(userRepository, never()).save(any());
    }

    @Test
    void testSignupAsAdmin() {
        // Given
        signupRequest.setAdmin(true);
        when(userRepository.existsByUsername("newuser")).thenReturn(false);
        when(userRepository.existsByEmail("newuser@example.com")).thenReturn(false);
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User user = invocation.getArgument(0);
            user.setId(3L);
            return user;
        });
        when(jwtUtil.generateToken(any(User.class))).thenReturn("admin-jwt-token");

        // When
        ResponseEntity<?> response = authController.signup(signupRequest);

        // Then
        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        verify(userRepository, times(1)).save(any(User.class));
    }

    // ==================== TESTS DE CREATE-ADMIN ====================

    @Test
    void testCreateAdminSuccess() {
        // Given
        SignupRequest adminRequest = new SignupRequest();
        adminRequest.setUsername("admin");
        adminRequest.setEmail("admin@hospital.com");
        adminRequest.setPassword("adminpass");
        adminRequest.setFirstName("Admin");
        adminRequest.setLastName("User");
        adminRequest.setAdmin(true);

        when(userRepository.existsByUsername("admin")).thenReturn(false);
        when(userRepository.existsByEmail("admin@hospital.com")).thenReturn(false);
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User user = invocation.getArgument(0);
            user.setId(4L);
            return user;
        });
        when(jwtUtil.generateToken(any(User.class))).thenReturn("admin-token");

        // When
        ResponseEntity<?> response = authController.createAdmin(adminRequest);

        // Then
        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        verify(userRepository, times(1)).save(any(User.class));
    }

    // ==================== TESTS DE VALIDATE-TOKEN ====================

    @Test
    void testValidateTokenValid() {
        // Given
        String token = "Bearer valid-token";
        when(jwtUtil.validateToken("valid-token")).thenReturn(true);
        when(jwtUtil.getUsernameFromToken("valid-token")).thenReturn("testuser");
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(testUser));

        // When
        ResponseEntity<?> response = authController.validateToken(token);

        // Then
        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(jwtUtil, times(1)).validateToken("valid-token");
    }

    @Test
    void testValidateTokenInvalid() {
        // Given
        String token = "Bearer invalid-token";
        when(jwtUtil.validateToken("invalid-token")).thenReturn(false);

        // When
        ResponseEntity<?> response = authController.validateToken(token);

        // Then
        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode());
        verify(jwtUtil, times(1)).validateToken("invalid-token");
        verify(userRepository, never()).findByUsername(any());
    }

    @Test
    void testValidateTokenMissing() {
        // When
        ResponseEntity<?> response = authController.validateToken(null);

        // Then
        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode());
    }
}
