package ca.uhn.fhir.jpa.starter.auth;

import ca.uhn.fhir.jpa.starter.auth.controller.UserController;
import ca.uhn.fhir.jpa.starter.auth.model.Role;
import ca.uhn.fhir.jpa.starter.auth.model.User;
import ca.uhn.fhir.jpa.starter.auth.repository.UserRepository;
import ca.uhn.fhir.jpa.starter.auth.util.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Tests unitarios para UserController
 * Verifica el correcto funcionamiento de operaciones CRUD de usuarios
 */
@ExtendWith(MockitoExtension.class)
class UserControllerTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private JwtUtil jwtUtil;

    @InjectMocks
    private UserController userController;

    private User adminUser;
    private User regularUser;
    private String adminToken;
    private String userToken;

    @BeforeEach
    void setUp() {
        // Usuario administrador
        adminUser = new User();
        adminUser.setId(1L);
        adminUser.setUsername("admin");
        adminUser.setEmail("admin@hospital.com");
        adminUser.setFirstName("Admin");
        adminUser.setLastName("User");
        Set<Role> adminRoles = new HashSet<>();
        adminRoles.add(Role.ADMIN);
        adminRoles.add(Role.USER);
        adminUser.setRoles(adminRoles);
        adminUser.setEnabled(true);

        // Usuario regular
        regularUser = new User();
        regularUser.setId(2L);
        regularUser.setUsername("user1");
        regularUser.setEmail("user1@hospital.com");
        regularUser.setFirstName("Regular");
        regularUser.setLastName("User");
        Set<Role> userRoles = new HashSet<>();
        userRoles.add(Role.USER);
        regularUser.setRoles(userRoles);
        regularUser.setEnabled(true);

        adminToken = "Bearer admin-token";
        userToken = "Bearer user-token";
    }

    // ==================== TESTS DE GET ALL USERS ====================

    @Test
    void testGetAllUsersAsAdmin() {
        // Given
        List<User> users = Arrays.asList(adminUser, regularUser);
        when(jwtUtil.validateToken("admin-token")).thenReturn(true);
        when(jwtUtil.getUsernameFromToken("admin-token")).thenReturn("admin");
        when(userRepository.findByUsername("admin")).thenReturn(Optional.of(adminUser));
        when(userRepository.findAll()).thenReturn(users);

        // When
        ResponseEntity<?> response = userController.getAllUsers(adminToken);

        // Then
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody() instanceof List);
        
        @SuppressWarnings("unchecked")
        List<?> userList = (List<?>) response.getBody();
        assertEquals(2, userList.size());
        
        verify(userRepository, times(1)).findAll();
    }

    @Test
    void testGetAllUsersAsNonAdmin() {
        // Given
        when(jwtUtil.validateToken("user-token")).thenReturn(true);
        when(jwtUtil.getUsernameFromToken("user-token")).thenReturn("user1");
        when(userRepository.findByUsername("user1")).thenReturn(Optional.of(regularUser));

        // When
        ResponseEntity<?> response = userController.getAllUsers(userToken);

        // Then
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        verify(userRepository, never()).findAll();
    }

    @Test
    void testGetAllUsersWithInvalidToken() {
        // Given
        when(jwtUtil.validateToken("invalid-token")).thenReturn(false);

        // When
        ResponseEntity<?> response = userController.getAllUsers("Bearer invalid-token");

        // Then
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        verify(userRepository, never()).findAll();
    }

    // ==================== TESTS DE GET USER BY ID ====================

    @Test
    void testGetUserByIdAsAdmin() {
        // Given
        when(jwtUtil.validateToken("admin-token")).thenReturn(true);
        when(jwtUtil.getUsernameFromToken("admin-token")).thenReturn("admin");
        when(userRepository.findByUsername("admin")).thenReturn(Optional.of(adminUser));
        when(userRepository.findById(2L)).thenReturn(Optional.of(regularUser));

        // When
        ResponseEntity<?> response = userController.getUserById(2L, adminToken);

        // Then
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        verify(userRepository, times(1)).findById(2L);
    }

    @Test
    void testGetUserByIdNotFound() {
        // Given
        when(jwtUtil.validateToken("admin-token")).thenReturn(true);
        when(jwtUtil.getUsernameFromToken("admin-token")).thenReturn("admin");
        when(userRepository.findByUsername("admin")).thenReturn(Optional.of(adminUser));
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When
        ResponseEntity<?> response = userController.getUserById(999L, adminToken);

        // Then
        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        verify(userRepository, times(1)).findById(999L);
    }

    @Test
    void testGetUserByIdAsNonAdmin() {
        // Given
        when(jwtUtil.validateToken("user-token")).thenReturn(true);
        when(jwtUtil.getUsernameFromToken("user-token")).thenReturn("user1");
        when(userRepository.findByUsername("user1")).thenReturn(Optional.of(regularUser));

        // When
        ResponseEntity<?> response = userController.getUserById(1L, userToken);

        // Then
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        verify(userRepository, never()).findById(any());
    }

    // ==================== TESTS DE DELETE USER ====================

    @Test
    void testDeleteUserAsAdmin() {
        // Given
        when(jwtUtil.validateToken("admin-token")).thenReturn(true);
        when(jwtUtil.getUsernameFromToken("admin-token")).thenReturn("admin");
        when(userRepository.findByUsername("admin")).thenReturn(Optional.of(adminUser));
        when(userRepository.findById(2L)).thenReturn(Optional.of(regularUser));
        doNothing().when(userRepository).deleteById(2L);

        // When
        ResponseEntity<?> response = userController.deleteUser(2L, adminToken);

        // Then
        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(userRepository, times(1)).deleteById(2L);
    }

    @Test
    void testDeleteUserNotFound() {
        // Given
        when(jwtUtil.validateToken("admin-token")).thenReturn(true);
        when(jwtUtil.getUsernameFromToken("admin-token")).thenReturn("admin");
        when(userRepository.findByUsername("admin")).thenReturn(Optional.of(adminUser));
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When
        ResponseEntity<?> response = userController.deleteUser(999L, adminToken);

        // Then
        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        verify(userRepository, never()).deleteById(any());
    }

    @Test
    void testDeleteUserAsNonAdmin() {
        // Given
        when(jwtUtil.validateToken("user-token")).thenReturn(true);
        when(jwtUtil.getUsernameFromToken("user-token")).thenReturn("user1");
        when(userRepository.findByUsername("user1")).thenReturn(Optional.of(regularUser));

        // When
        ResponseEntity<?> response = userController.deleteUser(1L, userToken);

        // Then
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        verify(userRepository, never()).deleteById(any());
    }

    // ==================== TESTS DE UPDATE USER ====================
    // ==================== TESTS DE TOGGLE USER STATUS ====================

    @Test
    void testToggleUserStatusEnableAsAdmin() {
        // Given
        regularUser.setEnabled(false);
        when(jwtUtil.validateToken("admin-token")).thenReturn(true);
        when(jwtUtil.getUsernameFromToken("admin-token")).thenReturn("admin");
        when(userRepository.findByUsername("admin")).thenReturn(Optional.of(adminUser));
        when(userRepository.findById(2L)).thenReturn(Optional.of(regularUser));
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User user = invocation.getArgument(0);
            return user;
        });

        // When
        ResponseEntity<?> response = userController.toggleUserStatus(2L, adminToken);

        // Then
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(regularUser.isEnabled());
        verify(userRepository, times(1)).save(regularUser);
    }

    @Test
    void testToggleUserStatusDisableAsAdmin() {
        // Given
        regularUser.setEnabled(true);
        when(jwtUtil.validateToken("admin-token")).thenReturn(true);
        when(jwtUtil.getUsernameFromToken("admin-token")).thenReturn("admin");
        when(userRepository.findByUsername("admin")).thenReturn(Optional.of(adminUser));
        when(userRepository.findById(2L)).thenReturn(Optional.of(regularUser));
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User user = invocation.getArgument(0);
            return user;
        });

        // When
        ResponseEntity<?> response = userController.toggleUserStatus(2L, adminToken);

        // Then
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertFalse(regularUser.isEnabled());
        verify(userRepository, times(1)).save(regularUser);
    }
}
