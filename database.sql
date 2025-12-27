CREATE DATABASE IF NOT EXISTS plants_shop;
USE plants_shop;

-- Products table (unchanged)
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    image VARCHAR(255) NOT NULL,
    description TEXT,
    stock_quantity INT DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    customer_address TEXT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending'
);
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);
INSERT INTO products (name, category, price, image, description) VALUES
-- Medicinal Plants
('Aloe Vera', 'Medicinal', 150, 'images/aloe_vera.jpg', 'Healing plant known for its soothing gel, perfect for skin care and air purification.'),
('Tulsi', 'Medicinal', 125, 'images/tulsi.jpg', 'Holy basil with aromatic leaves, known for its immunity-boosting properties.'),
('Turmeric', 'Medicinal', 99, 'images/turmeric.jpg', 'Anti-inflammatory root plant with vibrant color and health benefits.'),
('Ginger', 'Medicinal', 125, 'images/ginger.jpg', 'Digestive aid plant with aromatic rhizomes, easy to grow indoors.'),
('Neem', 'Medicinal', 875, 'images/neem.jpg', 'Natural pesticide plant with medicinal properties, purifies the air.'),

-- Ornamental Plants
('Rose', 'Ornamental', 200, 'images/rose.jpg', 'Classic beauty with fragrant blooms, perfect for gardens and gifts.'),
('Orchid', 'Ornamental', 850, 'images/orchid.jpg', 'Exotic and elegant flowering plant that adds sophistication to any space.'),
('Hibiscus', 'Ornamental', 499, 'images/Hibiscus.jpg', 'Vibrant tropical bloom that brings color to your garden or patio.'),
('Snake Plant', 'Ornamental', 675, 'images/snake.jpg', 'Low-maintenance air purifier with striking vertical leaves.'),
('Bonsai', 'Ornamental', 450, 'images/Bonsai.jpg', 'Miniature tree art that represents patience and harmony.'),

-- Indoor Plants
('Spider Plant', 'Indoor', 699, 'images/spider.jpg', 'Easy-care hanging plant that produces baby spiderettes.'),
('Pothos Plant', 'Indoor', 950, 'images/pothos.jpg', 'Trailing vine plant perfect for low light conditions.'),
('ZZ Plant', 'Indoor', 925, 'images/ZZ.jpg', 'Drought-tolerant succulent that thrives with minimal care.'),
('Areca Palm', 'Indoor', 700, 'images/areca.jpg', 'Tropical indoor tree that adds a touch of the tropics to your home.'),
('Chinese Evergreen Plant', 'Indoor', 1375, 'images/chinese.jpg', 'Beautiful foliage plant that thrives in shaded areas.'),

-- Aromatic Plants
('Lavender', 'Aromatic', 799, 'images/lavender.jpg', 'Calming scent for relaxation, perfect for aromatherapy and gardens.'),
('Mint', 'Aromatic', 150, 'images/mint.jpg', 'Fresh herb perfect for teas, cocktails, and culinary uses.'),
('Rosemary', 'Aromatic', 1099, 'images/rosemary.jpg', 'Culinary and aromatic shrub with needle-like leaves.'),
('Basil', 'Aromatic', 825, 'images/basil.jpg', 'Italian herb essential for cooking, with a strong aromatic scent.'),
('Jasmine', 'Aromatic', 910, 'images/jasmine.jpg', 'Fragrant flowering vine that blooms beautiful white flowers.'),

-- Flowering Plants
('Sunflower', 'Flowering', 199, 'images/sunflower.jpg', 'Tall, sunny blooms that follow the sun throughout the day.'),
('Tulip', 'Flowering', 1500, 'images/tulip.jpg', 'Spring bulb flower available in a wide range of colors.'),
('Peace-lily', 'Flowering', 850, 'images/peace.jpg', 'Colorful tuberous blooms with intricate petal arrangements.'),
('Lily', 'Flowering', 1175, 'images/lily.jpg', 'Elegant summer flower with a strong, sweet fragrance.'),
('Marigold', 'Flowering', 899, 'images/marigold.jpg', 'Bright annual flowers perfect for gardens and borders.');
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_name VARCHAR(100) NOT NULL DEFAULT '';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_email VARCHAR(255) NOT NULL DEFAULT '';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_phone VARCHAR(20) NOT NULL DEFAULT '';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_address TEXT NOT NULL DEFAULT '';
USE plants_shop;
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) DEFAULT NULL,  
    customer_address TEXT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending'
);
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);
DESCRIBE orders;