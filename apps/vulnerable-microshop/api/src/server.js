// MicroShop API Server
// Simple REST API for demonstration

const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Products endpoint
app.get('/api/products', (req, res) => {
  const products = [
    { id: 1, name: 'Widget Pro', price: 29.99 },
    { id: 2, name: 'Gadget Plus', price: 49.99 },
    { id: 3, name: 'Tool Kit', price: 79.99 }
  ];
  res.json(products);
});

// Cart endpoint (demo)
app.post('/api/cart', (req, res) => {
  res.json({ message: 'Item added to cart', cart: req.body });
});

// Start server
app.listen(PORT, () => {
  console.log(`MicroShop API running on port ${PORT}`);
});
