# Stellar Academy — Static Website

This folder contains a clean, corporate-style static website scaffold for a school.

Files
- `index.html` — main page with semantic sections and parallax strips
- `styles.css` — layout, colors, responsive and parallax visuals
- `scripts.js` — small JS for parallax scrolling and mobile menu

Preview locally

PowerShell (from repository root):

```powershell
cd web\school
# open directly in default browser
Start-Process .\index.html

# OR run a simple static server (recommended for testing JS features):
# Python 3: python -m http.server 8000
python -m http.server 8000
# then open http://localhost:8000 in your browser
```

Live updates (demo)

This site supports real-time updates via Server-Sent Events (SSE). A small demo server is included at `scripts/sse_server.js`.

To run the demo SSE server (requires Node.js):

```powershell
# from repository root
node .\scripts\sse_server.js
```

Then open the site with the static server (recommended) and the page will connect to `http://localhost:5000/sse` and display announcements and a live visitor count.

If EventSource isn't available the page falls back to polling `http://localhost:5000/sse.json`.

Dummy images & data

This scaffold includes ready-to-use placeholder images and a sample data JSON to help you preview and test the site.

- Images: `web/school/assets/images/hero.svg`, `feature.svg`, `cta.svg`, `gallery1.svg`, `gallery2.svg`.
- Dummy data: `web/school/data/dummy.json` — contains `announcements`, `visitors`, `programs`, and `gallery` entries pointing to the images.

You can load the JSON from client-side code or replace the SVGs with production photos. To wire up the dummy JSON into the page for quick testing, open the browser console and run:

```javascript
fetch('/data/dummy.json').then(r=>r.json()).then(data=>{
	document.getElementById('live-announcement').textContent = data.announcements[0];
	document.getElementById('live-visitors').textContent = data.visitors;
});
```



Customizing
- Replace background placeholders in `styles.css` with real images (update `background-image`).
- Adjust colors in the `:root` at the top of `styles.css`.
- Hook the contact form to your backend by changing the `form` `action` and removing `onsubmit="return false;"`.

Deployment
- Upload the folder contents to any static host (Hostinger, Netlify, GitHub Pages, S3 + CloudFront).
