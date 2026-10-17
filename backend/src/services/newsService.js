
const Parser = require('rss-parser');

const parser = new Parser({
  timeout: 15000,
  customFields: {
    item: [
      ['media:content', 'mediaContent'],
      ['media:thumbnail', 'mediaThumbnail'],
      ['enclosure', 'enclosure'],
      ['content:encoded', 'contentEncoded'],
    ],
  },
});

// Sumber berita pasar
const RSS_FEEDS = [
  {
    source: 'Bloomberg',
    url: 'https://www.bloomberg.com/feeds/markets/news.rss',
  },
  {
    source: 'CNBC',
    url: 'https://www.cnbc.com/id/100003114/device/rss/rss.html',
  },
  {
    source: 'Google News - Emas',
    url: 'https://news.google.com/rss/search?q=gold+OR+XAU+OR+bullion+when:7d&hl=en-US&gl=US&ceid=US:en',
  },
  {
    source: 'Google News - Forex',
    url: 'https://news.google.com/rss/search?q=forex+OR+currency+OR+exchange+rate+when:7d&hl=en-US&gl=US&ceid=US:en',
  },
  {
    source: 'Google News - Indeks Saham',
    url: 'https://news.google.com/rss/search?q=stock+index+OR+Nasdaq+OR+Hang+Seng+OR+Nikkei+OR+S%26P+500+when:7d&hl=en-US&gl=US&ceid=US:en',
  },
  {
    source: 'Google News - Reuters',
    url: 'https://news.google.com/rss/search?q=site%3Areuters.com+gold+OR+forex+OR+stock+index+when:7d&hl=en-US&gl=US&ceid=US:en',
  },
  {
    source: 'CNBC Indonesia',
    url: 'https://www.cnbcindonesia.com/market/rss',
  },
  {
    source: 'CNN Indonesia',
    url: 'https://www.cnnindonesia.com/ekonomi/rss',
  },
    {
    source: 'Google News - Indonesia',
    url: 'https://news.google.com/rss/search?q=(IHSG+OR+rupiah+OR+%22harga+emas%22+OR+%22bursa+saham%22)+when:7d&hl=id&gl=ID&ceid=ID:id',
  },
  {
    source: 'Google News - Ekonomi Indonesia',
    url: 'https://news.google.com/rss/search?q=(ekonomi+OR+investasi+OR+pasar+modal+OR+kurs+rupiah)+when:7d&hl=id&gl=ID&ceid=ID:id',
  },
   {
    source: 'Kontan',
    url: 'https://news.google.com/rss/search?q=site%3Akontan.co.id+(emas+OR+forex+OR+saham)&hl=id&gl=ID&ceid=ID:id',
  },
  {
    source: 'Bisnis Indonesia',
    url: 'https://news.google.com/rss/search?q=site%3Abisnis.com+(emas+OR+rupiah+OR+saham)&hl=id&gl=ID&ceid=ID:id',
  },
];

const MARKET_KEYWORDS = [
  'gold price', 'gold prices', 'gold futures', 'spot gold',
  'gold market', 'gold climbs', 'gold falls', 'gold rises',
  'gold drops', 'gold rally', 'gold selloff', 'xauusd',
  'xau/usd', 'bullion prices', 'precious metals prices',
  'forex market', 'foreign exchange', 'currency market',
  'exchange rate', 'exchange rates', 'currency pair',
  'currency pairs', 'us dollar', 'dollar index',
  'rupiah exchange rate', 'usd/idr', 'eur/usd',
  'gbp/usd', 'usd/jpy', 'stock index', 'stock indices',
  'stock market index', 'index futures', 'hang seng',
  'nasdaq composite', 'nasdaq 100', 's&p 500',
  'dow jones', 'nikkei 225', 'kospi index', 'ihsg',
  'idx composite', 'ftse 100', 'dax index',
  'harga emas',
  'emas antam',
  'emas dunia',
  'logam mulia',
  'harga emas hari ini',
  'harga emas naik',
  'harga emas turun',
  'kurs rupiah',
  'nilai tukar',
  'dolar as',
  'mata uang',
  'pasar valuta asing',
  'pasar saham',
  'indeks saham',
  'indeks harga saham gabungan',
  'bursa saham',
  'harga komoditas',
];

// Gambar alternatif berdasarkan kategori.
// URL gambar ini adalah ilustrasi, bukan foto asli artikel.
const FALLBACK_IMAGES = {
  gold: [
    'https://images.unsplash.com/photo-1610375461246-83df859d849d?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1610375461369-d613b564f4c4?auto=format&fit=crop&w=1200&q=80',
  ],
  forex: [
    'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1563013544-824ae1b704d3?auto=format&fit=crop&w=1200&q=80',
  ],
  stocks: [
    'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?auto=format&fit=crop&w=1200&q=80',
  ],
};

// Memastikan URL gambar valid dan bukan thumbnail Google News.
function isUsableImageUrl(value) {
  if (typeof value !== 'string' || !value.trim()) {
    return false;
  }

  try {
    const parsed = new URL(value.trim());

    if (!['http:', 'https:'].includes(parsed.protocol)) {
      return false;
    }

    const host = parsed.hostname.toLowerCase();

    if (
      host === 'googleusercontent.com' ||
      host.endsWith('.googleusercontent.com')
    ) {
      return false;
    }

    return true;
  } catch (error) {
    return false;
  }
}

function findImageUrl(value) {
  if (!value) return null;

  if (typeof value === 'string') {
    const url = value.trim();
    return isUsableImageUrl(url) ? url : null;
  }

  if (Array.isArray(value)) {
    for (const entry of value) {
      const found = findImageUrl(entry);
      if (found) return found;
    }

    return null;
  }

  if (typeof value === 'object') {
    const attrs = value.$ || value;

    for (const key of ['url', 'href', 'src']) {
      const url = attrs[key];

      if (isUsableImageUrl(url)) {
        return url.trim();
      }
    }

    for (const key of Object.keys(value)) {
      const found = findImageUrl(value[key]);
      if (found) return found;
    }
  }

  return null;
}

// Mencari gambar yang tersedia di data RSS.
function extractImage(item) {
  const rssImage =
    findImageUrl(item.enclosure) ||
    findImageUrl(item.mediaContent) ||
    findImageUrl(item.mediaThumbnail);

  if (rssImage) return rssImage;

  const html = String(
    item.contentEncoded ||
    item.content ||
    item.description ||
    ''
  );

  const match = html.match(
    /<img\b[^>]*\bsrc\s*=\s*["']([^"']+)["']/i
  );

  if (match && isUsableImageUrl(match[1])) {
    return match[1];
  }

  return null;
}

// Mengambil gambar utama dari halaman artikel.
async function fetchArticleImage(articleUrl) {
  if (!articleUrl) return null;

  try {
    const response = await fetch(articleUrl, {
      headers: {
        'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/130.0.0.0 Safari/537.36',
        Accept: 'text/html,application/xhtml+xml',
      },
      signal: AbortSignal.timeout(5000),
      redirect: 'follow',
    });

    if (!response.ok) return null;

    const contentType =
      response.headers.get('content-type') || '';

    if (!contentType.toLowerCase().includes('text/html')) {
      return null;
    }

    const html = await response.text();
    const metaTags = html.match(/<meta\b[^>]*>/gi) || [];

    // Dahulukan og:image, kemudian twitter:image.
    for (const wantedProperty of ['og:image', 'twitter:image']) {
      for (const tag of metaTags) {
        const property = tag.match(
          /\b(?:property|name)\s*=\s*["']([^"']+)["']/i
        )?.[1]?.toLowerCase();

        if (property !== wantedProperty) continue;

        const content = tag.match(
          /\bcontent\s*=\s*["']([^"']+)["']/i
        )?.[1];

        if (isUsableImageUrl(content)) {
          return content.trim();
        }
      }
    }

    return null;
  } catch (error) {
    // Sebagian situs menolak permintaan otomatis atau terlalu lambat.
    return null;
  }
}

// Menentukan kategori berita dari judul, ringkasan, dan sumber.
function getNewsCategory(article) {
  const text = (
    `${article.title || ''} ${article.summary || ''} ${article.source || ''}`
  ).toLowerCase();

  const goldKeywords = [
    'gold', 'bullion', 'xau', 'precious metal',
    'emas', 'gold price',
  ];

  const stockKeywords = [
    'stock index', 'stock market', 'nasdaq', 's&p 500',
    'dow jones', 'hang seng', 'nikkei', 'kospi',
    'ihsg', 'idx composite', 'ftse 100', 'dax index',
    'equity market', 'share market', 'stock futures',
  ];

  const forexKeywords = [
    'forex', 'currency', 'exchange rate', 'eur/usd',
    'gbp/usd', 'usd/jpy', 'usd/idr', 'dollar index',
    'foreign exchange', 'pound to dollar', 'rupiah',
  ];

  if (goldKeywords.some((keyword) => text.includes(keyword))) {
    return 'gold';
  }

  if (stockKeywords.some((keyword) => text.includes(keyword))) {
    return 'stocks';
  }

  if (forexKeywords.some((keyword) => text.includes(keyword))) {
    return 'forex';
  }

  // Jika kategori tidak dikenali, gunakan ilustrasi pasar saham.
  return 'stocks';
}

// Pilih gambar alternatif secara konsisten berdasarkan kategori dan judul.
function getFallbackImage(article) {
  const category = getNewsCategory(article);
  const images = FALLBACK_IMAGES[category];
  const text = article.title || article.link || category;

  let hash = 0;

  for (let i = 0; i < text.length; i++) {
    hash = (hash * 31 + text.charCodeAt(i)) >>> 0;
  }

  return images[hash % images.length];
}

async function fetchFeed(feedConfig) {
  try {
    const feed = await parser.parseURL(feedConfig.url);

    return feed.items.map((item) => ({
      title: item.title || 'Tanpa judul',
      summary: item.contentSnippet || item.content || '',
      link: item.link || '',
      imageUrl: extractImage(item),
      publishedAt: item.isoDate || item.pubDate || null,
      source: feedConfig.source,
    }));
  } catch (error) {
    console.error(
      `Gagal mengambil RSS ${feedConfig.source}:`,
      error.message
    );

    return [];
  }
}

function isRelevantMarketNews(article) {
  const text =
    `${article.title || ''} ${article.summary || ''}`.toLowerCase();

  const hasRelevantKeyword = MARKET_KEYWORDS.some(
    (keyword) => text.includes(keyword)
  );

  const excludeKeywords = [
    'gold mine',
    'gold mining',
    'gold mine investment',
    'buried gold',
    'gold rush',
    'gold medal',
    'gold award',
    'gold medalist',
    'gold-winning',
    'gold mining company',
    'coal mine',
    'metallurgical coal',
    'mining community',
  ];

  const hasExcludedKeyword = excludeKeywords.some(
    (keyword) => text.includes(keyword)
  );

  return hasRelevantKeyword && !hasExcludedKeyword;
}


function getNewsRegion(article) {
  const source = (article.source || '').toLowerCase();
  const link = (article.link || '').toLowerCase();
  const text =
    `${article.title || ''} ${article.summary || ''}`.toLowerCase();

  const indonesiaSources = [
    'cnbc indonesia',
    'cnn indonesia',
    'google news - indonesia',
    'google news - ekonomi indonesia',
    'kontan',
    'bisnis indonesia',
  ];

  const indonesiaDomains = [
    'cnnindonesia.com',
    'detik.com',
    'kompas.com',
    'kontan.co.id',
    'bisnis.com',
    'cnbcindonesia.com',
    'tempo.co',
    'liputan6.com',
    'antaranews.com',
    'idxchannel.com',
    'investor.id',
    'idnfinancials.com',
    'republika.co.id',
  ];

  if (
    indonesiaSources.some((name) => source.includes(name)) ||
    indonesiaDomains.some(
      (domain) =>
        source.includes(domain) || link.includes(domain),
    )
  ) {
    return 'indonesia';
  }

  const indonesiaKeywords = [
    'ihsg',
    'rupiah',
    'bursa efek indonesia',
    'indeks harga saham gabungan',
    'bank indonesia',
    'ekonomi indonesia',
    'saham indonesia',
    'emas antam',
  ];

  if (indonesiaKeywords.some((keyword) => text.includes(keyword))) {
    return 'indonesia';
  }

  return 'global';
}

async function getMarketNews() {
  const results = await Promise.all(
    RSS_FEEDS.map((feed) => fetchFeed(feed)),
  );

  const allNews = results.flat();
  const filteredNews = allNews.filter(isRelevantMarketNews);

  const uniqueNews = Array.from(
    new Map(
      filteredNews
        .filter((article) => article.link)
        .map((article) => [article.link, article]),
    ).values(),
  );

  // Urutkan berita terbaru terlebih dahulu.
  uniqueNews.sort((a, b) => {
    const dateA = a.publishedAt
      ? new Date(a.publishedAt).getTime()
      : 0;

    const dateB = b.publishedAt
      ? new Date(b.publishedAt).getTime()
      : 0;

    return dateB - dateA;
  });

  // Maksimal 8 berita per tanggal untuk setiap kategori.
  const MAX_NEWS_PER_DAY = 8;
  const newsPerDay = new Map();
  const newsToReturn = [];

  for (const article of uniqueNews) {
    if (!article.publishedAt) continue;

    const date = new Date(article.publishedAt);

    if (Number.isNaN(date.getTime())) continue;

    const dayKey = date.toISOString().slice(0, 10);
    const region = getNewsRegion(article);
    const counterKey = `${region}:${dayKey}`;
    const currentCount = newsPerDay.get(counterKey) || 0;

    if (currentCount >= MAX_NEWS_PER_DAY) continue;

    newsPerDay.set(counterKey, currentCount + 1);

    newsToReturn.push({
      ...article,
      region,
    });
  }

  // Ambil gambar asli secara bertahap.
  for (let i = 0; i < newsToReturn.length; i += 5) {
    const batch = newsToReturn.slice(i, i + 5);

    await Promise.all(
      batch.map(async (article) => {
        const originalImage = await fetchArticleImage(article.link);

        if (isUsableImageUrl(originalImage)) {
          article.imageUrl = originalImage;
        }
      }),
    );
  }

  // Gunakan gambar alternatif jika gambar asli tidak tersedia.
  for (const article of newsToReturn) {
    if (!isUsableImageUrl(article.imageUrl)) {
      article.imageUrl = getFallbackImage(article);
    }
  }

  console.log('Total berita:', newsToReturn.length);
  console.log(
    'Jumlah Global:',
    newsToReturn.filter((item) => item.region === 'global').length,
  );
  console.log(
    'Jumlah Indonesia:',
    newsToReturn.filter((item) => item.region === 'indonesia').length,
  );

  return newsToReturn;
}

module.exports = { getMarketNews };