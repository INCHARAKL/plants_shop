const express = require('express');
const mysql = require('mysql2/promise'); // Use promise version
const cors = require('cors');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// MySQL connection pool
const dbConfig = {
    host: 'localhost',
    user: 'root',
    password: 'tiger',
    database: 'plants_shop',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

let pool;
async function initDB() {
    try {
        pool = await mysql.createPool(dbConfig);
        console.log('✅ Connected to MySQL database');
    } catch (err) {
        console.error('❌ Error connecting to MySQL:', err);
        process.exit(1);
    }
}
initDB();

// --------- PRODUCTS ---------
app.get('/api/products', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM products WHERE stock_quantity > 0 ORDER BY id');
        res.json(rows);
    } catch (err) {
        console.error('Error fetching products:', err);
        res.status(500).json({ error: 'Failed to fetch products' });
    }
});

app.get('/api/products/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const [rows] = await pool.query('SELECT * FROM products WHERE id = ?', [id]);
        if (rows.length === 0) return res.status(404).json({ error: 'Product not found' });
        res.json(rows[0]);
    } catch (err) {
        console.error('Error fetching product:', err);
        res.status(500).json({ error: 'Failed to fetch product' });
    }
});

app.get('/api/products/category/:category', async (req, res) => {
    const { category } = req.params;
    try {
        const [rows] = await pool.query(
            'SELECT * FROM products WHERE category = ? AND stock_quantity > 0 ORDER BY id',
            [category]
        );
        res.json(rows);
    } catch (err) {
        console.error('Error fetching products by category:', err);
        res.status(500).json({ error: 'Failed to fetch products' });
    }
});

// --------- ORDERS ---------
app.post('/api/orders', async (req, res) => {
    const { items, total, customer_name, customer_email, customer_phone, customer_address } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
        return res.status(400).json({ error: 'No items to order' });
    }
    if (!customer_name || !customer_email || !customer_address) {
        return res.status(400).json({ error: 'Missing customer details' });
    }

    // Basic email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(customer_email)) {
        return res.status(400).json({ error: 'Invalid email address' });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // Insert order
        const [orderResult] = await connection.query(
            'INSERT INTO orders (customer_name, customer_email, customer_phone, customer_address, total_amount, order_date) VALUES (?, ?, ?, ?, ?, NOW())',
            [customer_name, customer_email, customer_phone || null, customer_address, total]
        );
        const orderId = orderResult.insertId;

        // Validate products exist
        const productIds = items.map(item => item.id);
        const [validProducts] = await connection.query(
            `SELECT id FROM products WHERE id IN (${productIds.map(() => '?').join(',')})`,
            productIds
        );
        const validIds = validProducts.map(p => p.id);
        const invalidIds = productIds.filter(id => !validIds.includes(id));
        if (invalidIds.length > 0) {
            await connection.rollback();
            return res.status(400).json({ error: `Invalid product IDs: ${invalidIds.join(', ')}` });
        }

        // Insert order items
        const orderItems = items.map(item => [orderId, item.id, item.quantity, item.price]);
        await connection.query(
            'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES ?',
            [orderItems]
        );

        // Update stock quantities
        for (const item of items) {
            await connection.query(
                'UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?',
                [item.quantity, item.id]
            );
        }

        await connection.commit();
        res.status(200).json({ success: true, orderId, message: 'Order created successfully!' });
    } catch (err) {
        await connection.rollback();
        console.error('Checkout error:', err);
        res.status(500).json({ error: 'Failed to place order' });
    } finally {
        connection.release();
    }
});

app.get('/api/orders', async (req, res) => {
    const sql = `
        SELECT o.customer_name, o.customer_email, o.customer_phone, o.customer_address, o.total_amount, o.order_date, o.status, o.id,
               oi.product_id, oi.quantity, oi.price, p.name AS product_name
        FROM orders o
        JOIN order_items oi ON o.id = oi.order_id
        JOIN products p ON oi.product_id = p.id
        ORDER BY o.order_date DESC
    `;
    try {
        const [rows] = await pool.query(sql);
        res.json(rows);
    } catch (err) {
        console.error('Error fetching orders:', err);
        res.status(500).json({ error: 'Failed to fetch orders' });
    }
});

// Serve index.html
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
});