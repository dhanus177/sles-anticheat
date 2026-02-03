using System;
using System.Collections.ObjectModel;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using System.Windows.Input;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using WpfClient.Models;

namespace WpfClient.ViewModels;

public partial class MainViewModel : ObservableObject
{
    private static readonly HttpClient Http = new();
    private static readonly DashboardConfig Config = DashboardConfig.Load();

    [ObservableProperty]
    private ObservableCollection<Detection> _detections = new();

    [ObservableProperty]
    private string _lastUpdated = "Never";

    public ICommand RefreshCommand { get; }

    public MainViewModel()
    {
        RefreshCommand = new AsyncRelayCommand(RefreshAsync);
    }

    private async Task RefreshAsync()
    {
        try
        {
            using var request = new HttpRequestMessage(HttpMethod.Get, Config.ServerUrl);
            if (!string.IsNullOrWhiteSpace(Config.ApiKey))
            {
                request.Headers.TryAddWithoutValidation("X-API-Key", Config.ApiKey);
            }

            using var response = await Http.SendAsync(request);
            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadAsStringAsync();
            var items = JsonSerializer.Deserialize<Detection[]>(json, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            }) ?? Array.Empty<Detection>();

            Detections = new ObservableCollection<Detection>(items);
            LastUpdated = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
        }
        catch (Exception ex)
        {
            // Minimal error surfacing; extend with dialogs/toasts as needed
            LastUpdated = $"Error: {ex.Message}";
        }
    }

    private sealed class DashboardConfig
    {
        public string ServerUrl { get; init; } = "http://127.0.0.1:30120/anticheat/detections";
        public string ApiKey { get; init; } = "";

        public static DashboardConfig Load()
        {
            try
            {
                var path = System.IO.Path.Combine(AppContext.BaseDirectory, "appsettings.json");
                if (!System.IO.File.Exists(path))
                {
                    return new DashboardConfig();
                }

                var json = System.IO.File.ReadAllText(path);
                return JsonSerializer.Deserialize<DashboardConfig>(json, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                }) ?? new DashboardConfig();
            }
            catch
            {
                return new DashboardConfig();
            }
        }
    }
}
