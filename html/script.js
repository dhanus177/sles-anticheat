let currentTab = 'players';
let selectedPlayerId = null;
let playerData = [];
let banData = [];
let detectionData = [];
let configData = {};

// Helper function to get resource name
function GetParentResourceName() {
    let resourceName = 'anti-cheat';
    if (window.location.href.includes('nui://')) {
        const matches = window.location.href.match(/nui:\/\/([^/]+)\//);
        if (matches && matches[1]) {
            resourceName = matches[1];
        }
    }
    return resourceName;
}

// Listen for messages from client
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'openPanel':
            document.getElementById('adminPanel').classList.remove('hidden');
            break;
            
        case 'updatePlayerList':
            playerData = data.players;
            updatePlayerList();
            break;
            
        case 'updatePlayerInfo':
            updatePlayerInfo(data.info);
            break;
            
        case 'updateBanList':
            banData = data.bans;
            updateBanList();
            break;
            
        case 'updateStats':
            updateStats(data.stats);
            break;
        case 'updateDetections':
            detectionData = data.detections || [];
            updateDetections();
            break;
        case 'updateConfig':
            configData = data.config || {};
            updateConfig();
            break;
            
        case 'notification':
            showNotification(data.message, data.notifType);
            break;
            
        case 'adminAlert':
            showAdminAlert(data.data);
            break;
        case 'forceClose':
            document.getElementById('adminPanel').classList.add('hidden');
            break;
    }
});

// Close panel
function closePanel() {
    document.getElementById('adminPanel').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(resp => resp.json())
      .catch(err => console.error('Close UI error:', err));
}

// ESC to close
document.addEventListener('keyup', function(e) {
    if (e.key === 'Escape') {
        closePanel();
    }
});

// Switch tabs
function switchTab(tab) {
    currentTab = tab;
    
    // Update buttons - find the clicked button by text
    document.querySelectorAll('.tab-btn').forEach(btn => {
        if (btn.textContent.toLowerCase().includes(tab === 'players' ? 'players' : tab === 'bans' ? 'ban' : 'detection')) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });
    
    // Update content
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    document.getElementById(tab + 'Tab').classList.add('active');
    
    // Load data for bans tab
    if (tab === 'bans') {
        fetch(`https://${GetParentResourceName()}/viewBans`, {
            method: 'POST',
            body: JSON.stringify({})
        }).catch(err => console.error('Failed to fetch bans:', err));
    }

    if (tab === 'logs') {
        refreshDetections();
    }

    if (tab === 'settings') {
        refreshConfig();
    }
}

// Update player list
function updatePlayerList() {
    const container = document.getElementById('playerList');
    container.innerHTML = '';
    
    playerData.forEach(player => {
        const item = document.createElement('div');
        item.className = 'player-item';
        if (selectedPlayerId === player.id) {
            item.classList.add('selected');
        }
        
        const repClass = getReputationClass(player.reputation);
        
        item.innerHTML = `
            <div class="player-name">${player.name}</div>
            <div class="player-id">ID: ${player.id}</div>
            <span class="player-reputation ${repClass}">${player.trustLevel} (${player.reputation})</span>
        `;
        
        item.onclick = () => selectPlayer(player.id);
        container.appendChild(item);
    });
}

// Get reputation CSS class
function getReputationClass(score) {
    if (score >= 90) return 'rep-trusted';
    if (score >= 50) return 'rep-normal';
    if (score >= 25) return 'rep-suspicious';
    return 'rep-high-risk';
}

// Select player
function selectPlayer(playerId) {
    selectedPlayerId = playerId;
    updatePlayerList();
    
    fetch(`https://${GetParentResourceName()}/getPlayerInfo`, {
        method: 'POST',
        body: JSON.stringify({ playerId: playerId })
    }).catch(err => console.error('Failed to fetch player info:', err));
}

// Update player info
function updatePlayerInfo(info) {
    const container = document.getElementById('playerInfo');
    
    container.innerHTML = `
        <h3>${info.name}</h3>
        
        <div class="info-section">
            <div class="info-label">Player ID</div>
            <div class="info-value">${info.id}</div>
        </div>
        
        <div class="info-section">
            <div class="info-label">Reputation</div>
            <div class="info-value">${info.reputation}/100 - ${info.trustLevel}</div>
        </div>
        
        <div class="info-section">
            <div class="info-label">Playtime</div>
            <div class="info-value">${info.playtime} hours</div>
        </div>
        
        <div class="info-section">
            <div class="info-label">Violations</div>
            <div class="info-value">${info.violations} detections</div>
        </div>
        
        <div class="info-section">
            <div class="info-label">Warnings / Kicks</div>
            <div class="info-value">${info.warnings} / ${info.kicks}</div>
        </div>
        
        <div class="action-buttons">
            <button class="action-btn btn-danger" onclick="banPlayer()">🔨 Ban</button>
            <button class="action-btn btn-danger" onclick="banHWIDPlayer()">⛔ Ban HWID</button>
            <button class="action-btn btn-warning" onclick="kickPlayer()">👢 Kick</button>
            <button class="action-btn btn-warning" onclick="warnPlayer()">⚠️ Warn</button>
            <button class="action-btn btn-info" onclick="freezePlayer()">❄️ Freeze</button>
            <button class="action-btn btn-info" onclick="unfreezePlayer()">🔥 Unfreeze</button>
            <button class="action-btn btn-primary" onclick="spectatePlayer()">👁️ Spectate</button>
            <button class="action-btn btn-primary" onclick="screenshotPlayer()">📸 Screenshot</button>
            <button class="action-btn btn-info" onclick="gotoPlayer()">🚀 Goto</button>
            <button class="action-btn btn-info" onclick="bringPlayer()">📍 Bring</button>
        </div>
    `;
}

// Action functions
function banPlayer() {
    const reason = prompt('Ban reason:');
    if (reason) {
        fetch(`https://${GetParentResourceName()}/banPlayer`, {
            method: 'POST',
            body: JSON.stringify({ playerId: selectedPlayerId, reason: reason })
        });
    }
}

function kickPlayer() {
    const reason = prompt('Kick reason:');
    if (reason) {
        fetch(`https://${GetParentResourceName()}/kickPlayer`, {
            method: 'POST',
            body: JSON.stringify({ playerId: selectedPlayerId, reason: reason })
        });
    }
}

function warnPlayer() {
    const reason = prompt('Warning message:');
    if (reason) {
        fetch(`https://${GetParentResourceName()}/warnPlayer`, {
            method: 'POST',
            body: JSON.stringify({ playerId: selectedPlayerId, reason: reason })
        });
    }
}

function freezePlayer() {
    fetch(`https://${GetParentResourceName()}/freezePlayer`, {
        method: 'POST',
        body: JSON.stringify({ playerId: selectedPlayerId })
    });
}

function unfreezePlayer() {
    fetch(`https://${GetParentResourceName()}/unfreezePlayer`, {
        method: 'POST',
        body: JSON.stringify({ playerId: selectedPlayerId })
    });
}

function spectatePlayer() {
    fetch(`https://${GetParentResourceName()}/spectatePlayer`, {
        method: 'POST',
        body: JSON.stringify({ playerId: selectedPlayerId })
    });
    closePanel();
}

function banHWIDPlayer() {
    const reason = prompt('HWID Ban reason:');
    if (reason) {
        fetch(`https://${GetParentResourceName()}/banHWIDPlayer`, {
            method: 'POST',
            body: JSON.stringify({ playerId: selectedPlayerId, reason: reason })
        });
    }
}

function screenshotPlayer() {
    fetch(`https://${GetParentResourceName()}/screenshotPlayer`, {
        method: 'POST',
        body: JSON.stringify({ playerId: selectedPlayerId })
    });
}

function gotoPlayer() {
    fetch(`https://${GetParentResourceName()}/gotoPlayer`, {
        method: 'POST',
        body: JSON.stringify({ playerId: selectedPlayerId })
    });
}

function bringPlayer() {
    fetch(`https://${GetParentResourceName()}/bringPlayer`, {
        method: 'POST',
        body: JSON.stringify({ playerId: selectedPlayerId })
    });
}

// Refresh players
function refreshPlayers() {
    fetch(`https://${GetParentResourceName()}/refreshPlayers`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function refreshDetections() {
    fetch(`https://${GetParentResourceName()}/requestRecentDetections`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function refreshConfig() {
    fetch(`https://${GetParentResourceName()}/requestConfig`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

// Filter players
function filterPlayers() {
    const search = document.getElementById('playerSearch').value.toLowerCase();
    const items = document.querySelectorAll('.player-item');
    
    items.forEach(item => {
        const text = item.textContent.toLowerCase();
        item.style.display = text.includes(search) ? 'block' : 'none';
    });
}

// Update ban list
function updateBanList() {
    const container = document.getElementById('banList');
    container.innerHTML = '';
    
    if (banData.length === 0) {
        container.innerHTML = '<p class="no-data">No bans on record</p>';
        return;
    }
    
    banData.forEach(ban => {
        const item = document.createElement('div');
        item.className = 'ban-item';
        
        const date = new Date(ban.timestamp * 1000).toLocaleString();
        
        item.innerHTML = `
            <div class="ban-header">
                <span class="ban-name">${ban.playerName}</span>
                <span class="ban-date">${date}</span>
            </div>
            <div class="ban-reason">Reason: ${ban.reason}</div>
            <div class="ban-identifier">${ban.identifier}</div>
            <button class="unban-btn" onclick="unbanPlayer('${ban.identifier}')">Unban</button>
        `;
        
        container.appendChild(item);
    });
}

function updateDetections() {
    const container = document.getElementById('logsContainer');
    container.innerHTML = '';

    if (!detectionData || detectionData.length === 0) {
        container.innerHTML = '<p class="no-data">No recent detections</p>';
        return;
    }

    detectionData.forEach(log => {
        const item = document.createElement('div');
        item.className = 'log-item';

        const time = log.timestamp ? new Date(log.timestamp).toLocaleString() : 'Unknown';
        item.innerHTML = `
            <div class="log-header">
                <span class="log-player">${log.playerName || 'Unknown'}</span>
                <span class="log-time">${time}</span>
            </div>
            <div class="log-type">${log.type || 'Unknown'}</div>
            <div class="log-details">${log.details || ''}</div>
        `;

        container.appendChild(item);
    });
}

function filterDetections() {
    const search = document.getElementById('logSearch').value.toLowerCase();
    const items = document.querySelectorAll('.log-item');

    items.forEach(item => {
        const text = item.textContent.toLowerCase();
        item.style.display = text.includes(search) ? 'block' : 'none';
    });
}

function updateConfig() {
    const grid = document.getElementById('settingsGrid');
    grid.innerHTML = '';

    const sections = [
        { title: 'Detections', keys: [
            'EnableSpeedCheck','EnableTeleportCheck','EnableGodmodeCheck','EnableWeaponCheck','EnableVehicleSpawnCheck',
            'EnableExplosionCheck','EnableBackdoorCheck','EnableCipherPanelDetection','EnableBehavioralDetection'
        ]},
        { title: 'Screenshots', keys: ['EnableScreenshotCheck','ScreenshotOnDetection','RandomScreenshots'] },
        { title: 'Bans', keys: ['AutoBan','EnableHWIDBans'] },
        { title: 'Thresholds', keys: ['MaxSpeed','MaxTeleportDistance','CheckInterval','ClientCheckInterval','GodmodeGracePeriod'] },
        { title: 'Behavioral', keys: ['AimbotMinShots','AimbotHeadshotRatioThreshold','AimSnapDeltaThreshold','AimSnapShotWindowMs','AimAccelThresholdDegPerSec2','AverageTTKMs'] },
        { title: 'Client Scanner', keys: ['RequireClientScanner','RecommendClientScanner','ScannerHeartbeatTimeout','KickOnScannerClose'] }
    ];

    sections.forEach(section => {
        const card = document.createElement('div');
        card.className = 'settings-card';
        card.innerHTML = `<div class="settings-title">${section.title}</div>`;

        section.keys.forEach(key => {
            if (configData[key] === undefined) return;
            const value = configData[key];
            const isBool = typeof value === 'boolean';
            const badge = isBool
                ? `<span class="badge ${value ? 'badge-on' : 'badge-off'}">${value ? 'On' : 'Off'}</span>`
                : `<span class="badge badge-neutral">${value}</span>`;

            const row = document.createElement('div');
            row.className = 'settings-row';
            row.innerHTML = `<span class="settings-key">${key}</span>${badge}`;
            card.appendChild(row);
        });

        grid.appendChild(card);
    });
}

// Unban player
function unbanPlayer(identifier) {
    if (confirm('Are you sure you want to unban this player?')) {
        fetch(`https://${GetParentResourceName()}/unbanPlayer`, {
            method: 'POST',
            body: JSON.stringify({ identifier: identifier })
        });
    }
}

// Filter bans
function filterBans() {
    const search = document.getElementById('banSearch').value.toLowerCase();
    const items = document.querySelectorAll('.ban-item');
    
    items.forEach(item => {
        const text = item.textContent.toLowerCase();
        item.style.display = text.includes(search) ? 'block' : 'none';
    });
}

// Update stats
function updateStats(stats) {
    document.getElementById('onlinePlayers').textContent = stats.onlinePlayers || 0;
    document.getElementById('totalBans').textContent = stats.totalBans || 0;
    document.getElementById('recentDetections').textContent = stats.recentDetections || 0;
    document.getElementById('hwidBans').textContent = stats.hwidBans || 0;
}

// Show notification
function showNotification(message, type) {
    const notification = document.getElementById('notification');
    const text = document.getElementById('notificationText');
    
    text.textContent = message;
    notification.className = `notification ${type}`;
    notification.classList.remove('hidden');
    
    setTimeout(() => {
        notification.classList.add('hidden');
    }, 3000);
}

// Show admin alert for detections
function showAdminAlert(data) {
    const alert = document.getElementById('adminAlert');
    const body = document.getElementById('alertBody');
    
    body.innerHTML = `
        <div class="alert-player">Player: ${data.player} (ID: ${data.playerId})</div>
        <div class="alert-type">Detection: ${data.detectionType}</div>
        <div class="alert-details">Details: ${data.details}</div>
        <div class="alert-time">Time: ${data.timestamp}</div>
    `;
    
    alert.classList.remove('hidden');
    
    // Auto-hide after 10 seconds
    setTimeout(() => {
        alert.classList.add('hidden');
    }, 10000);
}

// Close alert
function closeAlert() {
    document.getElementById('adminAlert').classList.add('hidden');
}

