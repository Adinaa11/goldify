const axios = require('axios');

async function getAllHistoricalData() {
  const response = await axios.get(
    'https://www.newsmaker.id/api/historical-data',
    {
      timeout: 20000,
      headers: {
        Accept: 'application/json',
      },
    }
  );

  const payload = response.data;
  let allData = [];

  if (Array.isArray(payload)) {
    allData = payload;
  } else if (Array.isArray(payload?.data)) {
    allData = payload.data;
  } else if (Array.isArray(payload?.data?.data)) {
    allData = payload.data.data;
  }

  console.log('Jumlah data Newsmaker:', allData.length);

  return allData.filter(
    (item) =>
      item &&
      item.category &&
      item.tanggal
  );
}

function normalizeCategory(category) {
  const value = String(category || '')
    .trim()
    .toLowerCase();

  if (value === 'lgd daily') return 'lgd daily';

  if (
    value === 'hsi daily' ||
    value === 'hsi — hang seng hong kong' ||
    value === 'hsi - hang seng hong kong' ||
    value === 'hang seng hong kong'
  ) {
    return 'hsi daily';
  }

  if (
    value === 'sni' ||
    value === 'sni daily' ||
    value === 'sni — nikkei jepang' ||
    value === 'sni - nikkei jepang' ||
    value === 'nikkei daily' ||
    value === 'nikkei jepang' ||
    value === 'nikkei japan' ||
    value === 'nikkei'
  ) {
    return 'sni';
  }

  return value;
}

async function getHistoricalDataByCategory(category) {
  const allData = await getAllHistoricalData();
  const requested = normalizeCategory(category);

  const filtered = allData.filter(
    (item) => normalizeCategory(item.category) === requested
  );

  filtered.sort((a, b) =>
    String(b.tanggal).localeCompare(String(a.tanggal))
  );

  console.log(
    `Jumlah data ${requested}:`,
    filtered.length
  );

  return filtered;
}

async function getGoldHistoricalData() {
  return getHistoricalDataByCategory('LGD Daily');
}

async function getHangsengHistoricalData() {
  return getHistoricalDataByCategory('HSI Daily');
}

async function getSniHistoricalData() {
  return getHistoricalDataByCategory('SNI');
}

module.exports = {
  getAllHistoricalData,
  getGoldHistoricalData,
  getHangsengHistoricalData,
  getSniHistoricalData,
  getHistoricalDataByCategory,
};