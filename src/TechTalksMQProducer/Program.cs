using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;

namespace TechTalksAPI
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateWebHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateWebHostBuilder(string[] args) =>
            // WebHost.CreateDefaultBuilder(args)
            Host.CreateDefaultBuilder(args)
            .ConfigureWebHostDefaults(webBuilder => {
                webBuilder.UseSentry(options =>{
                    options.Dsn = "https://05b9449ee8ff4c23a8a0b38d351b3633@o1049645.ingest.sentry.io/6030891";
                    options.TracesSampleRate = 1.0;
                });
                webBuilder.UseStartup<Startup>();
            });
                
    }
}
