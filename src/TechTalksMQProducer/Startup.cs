﻿using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TechTalksAPI.Messaging;

using Microsoft.Extensions.Hosting;
using Prometheus;
using Sentry.AspNetCore;
using Dapr.AspNetCore;

namespace TechTalksAPI
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllers();

            services.AddSingleton<IConfiguration>(provider => Configuration);

            services.AddTransient<ITechTalksEventPublisher, TechTalksEventPublisher>();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseHsts();
            }

            app.UseCloudEvents();

            app.UseHttpsRedirection();

            app.UseRouting();

            app.UseSentryTracing();

            app.UseHttpMetrics();

            // Expose deault Prometheus Metrics
            // app.UseMetricServer();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
                
                endpoints.MapMetrics();
            });

        }
    }
}