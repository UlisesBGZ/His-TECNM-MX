package ca.uhn.fhir.jpa.starter.auth.config;

import ca.uhn.fhir.jpa.starter.auth.model.Role;
import ca.uhn.fhir.jpa.starter.auth.model.User;
import ca.uhn.fhir.jpa.starter.auth.repository.UserRepository;
import org.mindrot.jbcrypt.BCrypt;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.Set;

@Component
public class DataInitializer implements CommandLineRunner {
    
    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);
    
    @Autowired
    private UserRepository userRepository;
    
    @Override
    public void run(String... args) throws Exception {
        if (!userRepository.existsByUsername("admin")) {
            User admin = new User();
            admin.setUsername("admin");
            admin.setEmail("admin@example.com");
            admin.setPassword(BCrypt.hashpw("admin123", BCrypt.gensalt()));
            admin.setFirstName("System");
            admin.setLastName("Administrator");
            
            Set<Role> roles = new HashSet<>();
            roles.add(Role.ADMIN);
            roles.add(Role.USER);
            admin.setRoles(roles);
            
            userRepository.save(admin);
            logger.info("Default admin user created: username=admin, password=admin123");
        } else {
            logger.info("Admin user already exists");
        }
    }
}
