using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Naidira.Client;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");
builder.Services.AddHttpClient("APIClient", client => client.BaseAddress =
   new Uri(builder.HostEnvironment.IsDevelopment()
      ? "http://localhost:7071/"
      : builder.HostEnvironment.BaseAddress));
builder.Services.AddScoped(sp =>
   sp.GetRequiredService<IHttpClientFactory>().CreateClient("APIClient"));
var host = builder.Build();
host.Services.GetRequiredService<ILoggerFactory>()
   .CreateLogger<Program>();

await host.RunAsync();