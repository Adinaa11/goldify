const express = require('express');
const router = express.Router();

const {
  getGoldHistoricalData,
} = require('../services/marketService');

router.get('/gold', async (req, res) => {
  try {
    const data = await getGoldHistoricalData();

    // Ambil tanggal dari URL jika diberikan
    const selectedDate = req.query.date;

    // Jika user memilih tanggal
    if (selectedDate) {
      const selectedData = data.find(
        (item) => item.tanggal === selectedDate
      );

      if (!selectedData) {
        return res.status(404).json({
          success: false,
          message: `Data LGD Daily untuk tanggal ${selectedDate} tidak ditemukan`,
        });
      }

      return res.json({
        success: true,
        data: selectedData,
      });
    }

    // Jika tidak memilih tanggal,
    // ambil data dengan tanggal paling baru
    const latestData = data.reduce((latest, current) => {
      return new Date(current.tanggal) > new Date(latest.tanggal)
        ? current
        : latest;
    });

    res.json({
      success: true,
      data: latestData,
    });

  } catch (error) {
    console.error('Gagal mengambil data emas:', error.message);

    res.status(500).json({
      success: false,
      message: 'Gagal mengambil data historical gold',
    });
  }
});

module.exports = router;