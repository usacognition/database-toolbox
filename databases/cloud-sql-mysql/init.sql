-- MySQL initialization script for MCP Toolbox testing
-- This script creates sample tables and data for testing the MCP server

USE testdb;

-- Create a sample users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Create a sample orders table
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    shipping_address TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create a sample products table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(8,2) NOT NULL,
    category VARCHAR(50),
    in_stock INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create order_items junction table
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price_per_item DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Insert sample data
INSERT INTO users (username, email, first_name, last_name) VALUES
    ('john_doe', 'john@example.com', 'John', 'Doe'),
    ('jane_smith', 'jane@example.com', 'Jane', 'Smith'),
    ('bob_wilson', 'bob@example.com', 'Bob', 'Wilson'),
    ('alice_brown', 'alice@example.com', 'Alice', 'Brown');

INSERT INTO products (name, description, price, category, in_stock) VALUES
    ('Laptop Pro', 'High-performance laptop for professionals', 1299.99, 'Electronics', 25),
    ('Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 'Electronics', 100),
    ('Coffee Mug', 'Ceramic coffee mug with company logo', 12.99, 'Office', 50),
    ('Notebook', 'Professional notebook for meetings', 8.99, 'Office', 75),
    ('Desk Lamp', 'LED desk lamp with adjustable brightness', 45.99, 'Office', 30);

INSERT INTO orders (user_id, total_amount, status, shipping_address) VALUES
    (1, 1329.98, 'shipped', '123 Main St, Anytown, USA'),
    (2, 42.98, 'delivered', '456 Oak Ave, Somewhere, USA'),
    (3, 54.98, 'pending', '789 Pine Rd, Elsewhere, USA'),
    (1, 8.99, 'delivered', '123 Main St, Anytown, USA');

INSERT INTO order_items (order_id, product_id, quantity, price_per_item) VALUES
    (1, 1, 1, 1299.99),
    (1, 2, 1, 29.99),
    (2, 2, 1, 29.99),
    (2, 4, 1, 8.99),
    (2, 3, 1, 12.99),
    (3, 5, 1, 45.99),
    (3, 4, 1, 8.99),
    (4, 4, 1, 8.99);

-- Create some indexes for better query performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category);

-- Grant necessary permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON testdb.* TO 'testuser'@'%';