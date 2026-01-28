// Simple SSE demo server
// Usage: node scripts/sse_server.js

const http = require('http');

const clients = new Set();

function sendEvent(res, data){
  res.write(`data: ${JSON.stringify(data)}\n\n`);
}

const server = http.createServer((req,res)=>{
  if (req.url === '/sse'){
    // set headers for SSE
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      Connection: 'keep-alive',
      'Access-Control-Allow-Origin': '*'
    });
    res.write('\n');
    clients.add(res);
    req.on('close', ()=>{ clients.delete(res); });
  } else if (req.url === '/sse.json'){
    // simple JSON polling endpoint
    res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
    const payload = generatePayload();
    res.end(JSON.stringify(payload));
  } else {
    res.writeHead(404);
    res.end('Not found');
  }
});

function generatePayload(){
  // demo announcement rotation and visitors count
  const announcements = [
    'Open day next Saturday — register now!',
    'New STEM after-school clubs launching this term.',
    'School choir performing on Friday at 6pm.'
  ];
  const announcement = announcements[Math.floor(Math.random()*announcements.length)];
  const visitors = 20 + Math.floor(Math.random()*80);
  return { announcement, visitors };
}

function broadcast(){
  const payload = generatePayload();
  for (const res of clients){
    try{ sendEvent(res, payload); } catch(e){ clients.delete(res); }
  }
}

const PORT = process.env.SSE_PORT || 5000;
server.listen(PORT, ()=>{
  console.log(`SSE demo server listening on http://localhost:${PORT}`);
});

// Broadcast every 4 seconds
setInterval(broadcast, 4000);
