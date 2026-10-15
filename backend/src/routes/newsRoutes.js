
const express = require('express');
const router = express.Router();

const { getMarketNews } = require('../services/newsService');

router.get('/', async (req, res) => {
  try {
    const news = await getMarketNews();

    res.json({
      success: true,
      total: news.length,
      data: news,
    });
  } catch (error) {
    console.error('Gagal memuat Market News:', error.message);

    res.status(500).json({
      success: false,
      message: 'Gagal memuat berita pasar.',
    });
  }
});

module.exports = router;