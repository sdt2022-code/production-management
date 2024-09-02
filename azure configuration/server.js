const express = require('express');
const { Client } = require('pg');
const fs = require('fs');

const app = express();
const port = process.env.PORT || 3000;

// PostgreSQL client configuration
const client = new Client({
  host: "mypostgreserver.postgres.database.azure.com",
  user: "saridtarabay",
  password: "S@R!t2024", // Replace with your actual password
  database: "postgres",
  port: 5432,
  ssl: {
    ca: fs.readFileSync("C:\Users\sari_\Desktop\AI Business\SaaS\Postgre Database Dev\azure configuration\BaltimoreCyberTrustRoot.crt.pem") // Replace with the path to your CA certificate file
  }
});

// Connect to PostgreSQL
client.connect(err => {
  if (err) {
    console.error('Connection error:', err.stack);
  } else {
    console.log('Connected to PostgreSQL database');
  }
});

app.use(express.json());

// Example endpoint to get data
app.get('/api/parts', async (req, res) => {
  try {
    const result = await client.query('SELECT * FROM parts');
    res.json(result.rows);
  } catch (err) {
    console.error('Error executing query:', err.stack);
    res.status(500).send('Server error');
  }
});

// Example endpoint to add data
app.post('/api/parts', async (req, res) => {
  const { name, description } = req.body;
  try {
    const result = await client.query(
      'INSERT INTO parts (name, description) VALUES ($1, $2) RETURNING *',
      [name, description]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error executing query:', err.stack);
    res.status(500).send('Server error');
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
