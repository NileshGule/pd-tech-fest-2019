using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using TechTalksModel;
using Dapr;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TechTalksAPI.Controllers
{
    [Route("api/[controller]")]
    public class TechTalksConsumerController : Controller
    {
        // POST: api/TechTalksConsumer
        [HttpPost("process")]
        [Topic("rabbitmq-pubsub", "techtalks")]
        public void Process([FromBody] TechTalk techTalk)
        {
            Thread.Sleep(2 * 1000);

            LogTechTalkDetails(techTalk);
        }

        private void LogTechTalkDetails(TechTalk techTalk)
        {
            Console.WriteLine();
            Console.WriteLine("----------");
            Console.WriteLine($"Tech Talk Id : {techTalk.Id}");
            Console.WriteLine($"Tech Talk Name : {techTalk.TechTalkName}");
            Console.WriteLine($"Category : {techTalk.CategoryId}");
            Console.WriteLine($"Level : {techTalk.LevelId}");
            Console.WriteLine("----------");
            Console.WriteLine();

            Console.WriteLine($"TechTalk persisted successfully at {DateTime.Now.ToLongTimeString()}");
        }

    }
}
