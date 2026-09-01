const axios = require('axios');

async function getGoldHistoricalData() {
  const response = await axios.get(
    'https://www.newsmaker.id/api/historical-data'
  );

  console.log(
    'HASIL DARI NEWSMAKER:',
    JSON.stringify(response.data, null, 2)
  );

  // NEWSMAKER BISA MENGEMBALIKAN DATA DALAM BEBERAPA BENTUK.
  // Kita cek satu per satu supaya backend tetap aman.

  let allData = [];

  if (Array.isArray(response.data)) {
    // Jika response langsung berupa array
    allData = response.data;
  } else if (Array.isArray(response.data?.data)) {
    // Jika response berbentuk { data: [...] }
    allData = response.data.data;
  } else if (Array.isArray(response.data?.data?.data)) {
    // Jika response berbentuk { data: { data: [...] } }
    allData = response.data.data.data;
  }

  console.log(
    'JUMLAH DATA NEWSMAKER:',
    allData.length
  );

  const goldData = allData.filter(
    (item) =>
      item.category &&
      item.category.trim().toLowerCase() === 'lgd daily'
  );

  console.log(
    'JUMLAH DATA LGD DAILY:',
    goldData.length
  );

  return goldData;
}

module.exports = {
  getGoldHistoricalData,
};