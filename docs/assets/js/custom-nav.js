(function () {
  function normalize(path) {
    return path.replace(/\/+$/, '') || '/';
  }

  function run() {
    var links = document.querySelectorAll('.site-nav .nav-list .nav-list-link');
    if (!links.length) return;

    var allowed = new Set([
      '/Azazel',
      '/Azazel/philosophy',
      '/Azazel/concepts/system-overview.html',
      '/Azazel/products',
      '/Azazel/architecture/overview.html',
      '/Azazel/specs/naming.html',
      '/Azazel/about/credits.html'
    ].map(normalize));

    links.forEach(function (a) {
      try {
        var p = normalize(new URL(a.href, window.location.origin).pathname);
        var li = a.closest('.nav-list-item');
        if (li && !allowed.has(p)) {
          li.style.display = 'none';
        }
      } catch (e) {
        // noop
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', run);
  } else {
    run();
  }
})();
