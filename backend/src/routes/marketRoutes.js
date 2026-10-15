const express = require('express');
const router = express.Router();

const {
  getGoldHistoricalData,
  getHangsengHistoricalData,
  getSniHistoricalData,
} = require('../services/marketService');

// Endpoint data historis berdasarkan kategori
async function handleHistoricalRoute(req, res, getData, label) {
  try {
    const data = await getData();

    if (data.length === 0) {
      return res.status(404).json({
        success: false,
        message: `Data historis ${label} tidak tersedia`,
      });
    }

    const selectedDate = req.query.date;

    if (selectedDate) {
      const selectedData = data.find(
        (item) => item.tanggal === selectedDate
      );

      if (!selectedData) {
        return res.status(404).json({
          success: false,
          message: `Data ${label} untuk tanggal ${selectedDate} tidak ditemukan`,
        });
      }

      return res.json({
        success: true,
        data: selectedData,
      });
    }

    // all=true mengembalikan seluruh data historis
    if (req.query.all === 'true') {
      return res.json({
        success: true,
        total: data.length,
        data,
      });
    }

    // Default: hanya data terbaru
    const latestData = data.reduce((latest, current) => {
      return new Date(current.tanggal) > new Date(latest.tanggal)
        ? current
        : latest;
    });

    return res.json({
      success: true,
      data: latestData,
    });
  } catch (error) {
    console.error(`Gagal mengambil data ${label}:`, error.message);

    return res.status(500).json({
      success: false,
      message: `Gagal mengambil data historis ${label}`,
    });
  }
}

// Emas
router.get('/gold', (req, res) =>
  handleHistoricalRoute(
    req,
    res,
    getGoldHistoricalData,
    'emas'
  )
);

// Hangseng
router.get('/hangseng', (req, res) =>
  handleHistoricalRoute(
    req,
    res,
    getHangsengHistoricalData,
    'Hangseng'
  )
);

// Nikkei / SNI
router.get('/sni', (req, res) =>
  handleHistoricalRoute(
    req,
    res,
    getSniHistoricalData,
    'Nikkei'
  )
);

module.exports = router;