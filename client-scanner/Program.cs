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
    private static readonly string[] BlacklistedProcesses = new[]
    {
        "cheatengine", "ce-x64", "ce-x86",
        "eulen", "lynx", "redengine", "modestmenu",
        "cheat", "hack", "executor", "injector",
        "x-menu", "xmenu", "d-panel", "dpanel", "reborn", "spectra",
        "blum-panel", "blum", "blumpanel", "blummenu", "blum_menu",
        "midnight", "nexus", "skript.gg", "desudo", 
        "1337service", "absolute", "cipher", "cipherpanel"
    };

    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

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

        _ = Task.Run(ScanLoop);

        Application.Run();
    }

    private static async Task ScanLoop()
    {
        int heartbeatCounter = 0;
        
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
                
                // Send heartbeat every 30 seconds (6 loops x 5sec)
                heartbeatCounter++;
                if (heartbeatCounter >= 6)
                {
                    await SendHeartbeat();
                    heartbeatCounter = 0;
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Scan error: {ex.Message}");
            }

            await Task.Delay(5000); // Scan every 5 seconds
        }
    }
    
    private static async Task SendHeartbeat()
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

            var serverUrl = "http://localhost:30120/anticheat-client";
            await Http.PostAsync(serverUrl, content);
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"Heartbeat error: {ex.Message}");
        }
    }

    private static string[] ScanProcesses()
    {
        var processes = Process.GetProcesses();
        var found = processes
            .Where(p => BlacklistedProcesses.Any(bl =>
                p.ProcessName.Contains(bl, StringComparison.OrdinalIgnoreCase)))
            .Select(p => p.ProcessName)
            .Distinct()
            .ToArray();

        return found;
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

            // TODO: Replace with your FiveM server endpoint
            var serverUrl = "http://localhost:30120/anticheat-client";
            await Http.PostAsync(serverUrl, content);
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
}
