var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddHealthChecks();

var app = builder.Build();

app.UseHttpsRedirection();
app.MapControllers();
app.MapHealthChecks("/health/live");

app.Run();

// Only a minimal API host is wired. Google OIDC, EF Core, MySQL,
// permission authorization, and SignalR must be implemented next.
public partial class Program { }
