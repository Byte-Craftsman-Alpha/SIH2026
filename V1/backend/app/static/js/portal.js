// MediKiosk Doctor Portal JavaScript helpers

console.log("MediKiosk Clinical Portal initialized");

// Check server status periodically
async function checkServerHealth() {
  try {
    const res = await fetch('/api/v1/health');
    const data = await res.json();
    if (data.status === 'ok') {
      // online
    }
  } catch (e) {
    console.warn("Backend connection paused:", e);
  }
}

setInterval(checkServerHealth, 30000);
