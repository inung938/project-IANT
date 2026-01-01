const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;
const fs = require('fs');
const YAML = require('yaml');
const swaggerUi = require('swagger-ui-express');
const userRoutes = require('./routes/index');

const file = fs.readFileSync('./routes/doc.yaml', 'utf-8');
const swaggerDocument = YAML.parse(file);

app.use(cors());
app.use(express.json());

// Routes utama
app.use('/api/users', userRoutes);

// Swagger
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.get('/api/test', (req, res) => {
  res.json({ message: '✅ Backend connected successfully!' });
});

// app.listen(3000, '0.0.0.0')
app.listen(port, () => {
  console.log(file);
  console.log(`Server is running on http://localhost:${port}`);
});
