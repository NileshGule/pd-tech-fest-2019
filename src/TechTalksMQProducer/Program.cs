// namespace TechTalksAPI
// {
//     public class Program
//     {
//         public static void Main(string[] args)
//         {
//             CreateWebHostBuilder(args).Build().Run();
//         }

//         public static IHostBuilder CreateWebHostBuilder(string[] args) =>
//             // WebHost.CreateDefaultBuilder(args)
//             Host.CreateDefaultBuilder(args)
//             .ConfigureWebHostDefaults(webBuilder => {
//                 webBuilder.UseSentry(options =>{
//                     options.Dsn = "https://05b9449ee8ff4c23a8a0b38d351b3633@o1049645.ingest.sentry.io/6030891";
//                     options.TracesSampleRate = 1.0;
//                 });
//                 webBuilder.UseStartup<Startup>();
//             });

//     }
// }

using TechTalksAPI.Messaging;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle

builder.Services.AddTransient<ITechTalksEventPublisher, TechTalksEventPublisher>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
