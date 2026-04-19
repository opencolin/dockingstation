// Docking Station Dashboard

(function () {
  'use strict';

  // ── Health checks for web-based tools ──

  const WEB_TOOLS = [
    { id: 'code-server', url: '/code-server/',  port: 8080 },
    { id: 'filebrowser', url: '/files/',         port: 8443 },
    { id: 'novnc',       url: '/desktop/',       port: 6080 },
    { id: 'terminal',    url: '/terminal/',      port: 7681 },
    { id: 'safemode',    url: '/safemode/',      port: 80 },
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
    const statuses = new Map();

    for (const tool of WEB_TOOLS) {
      const status = await checkHealth(tool);
      statuses.set(tool.id, status);
      const card = document.querySelector(`[data-tool="${tool.id}"]`);
      if (card) card.dataset.status = status;
      if (status !== 'up') allUp = false;
    }

    const terminalUp = statuses.get('terminal') === 'up';
    document.querySelectorAll('.cli-tool').forEach(card => {
      card.dataset.status = terminalUp ? 'up' : 'down';
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
  // Opens the tool in the browser terminal

  document.querySelectorAll('.launch-cli').forEach(btn => {
    btn.addEventListener('click', () => {
      const cmd = btn.dataset.cmd;
      const termUrl = `/terminal/?arg=${encodeURIComponent(cmd)}`;
      window.open(termUrl, '_blank');
    });
  });

  // ── Init ──

  runHealthChecks();
  // Re-check every 30s
  setInterval(runHealthChecks, 30000);
})();
