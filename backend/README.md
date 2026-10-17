# BusTracking.Backend
Based on the user-supplied **Bus Tracking System Specification v1.0**.
A modular-monolith solution for the scheduled public-transit (not ride-hailing) system.

## Layers 

- `BusTracking.Domain`: domain entities, value objects, transit and trip rules.
- `BusTracking.Application`: use cases, contracts, validation and interfaces.
- `BusTracking.Infrastructure`: adapters (EF Core, OIDC, outbox, GPS/ETA, external providers).
- `BusTracking.Api`: ASP.NET Core host, controllers, SignalR hub, policies.
- `tests`: domain/application unit tests and real-MySQL integration tests.


## Prerequisites

- .NET SDK 10
- Docker Engine / Docker Desktop for the local MySQL service

## Quick start

```bash
cp .env.example .env                # Windows PowerShell: Copy-Item .env.example .env
docker compose up -d mysql
dotnet restore BusTracking.slnx
dotnet build BusTracking.slnx
dotnet test BusTracking.slnx
dotnet run --project src/BusTracking.Api --launch-profile https
```

The starter health check is at `https://localhost:7100/health/live`.