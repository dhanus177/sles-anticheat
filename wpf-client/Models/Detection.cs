using System;

namespace WpfClient.Models;

public record Detection(
    string PlayerName,
    string Type,
    string Details,
    DateTime Timestamp
);
