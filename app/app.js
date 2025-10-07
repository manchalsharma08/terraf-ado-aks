// ======================================
// File: app.js
// Purpose: Simple Express.js Web Server
// ======================================

const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

// Basic route
app.get('/', (req, res) => {
  res.send('🚀 Hello from Node.js App running on AKS!');
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).send('✅ OK');
});

// Start server
app.listen(port, () => {
  console.log(`✅ Server is running on port ${port}`);
});
