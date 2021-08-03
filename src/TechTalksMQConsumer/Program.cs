using Prometheus;
using System;
using System.IO;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TechTalksProcessor.Messaging;

namespace TechTalksMQProcessor
{
    class Program
    {
        static IConfiguration Configuration;

        static void Main(string[] args)
        {
            var metricServer = new MetricServer(port:8080);
            metricServer.Start();

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

            services.AddSingleton<IConfiguration>(provider => Configuration);

            services.AddSingleton<ITechTalksEventConsumer, TechTalksEventConsumer>();

            return services.BuildServiceProvider();
        }
    }
}
