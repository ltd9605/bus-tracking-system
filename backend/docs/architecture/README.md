# Architecture

Baseline: modular monolith with Domain, Application, Infrastructure, and API.
Optional separate Worker host only when required by measured load.
Keep dependency direction inward (Domain knows no EF Core, ASP.NET Core or SignalR).
