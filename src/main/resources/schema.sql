
CREATE DATABASE IF NOT EXISTS employee_db;

USE employee_db;

CREATE TABLE IF NOT EXISTS employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    department VARCHAR(100),
    salary DECIMAL(10, 2)
);

INSERT INTO employees (name, email, department, salary)
VALUES
('Rahul', 'rahul@example.com', 'IT', 35000.00),
('Priya', 'priya@example.com', 'HR', 30000.00),
('Arun', 'arun@example.com', 'Finance', 40000.00);
