using System;
using System.Diagnostics;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ClientScanner;

static class Program
{
    private static readonly HttpClient Http = new();
    private static NotifyIcon? _trayIcon;
    private static ScannerConfig _config = ScannerConfig.Default();
    private static DateTime _lastScanTick = DateTime.UtcNow;
    private static readonly string[] BlacklistedProcesses = new[]
    {
        "cheatengine", "ce-x64", "ce-x86",
        "eulen", "lynx", "redengine", "modestmenu",
        "cheat", "hack", "executor", "injector",
        "x-menu", "xmenu", "d-panel", "dpanel", "reborn", "spectra",
        "blum-panel", "blum", "blumpanel", "blummenu", "blum_menu",
        "midnight", "nexus", "skript.gg", "desudo",
        "1337service", "absolute", "cipher", "cipherpanel",
        "processhacker", "x64dbg", "ida64", "ida32", "ghidra",
        "xenos", "gh-injector", "extremeinjector", "reclass",
        "kiddions", "2take1", "stand", "cherax", "impulse", "phantom"
    };

    private static readonly string[] BlacklistedWindowTitles = new[]
    {
        "Cheat Engine",
        "Process Hacker",
        "x64dbg",
        "IDA",
        "Ghidra",
        "ReClass",
        "Extreme Injector",
        "GH Injector",
        "Xenos",
        "Kiddion",
        "2Take1",
        "Stand",
        "Cherax",
        "Impulse",
        "Eulen",
        "Lynx",
        "RedEngine",
        "Blum",
        "Cipher",
        "X-Menu",
        "D-Panel"
    };

    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        LoadConfig();

        _trayIcon = new NotifyIcon
        {
            Icon = SystemIcons.Shield,
            Visible = true,
            Text = "Anti-Cheat Scanner Running"
        };

        var menu = new ContextMenuStrip();
        menu.Items.Add("🛡️ Scanner Active", null, null).Enabled = false;
        menu.Items.Add(new ToolStripSeparator());
        menu.Items.Add("⚠️ Exit (Will kick from server)", null, (s, e) => {
            var result = MessageBox.Show(
                "Closing the scanner will disconnect you from the server!\n\nAre you sure you want to exit?",
                "⚠️ Anti-Cheat Scanner",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Warning
            );
            if (result == DialogResult.Yes)
            {
                Application.Exit();
            }
        });
        _trayIcon.ContextMenuStrip = menu;

        // Show startup warning
        _trayIcon.ShowBalloonTip(8000,
            "🛡️ Anti-Cheat Scanner Active",
            "Keep this running while playing!\nClosing will disconnect you from the server.",
            ToolTipIcon.Info);

        if (!IsRunningAsAdmin())
        {
            _trayIcon.ShowBalloonTip(8000,
                "⚠️ Admin Recommended",
                "Run as Administrator for best detection coverage.",
                ToolTipIcon.Warning);
        }

        _ = Task.Run(ScanLoop);
        _ = Task.Run(WatchdogLoop);

        Application.Run();
    }

    private static async Task ScanLoop()
    {
        int missedHeartbeats = 0;
        var lastHeartbeat = DateTime.UtcNow;
        var scanInterval = TimeSpan.FromMilliseconds(Math.Max(1000, _config.ScanIntervalMs));
        var heartbeatInterval = TimeSpan.FromMilliseconds(Math.Max(5000, _config.HeartbeatIntervalMs));
        
        while (true)
        {
            try
            {
                var detected = ScanProcesses();
                if (detected.Any())
                {
                    await ReportToServer(detected);
                    ShowWarning(detected);
                }

                _lastScanTick = DateTime.UtcNow;
                
                // Send heartbeat on interval
                if (DateTime.UtcNow - lastHeartbeat >= heartbeatInterval)
                {
                    var ok = await SendHeartbeat();
                    if (!ok)
                    {
                        missedHeartbeats++;
                        if (missedHeartbeats >= _config.MaxMissedHeartbeats)
                        {
                            _trayIcon?.ShowBalloonTip(8000,
                                "❌ Scanner Disconnected",
                                "Lost contact with server. You may be kicked.",
                                ToolTipIcon.Error);
                        }
                    }
                    else
                    {
                        missedHeartbeats = 0;
                    }

                    lastHeartbeat = DateTime.UtcNow;
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Scan error: {ex.Message}");
            }

            await Task.Delay(scanInterval);
        }
    }

    private static async Task WatchdogLoop()
    {
        while (true)
        {
            var scanInterval = TimeSpan.FromMilliseconds(Math.Max(1000, _config.ScanIntervalMs));
            var timeout = scanInterval + scanInterval + TimeSpan.FromSeconds(5);

            if (DateTime.UtcNow - _lastScanTick > timeout)
            {
                _trayIcon?.ShowBalloonTip(8000,
                    "❌ Scanner Tamper Detected",
                    "Scanner loop stalled. Exiting for safety.",
                    ToolTipIcon.Error);

                await SendWatchdogAlert("Scan loop stalled");

                await Task.Delay(2000);
                Environment.Exit(1);
            }

            await Task.Delay(5000);
        }
    }

    private static async Task SendWatchdogAlert(string reason)
    {
        try
        {
            var payload = new
            {
                type = "Watchdog",
                reason,
                machineName = Environment.MachineName,
                userName = Environment.UserName,
                timestamp = DateTime.UtcNow
            };

            var json = JsonSerializer.Serialize(payload);
            var content = new StringContent(json, Encoding.UTF8, "application/json");
            await Http.PostAsync(_config.ServerUrl, content);
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"Watchdog error: {ex.Message}");
        }
    }
    
    private static async Task<bool> SendHeartbeat()
    {
        try
        {
            var payload = new
            {
                type = "Heartbeat",
                machineName = Environment.MachineName,
                userName = Environment.UserName,
                timestamp = DateTime.UtcNow
            };

            var json = JsonSerializer.Serialize(payload);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            await Http.PostAsync(_config.ServerUrl, content);
            return true;
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"Heartbeat error: {ex.Message}");
            return false;
        }
    }

    private static string[] ScanProcesses()
    {
        var processes = Process.GetProcesses();
        var found = processes
            .Where(p => BlacklistedProcesses.Any(bl =>
                p.ProcessName.Contains(bl, StringComparison.OrdinalIgnoreCase)))
            .Select(p => p.ProcessName)
            .ToList();

        // Window title scan (helps catch renamed processes)
        foreach (var p in processes)
        {
            try
            {
                var title = p.MainWindowTitle;
                if (string.IsNullOrWhiteSpace(title)) continue;

                if (BlacklistedWindowTitles.Any(t =>
                    title.Contains(t, StringComparison.OrdinalIgnoreCase)))
                {
                    found.Add($"WindowTitle:{title}");
                }
            }
            catch
            {
                // Ignore processes we can't inspect
            }
        }

        var distinct = found.Distinct().ToArray();

        return distinct;
    }

    private static async Task ReportToServer(string[] detected)
    {
        try
        {
            var payload = new
            {
                type = "ProcessDetection",
                details = string.Join(", ", detected),
                machineName = Environment.MachineName,
                userName = Environment.UserName,
                timestamp = DateTime.UtcNow
            };

            var json = JsonSerializer.Serialize(payload);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            await Http.PostAsync(_config.ServerUrl, content);
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"Report error: {ex.Message}");
        }
    }

    private static void ShowWarning(string[] detected)
    {
        _trayIcon?.ShowBalloonTip(5000,
            "⚠️ Cheat Detection",
            $"Detected: {string.Join(", ", detected)}\nYou will be kicked from the server.",
            ToolTipIcon.Warning);
    }

    private static void LoadConfig()
    {
        try
        {
            var configPath = System.IO.Path.Combine(AppContext.BaseDirectory, "ClientScanner.config.json");
            if (!System.IO.File.Exists(configPath))
            {
                _config = ScannerConfig.Default();
                return;
            }

            var json = System.IO.File.ReadAllText(configPath);
            var parsed = JsonSerializer.Deserialize<ScannerConfig>(json);
            _config = parsed ?? ScannerConfig.Default();
        }
        catch
        {
            _config = ScannerConfig.Default();
        }
    }

    private static bool IsRunningAsAdmin()
    {
        try
        {
            var identity = System.Security.Principal.WindowsIdentity.GetCurrent();
            var principal = new System.Security.Principal.WindowsPrincipal(identity);
            return principal.IsInRole(System.Security.Principal.WindowsBuiltInRole.Administrator);
        }
        catch
        {
            return false;
        }
    }

    private sealed class ScannerConfig
    {
        public string ServerUrl { get; set; } = "http://127.0.0.1:30120/anticheat-client";
        public int ScanIntervalMs { get; set; } = 5000;
        public int HeartbeatIntervalMs { get; set; } = 30000;
        public int MaxMissedHeartbeats { get; set; } = 3;

        public static ScannerConfig Default() => new();
    }
}
