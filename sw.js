// Deixa o jogo abrir mesmo sem internet (atalho na tela de início).
// Busca sempre a versão nova na rede; se estiver offline, usa a cópia guardada.
const CACHE = 'laura-sobe-v1';
const ARQUIVOS = ['./', 'index.html', 'manifest.webmanifest', 'icone/icone-192.png', 'icone/icone-512.png', 'icone/apple-touch-icon.png',
  ...['pulando', 'abaixada', 'parada', 'ops'].map(n => 'img/' + n + '.png')];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ARQUIVOS)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET' || /\.(exe|apk)$/.test(new URL(e.request.url).pathname)) return;
  e.respondWith(
    fetch(e.request).then(r => {
      if (r.ok) { const copia = r.clone(); caches.open(CACHE).then(c => c.put(e.request, copia)); }
      return r;
    }).catch(() => caches.match(e.request, { ignoreSearch: true }))
  );
});
