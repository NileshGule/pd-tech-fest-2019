using System;
using System.IO;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TechTalksModel;
using TechTalksProcessor.Messaging;

namespace TechTalksMQProcessor
{
    class Program
    {
        static IConfiguration Configuration;

        static void Main(string[] args)
        {
            ConfigureEnvironment();
            var serviceProvider = ConfigureServices();

            var techTalksEventConsumer = serviceProvider.GetService<ITechTalksEventConsumer>();

            Console.WriteLine("Starting to read from the queue");

            techTalksEventConsumer.ConsumeMessage();

        }

        static void ConfigureEnvironment()
        {
            string environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");

            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile($"appsettings.{environment}.json", optional: false)
                .AddEnvironmentVariables();

            Configuration = builder.Build();
        }

        static ServiceProvider ConfigureServices()
        {
            var services = new ServiceCollection();
            services.AddOptions();

            services.AddDbContext<TechTalksDBContext>
            (
                options => options.UseSqlServer(Configuration.GetConnectionString("DefaultConnection"))
            );

            services.AddSingleton<ITechTalksEventConsumer, TechTalksEventConsumer>();

            return services.BuildServiceProvider();
        }
    }
}
