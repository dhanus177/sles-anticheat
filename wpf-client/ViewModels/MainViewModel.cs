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
            // TODO: replace with your endpoint or local file path
            // Example: var uri = "http://localhost:30120/anticheat/detections";
            var uri = "http://localhost:30120/anticheat/detections";
            using var response = await Http.GetAsync(uri);
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
}
