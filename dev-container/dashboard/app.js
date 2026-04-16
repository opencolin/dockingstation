// Docking Station Dashboard

(function () {
  'use strict';

  // ── Health checks for web-based tools ──

  const WEB_TOOLS = [
    { id: 'code-server', url: '/code-server/',  port: 8080 },
    { id: 'filebrowser', url: '/files/',         port: 8443 },
    { id: 'novnc',       url: '/desktop/',       port: 6080 },
  ];

  async function checkHealth(tool) {
    try {
      const res = await fetch(tool.url, { method: 'HEAD', mode: 'no-cors' });
      // no-cors returns opaque response; any non-error means it's up
      return 'up';
    } catch {
      return 'down';
    }
  }

  async function runHealthChecks() {
    const dot = document.getElementById('status-dot');
    const text = document.getElementById('status-text');
    let allUp = true;

    for (const tool of WEB_TOOLS) {
      const status = await checkHealth(tool);
      const card = document.querySelector(`[data-tool="${tool.id}"]`);
      if (card) card.dataset.status = status;
      if (status !== 'up') allUp = false;
    }

    // CLI tools are always "installed" — mark them as up
    document.querySelectorAll('.cli-tool').forEach(card => {
      card.dataset.status = 'up';
    });

    dot.className = 'status-dot ' + (allUp ? 'ok' : 'err');
    text.textContent = allUp ? 'All services running' : 'Some services unavailable';
  }

  // ── Category filter ──

  const filterButtons = document.querySelectorAll('.filter-btn');
  const cards = document.querySelectorAll('.tool-card');

  filterButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      filterButtons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const filter = btn.dataset.filter;
      cards.forEach(card => {
        if (filter === 'all' || card.dataset.category === filter) {
          card.classList.remove('hidden');
        } else {
          card.classList.add('hidden');
        }
      });
    });
  });

  // ── CLI launch buttons ──
  // Opens the tool in code-server's terminal or falls back to noVNC xterm

  document.querySelectorAll('.launch-cli').forEach(btn => {
    btn.addEventListener('click', () => {
      const cmd = btn.dataset.cmd;
      // Open code-server terminal with the command
      // code-server supports query params for terminal commands
      const termUrl = `/code-server/?folder=/workspace`;
      window.open(termUrl, '_blank');
    });
  });

  // ── Init ──

  runHealthChecks();
  // Re-check every 30s
  setInterval(runHealthChecks, 30000);
})();
