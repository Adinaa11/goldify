
const Parser = require('rss-parser');

const parser = new Parser({
  timeout: 15000,
});

const RSS_URL =
  'https://www.bloomberg.com/feeds/markets/news.rss';

async function main() {
  try {
    const feed = await parser.parseURL(RSS_URL);

    console.log('Nama sumber:', feed.title);
    console.log('Jumlah berita:', feed.items.length);

    feed.items.slice(0, 5).forEach((item, index) => {
      console.log(`\nBerita ${index + 1}`);
      console.log('Judul:', item.title);
      console.log('Ringkasan:', item.contentSnippet);
      console.log('Link:', item.link);
      console.log('Tanggal:', item.pubDate);
    });
  } catch (error) {
    console.error('RSS gagal dibaca:', error.message);
  }
}

main();