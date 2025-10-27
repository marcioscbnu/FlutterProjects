CREATE DATABASE IF NOT EXISTS biblioteca CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'usuario'@'localhost' IDENTIFIED BY 'senha';
GRANT ALL PRIVILEGES ON *.* TO 'usuario'@'localhost';
FLUSH PRIVILEGES;

// tive que usar essa opção d ecriação de usuário a fim de evitar erro de SOCKET na conexão
ALTER USER 'usuario'@'localhost'
  IDENTIFIED WITH mysql_native_password BY 'senha';
FLUSH PRIVILEGES;

USE biblioteca;

CREATE TABLE IF NOT EXISTS livro (
  idlivro INT AUTO_INCREMENT PRIMARY KEY,
  autor   VARCHAR(40) NOT NULL,
  titulo  VARCHAR(60) NOT NULL,
  tema    VARCHAR(20) NOT NULL
);

-- Opcional: dados de exemplo
INSERT INTO livro (autor, titulo, tema) VALUES
('Machado de Assis', 'Dom Casmurro', 'Romance'),
('George Orwell', '1984', 'Distopia');
