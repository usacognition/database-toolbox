-- SQLite initialization script for MCP Toolbox testing
-- This script creates sample tables and data for testing the MCP server

-- Create a sample users table
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    first_name TEXT,
    last_name TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Create a sample orders table
CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER REFERENCES users(id),
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    status TEXT DEFAULT 'pending',
    shipping_address TEXT
);

-- Create a sample products table
CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(8,2) NOT NULL,
    category TEXT,
    in_stock INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create order_items junction table
CREATE TABLE IF NOT EXISTS order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    price_per_item DECIMAL(8,2) NOT NULL
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
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category); 