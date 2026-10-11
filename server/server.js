/**
 * ETERNAL ABYSS: VOID'S LEGACY - DEDICATED GAME BACKEND & CLOUD SERVER
 * Built with native Node.js HTTP and persistent JSON datastore.
 * Supports: Player Auth, Cloud Save Sync, Global Leaderboard, World Boss Raid Pool.
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const PORT = process.env.PORT || 8787;
const HOST = process.env.HOST || '0.0.0.0';
const DATA_DIR = path.join(__dirname, 'data');

if (!fs.existsSync(DATA_DIR)) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
}

const PLAYERS_FILE = path.join(DATA_DIR, 'players.json');
const LEADERBOARD_FILE = path.join(DATA_DIR, 'leaderboard.json');
const RAID_FILE = path.join(DATA_DIR, 'raid.json');

function loadJson(file, defaultData) {
  try {
    if (fs.existsSync(file)) {
      return JSON.parse(fs.readFileSync(file, 'utf8'));
    }
  } catch (err) {
    console.error(`Error loading ${file}:`, err.message);
  }
  saveJson(file, defaultData);
  return defaultData;
}

function saveJson(file, data) {
  try {
    fs.writeFileSync(file, JSON.stringify(data, null, 2), 'utf8');
  } catch (err) {
    console.error(`Error saving ${file}:`, err.message);
  }
}

// Seed initial leaderboard with legends if empty
const defaultLeaderboard = [
  { rank: 1, player_id: "legend_01", name: "Long Thần Chi Tôn", max_floor: 4, max_dps: 3420, total_damage: 9800000, date: "2026-10-10" },
  { rank: 2, player_id: "legend_02", name: "Hư Không Kiếm Thánh", max_floor: 4, max_dps: 2890, total_damage: 7450000, date: "2026-10-09" },
  { rank: 3, player_id: "legend_03", name: "Bóng Đêm Tử Thần", max_floor: 3, max_dps: 1950, total_damage: 4200000, date: "2026-10-08" },
  { rank: 4, player_id: "legend_04", name: "Lôi Đình Cuồng Nộ", max_floor: 3, max_dps: 1680, total_damage: 3100000, date: "2026-10-07" },
  { rank: 5, player_id: "legend_05", name: "Thánh Khiên Hộ Quốc", max_floor: 2, max_dps: 1240, total_damage: 1850000, date: "2026-10-06" }
];

const defaultRaid = {
  world_boss_name: "Quái Vật Vĩnh Cửu - Siêu Cấp Hư Không",
  global_hp_max: 10000000,
  global_hp_current: 7850000,
  contributors_count: 142,
  recent_hits: []
};

let playersDb = loadJson(PLAYERS_FILE, {});
let leaderboardDb = loadJson(LEADERBOARD_FILE, defaultLeaderboard);
let raidDb = loadJson(RAID_FILE, defaultRaid);

function parseRequestBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
      if (body.length > 2 * 1024 * 1024) { // 2MB limit
        reject(new Error("Request payload too large"));
      }
    });
    req.on('end', () => {
      if (!body) return resolve({});
      try {
        resolve(JSON.parse(body));
      } catch (err) {
        resolve({});
      }
    });
    req.on('error', err => reject(err));
  });
}

function sendResponse(res, statusCode, data) {
  const payload = JSON.stringify(data);
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(payload),
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization'
  });
  res.end(payload);
}

const server = http.createServer(async (req, res) => {
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization'
    });
    res.end();
    return;
  }

  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = url.pathname;

  // 1. Health & Status
  if ((pathname === '/' || pathname === '/api/status' || pathname === '/health') && req.method === 'GET') {
    return sendResponse(res, 200, {
      status: "online",
      game: "Vực Thẳm Vĩnh Cửu: Di Sản Hư Không",
      subtitle: "Eternal Abyss: Void's Legacy",
      version: "1.2.0",
      server_time: new Date().toISOString(),
      active_players: Object.keys(playersDb).length,
      leaderboard_count: leaderboardDb.length
    });
  }

  // 2. Auth / Login (Guest or Registered)
  if (pathname === '/api/auth/login' && req.method === 'POST') {
    try {
      const body = await parseRequestBody(req);
      let playerId = body.player_id;
      let playerName = body.name || "Dũng Sĩ Hư Không";

      if (!playerId || playerId.trim() === "") {
        playerId = "hero_" + crypto.randomUUID().substring(0, 8);
      }

      if (!playersDb[playerId]) {
        playersDb[playerId] = {
          player_id: playerId,
          name: playerName,
          floor: 1,
          weapon: "wpn_sword_1",
          weapon_upgrade: 0,
          armor: "arm_leather_1",
          armor_upgrade: 0,
          ring: "ring_copper_1",
          inventory: { "wpn_sword_1": 1, "arm_leather_1": 1, "ring_copper_1": 1 },
          max_dps: 0,
          total_damage: 0,
          created_at: new Date().toISOString(),
          last_online: new Date().toISOString()
        };
      } else {
        playersDb[playerId].last_online = new Date().toISOString();
        if (body.name) playersDb[playerId].name = body.name;
      }

      saveJson(PLAYERS_FILE, playersDb);

      return sendResponse(res, 200, {
        success: true,
        player_id: playerId,
        token: crypto.createHash('sha256').update(playerId + "_secret_salt").digest('hex'),
        profile: playersDb[playerId]
      });
    } catch (err) {
      return sendResponse(res, 500, { success: false, error: err.message });
    }
  }

  // 3. Get Player Cloud Profile
  if (pathname === '/api/player/profile' && req.method === 'GET') {
    const playerId = url.searchParams.get('player_id');
    if (!playerId || !playersDb[playerId]) {
      return sendResponse(res, 404, { success: false, error: "Player not found" });
    }
    return sendResponse(res, 200, { success: true, profile: playersDb[playerId] });
  }

  // 4. Save / Sync Player Cloud Save
  if (pathname === '/api/player/save' && req.method === 'POST') {
    try {
      const body = await parseRequestBody(req);
      const playerId = body.player_id;
      if (!playerId) {
        return sendResponse(res, 400, { success: false, error: "Missing player_id" });
      }

      const existing = playersDb[playerId] || { player_id: playerId };
      playersDb[playerId] = {
        ...existing,
        name: body.name || existing.name || "Dũng Sĩ",
        floor: Math.max(existing.floor || 1, body.floor || 1),
        weapon: body.weapon || existing.weapon || "wpn_sword_1",
        weapon_upgrade: Math.max(existing.weapon_upgrade || 0, body.weapon_upgrade || 0),
        armor: body.armor || existing.armor || "arm_leather_1",
        armor_upgrade: Math.max(existing.armor_upgrade || 0, body.armor_upgrade || 0),
        ring: body.ring || existing.ring || "ring_copper_1",
        inventory: body.inventory || existing.inventory || {},
        max_dps: Math.max(existing.max_dps || 0, body.max_dps || 0),
        total_damage: Math.max(existing.total_damage || 0, body.total_damage || 0),
        last_online: new Date().toISOString()
      };

      saveJson(PLAYERS_FILE, playersDb);

      // Auto update leaderboard if stats qualified
      updateLeaderboardEntry(playersDb[playerId]);

      return sendResponse(res, 200, {
        success: true,
        message: "Cloud save synchronized successfully",
        updated_at: new Date().toISOString()
      });
    } catch (err) {
      return sendResponse(res, 500, { success: false, error: err.message });
    }
  }

  // 5. Global Leaderboard
  if (pathname === '/api/leaderboard' && req.method === 'GET') {
    return sendResponse(res, 200, {
      success: true,
      leaderboard: leaderboardDb.slice(0, 10),
      total_entries: leaderboardDb.length
    });
  }

  // 6. Submit Leaderboard Score
  if (pathname === '/api/leaderboard/submit' && req.method === 'POST') {
    try {
      const body = await parseRequestBody(req);
      const entry = updateLeaderboardEntry(body);
      return sendResponse(res, 200, {
        success: true,
        leaderboard: leaderboardDb.slice(0, 10),
        my_rank: entry ? entry.rank : -1
      });
    } catch (err) {
      return sendResponse(res, 500, { success: false, error: err.message });
    }
  }

  // 7. World Boss Raid Pool
  if (pathname === '/api/raid' && req.method === 'GET') {
    return sendResponse(res, 200, {
      success: true,
      raid: raidDb
    });
  }

  if (pathname === '/api/raid/damage' && req.method === 'POST') {
    try {
      const body = await parseRequestBody(req);
      const dmg = parseFloat(body.damage) || 0;
      const playerId = body.player_id || "anonymous";
      const playerName = body.name || "Dũng Sĩ";

      if (dmg > 0) {
        raidDb.global_hp_current = Math.max(0, raidDb.global_hp_current - dmg);
        raidDb.recent_hits.unshift({
          player: playerName,
          damage: dmg,
          timestamp: new Date().toISOString()
        });
        if (raidDb.recent_hits.length > 20) raidDb.recent_hits.pop();
        saveJson(RAID_FILE, raidDb);
      }

      return sendResponse(res, 200, {
        success: true,
        remaining_hp: raidDb.global_hp_current,
        total_hp: raidDb.global_hp_max
      });
    } catch (err) {
      return sendResponse(res, 500, { success: false, error: err.message });
    }
  }

  // 404 Route
  return sendResponse(res, 404, { error: "Endpoint not found" });
});

function updateLeaderboardEntry(data) {
  if (!data || !data.name) return null;
  const pId = data.player_id || ("anon_" + data.name);
  let existingIndex = leaderboardDb.findIndex(e => e.player_id === pId || e.name === data.name);

  const entry = {
    player_id: pId,
    name: data.name,
    max_floor: Math.max(1, data.floor || data.max_floor || 1),
    max_dps: Math.max(0, data.max_dps || data.dps || 0),
    total_damage: Math.max(0, data.total_damage || data.damage || 0),
    date: new Date().toISOString().split('T')[0]
  };

  if (existingIndex >= 0) {
    leaderboardDb[existingIndex] = {
      ...leaderboardDb[existingIndex],
      max_floor: Math.max(leaderboardDb[existingIndex].max_floor, entry.max_floor),
      max_dps: Math.max(leaderboardDb[existingIndex].max_dps, entry.max_dps),
      total_damage: Math.max(leaderboardDb[existingIndex].total_damage, entry.total_damage),
      date: entry.date
    };
  } else {
    leaderboardDb.push(entry);
  }

  // Sort by floor (desc), then max_dps (desc), then total_damage (desc)
  leaderboardDb.sort((a, b) => {
    if (b.max_floor !== a.max_floor) return b.max_floor - a.max_floor;
    if (b.max_dps !== a.max_dps) return b.max_dps - a.max_dps;
    return b.total_damage - a.total_damage;
  });

  // Assign ranks
  leaderboardDb.forEach((item, idx) => {
    item.rank = idx + 1;
  });

  saveJson(LEADERBOARD_FILE, leaderboardDb);
  return leaderboardDb.find(e => e.player_id === pId);
}

server.listen(PORT, HOST, () => {
  console.log(`=======================================================`);
  console.log(`  ETERNAL ABYSS: VOID'S LEGACY - GAME BACKEND SERVER`);
  console.log(`  Status: ONLINE on http://${HOST}:${PORT}`);
  console.log(`  API Status: http://localhost:${PORT}/api/status`);
  console.log(`  Leaderboard: http://localhost:${PORT}/api/leaderboard`);
  console.log(`=======================================================`);
});

process.on('SIGTERM', () => {
  server.close(() => process.exit(0));
});
