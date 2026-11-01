(function () {
  var KEY = 'zhizhan-lang';

  function normalize(value) {
    return value === 'en' ? 'en' : 'zh';
  }

  function initial() {
    var query = new URLSearchParams(location.search).get('lang');
    if (query) return normalize(query);
    try {
      var saved = localStorage.getItem(KEY);
      if (saved) return normalize(saved);
    } catch (e) {}
    return (navigator.language || 'zh').toLowerCase().indexOf('zh') === 0 ? 'zh' : 'en';
  }

  function apply(lang) {
    lang = normalize(lang);
    document.documentElement.setAttribute('data-lang', lang);
    document.documentElement.lang = lang === 'zh' ? 'zh-CN' : 'en';

    try { localStorage.setItem(KEY, lang); } catch (e) {}

    document.querySelectorAll('[data-set-lang]').forEach(function (button) {
      var active = button.getAttribute('data-set-lang') === lang;
      button.classList.toggle('active', active);
      button.setAttribute('aria-pressed', active ? 'true' : 'false');
    });

    var body = document.body;
    if (body) {
      if (body.dataset.titleZh) {
        document.title = lang === 'zh' ? body.dataset.titleZh : (body.dataset.titleEn || body.dataset.titleZh);
      }
      var meta = document.querySelector('meta[name="description"]');
      if (meta && body.dataset.descZh) {
        meta.setAttribute('content', lang === 'zh' ? body.dataset.descZh : (body.dataset.descEn || body.dataset.descZh));
      }
    }

    document.querySelectorAll('a[data-lang-link]').forEach(function (link) {
      try {
        var url = new URL(link.getAttribute('href'), location.href);
        url.searchParams.set('lang', lang);
        link.setAttribute('href', url.pathname.split('/').pop() + url.search);
      } catch (e) {}
    });
  }

  window.setSiteLang = function (lang) {
    apply(lang);
    try {
      var url = new URL(location.href);
      url.searchParams.set('lang', normalize(lang));
      history.replaceState(null, '', url);
    } catch (e) {}
  };

  apply(initial());

  document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('[data-set-lang]').forEach(function (button) {
      button.addEventListener('click', function () {
        window.setSiteLang(button.getAttribute('data-set-lang'));
      });
    });
    apply(document.documentElement.getAttribute('data-lang') || initial());
  });
})();
