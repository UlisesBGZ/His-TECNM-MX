-- Script de inicialización: Crear usuario admin por defecto
-- Password: admin123 (encriptado con BCrypt)
-- Ejecutar manualmente después del primer arranque del servidor

-- Nota: El hash BCrypt para 'admin123' es el siguiente:
-- $2a$10$8mjK9ywWBv.G6Px6a5zN8.FHY9zJbZjY7TQwK9WwGJ8FUqLqR5HnO

INSERT INTO app_users (username, email, password, first_name, last_name, enabled, created_at, updated_at)
VALUES ('admin', 'admin@hospital.com', '$2a$10$8mjK9ywWBv.G6Px6a5zN8.FHY9zJbZjY7TQwK9WwGJ8FUqLqR5HnO', 'Administrador', 'Sistema', true, NOW(), NOW())
ON CONFLICT (username) DO NOTHING;

-- Obtener el ID del usuario admin
DO $$
DECLARE
    admin_user_id BIGINT;
BEGIN
    SELECT id INTO admin_user_id FROM app_users WHERE username = 'admin';
    
    -- Asignar rol ADMIN
    INSERT INTO user_roles (user_id, role)
    VALUES (admin_user_id, 'ROLE_ADMIN')
    ON CONFLICT DO NOTHING;
    
    -- Asignar rol USER también
    INSERT INTO user_roles (user_id, role)
    VALUES (admin_user_id, 'ROLE_USER')
    ON CONFLICT DO NOTHING;
END $$;
