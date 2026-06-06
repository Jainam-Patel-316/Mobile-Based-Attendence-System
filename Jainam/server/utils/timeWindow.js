// utils/timeWindow.js
// Checks current server time against qr_settings windows
// Returns 'morning', 'afternoon', or null (outside all windows)

function getSessionForTime(now, settings) {
    const currentMinutes = now.getHours() * 60 + now.getMinutes();

    for (const setting of settings) {
        const [startH, startM] = setting.window_start.split(':').map(Number);
        const [endH,   endM]   = setting.window_end.split(':').map(Number);

        const windowStart = startH * 60 + startM;
        // Add grace period to the window end
        const windowEnd   = endH * 60 + endM + (setting.grace_minutes || 0);

        if (currentMinutes >= windowStart && currentMinutes <= windowEnd) {
            return setting.session; // 'morning' or 'afternoon'
        }
    }

    return null; // outside all windows
}

module.exports = { getSessionForTime };
