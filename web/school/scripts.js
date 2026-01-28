document.addEventListener('DOMContentLoaded', function(){
  // set current year
  const y = new Date().getFullYear();
  const yearEl = document.getElementById('year');
  if(yearEl) yearEl.textContent = y;

  // basic mobile menu toggle
  const toggle = document.querySelector('.menu-toggle');
  const nav = document.querySelector('.site-nav');
  if(toggle && nav){
    toggle.addEventListener('click', ()=>{
      const expanded = toggle.getAttribute('aria-expanded') === 'true';
      toggle.setAttribute('aria-expanded', String(!expanded));
      nav.style.display = expanded ? '' : 'flex';
    });
  }

  // Smooth GPU-accelerated parallax using transform and lerp
  const parallaxEls = Array.from(document.querySelectorAll('.parallax'))
    .map(el => ({ el, speed: parseFloat(el.dataset.speed) || 0.4, y: 0, target: 0 }));

  function lerp(a,b,t){ return a + (b-a)*t; }

  function updateParallax(){
    const scrollY = window.pageYOffset || document.documentElement.scrollTop;
    parallaxEls.forEach(item=>{
      // target offset for this element (relative to page)
      const rect = item.el.getBoundingClientRect();
      const elTop = rect.top + scrollY;
      // compute relative distance from viewport center
      const centerOffset = (scrollY + (window.innerHeight/2)) - (elTop + rect.height/2);
      const target = centerOffset * item.speed * 0.08; // scale down for subtle effect
      item.target = target;
      item.y = lerp(item.y, item.target, 0.12);
      // apply transform for smoother, GPU-accelerated animation
      item.el.style.transform = `translate3d(0, ${item.y}px, 0)`;
      // make sure the overlay and children remain readable
    });
    requestAnimationFrame(updateParallax);
  }
  requestAnimationFrame(updateParallax);

  // Expose a lightweight API to add parallax layers dynamically if needed
  window.__addParallax = function(selector, speed){
    document.querySelectorAll(selector).forEach(el=>{
      parallaxEls.push({ el, speed: speed||0.4, y:0, target:0 });
    });
  }

  // Live updates via Server-Sent Events (SSE) - graceful fallback to polling
  const announcementEl = document.getElementById('live-announcement');
  const visitorsEl = document.getElementById('live-visitors');

  function connectSSE(){
    if (!window.EventSource) return startPolling();
    // adjust URL if hosted elsewhere; default demo server at /sse
    const url = (location.hostname === 'localhost' || location.hostname === '127.0.0.1') ? 'http://localhost:5000/sse' : '/sse';
    const es = new EventSource(url);
    es.onopen = () => console.info('SSE connected');
    es.onmessage = (ev) => {
      try{
        const data = JSON.parse(ev.data);
        if (data.announcement) announcementEl.textContent = data.announcement;
        if (typeof data.visitors !== 'undefined') visitorsEl.textContent = data.visitors;
      }catch(e){ console.warn('Invalid SSE payload', e); }
    };
    es.onerror = (err) => {
      console.warn('SSE error, falling back to polling', err);
      es.close();
      startPolling();
    };
  }

  let pollInterval = null;
  function startPolling(){
    // fallback polling endpoint; user must host a JSON endpoint at /sse.json for polling
    async function poll(){
      try{
        const url = (location.hostname === 'localhost' || location.hostname === '127.0.0.1') ? 'http://localhost:5000/sse.json' : '/sse.json';
        const r = await fetch(url, {cache: 'no-cache'});
        if (!r.ok) throw new Error('poll failed');
        const data = await r.json();
        if (data.announcement) announcementEl.textContent = data.announcement;
        if (typeof data.visitors !== 'undefined') visitorsEl.textContent = data.visitors;
      }catch(e){ console.debug('Polling error', e); }
    }
    poll();
    pollInterval = setInterval(poll, 4000);
  }

  // Start SSE with fallback
  connectSSE();
});
