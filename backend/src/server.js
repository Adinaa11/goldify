const express = require('express');
const cors = require('cors');
require('dotenv').config();

const marketRoutes = require('./routes/marketRoutes');
const newsRoutes = require('./routes/newsRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Goldify Backend berhasil berjalan',
  });
});

app.use('/api/market', marketRoutes);
app.use('/api/news', newsRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(
    `Goldify Backend berjalan di http://0.0.0.0:${PORT}`
  );
});