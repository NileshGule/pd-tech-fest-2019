using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TechTalksModel.DTO;
using TechTalksAPI.Messaging;
using TechTalksModel;
using Bogus;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TechTalksAPI.Controllers
{
    [Route("api/[controller]")]
    public class TechTalksController : Controller
    {
        private readonly ITechTalksEventPublisher _messageQueue;

        public TechTalksController(ITechTalksEventPublisher messageQueue)
        {
            _messageQueue = messageQueue;
        }

        // GET: api/TechTalks
        [HttpGet]
        public IEnumerable<TechTalk> GetAll()
        {
            // List<TechTalk> techTalks = _context.TechTalk
            //     .Include(t => t.Category)
            //     .Include(t => t.Level)
            //     .ToList();

            List<TechTalk> techTalks = new List<TechTalk>();

            return techTalks;

        }


        // POST api/TechTalks
        [HttpPost]
        public IActionResult Create([FromBody]TechTalkDTO techTalkDto)
        {
            if (techTalkDto == null)
            {
                return BadRequest();
            }

            var fakeDataCreator = new Faker();

            var categoryNames = new List<string>() { "Meetup", "Free Conference", "Paid Conference", "Hackathon", "EventTribe" };

            var categoryDescriptions = new List<string>()
            {
                "Community event organized via meetup",
                "Free Tech Conference",
                "Paid Tech Conference",
                "Hackathon",
                "Community event organized via Eventribe"
            };

            Category dummyCategory = new Category
            {
                Id = fakeDataCreator.Random.Number(1, 5),
                CategoryName = fakeDataCreator.PickRandom(categoryNames),
                Description = fakeDataCreator.PickRandom(categoryDescriptions)
            };

            Level dummyLevel = new Level
            {
                Id = fakeDataCreator.Random.Number(1, 4),
                LevelName = techTalkDto.LevelName
            };

            // TechTalk techTalk = new TechTalk
            // {
            //     Id = techTalkDto.Id,
            //     TechTalkName = techTalkDto.TechTalkName,
            //     CategoryId = techTalkDto.CategoryId,
            //     // Category = _context.Categories.FirstOrDefault(x => x.Id == techTalkDto.CategoryId),
            //     Category = dummyCategory,
            //     LevelId = techTalkDto.LevelId,
            //     // Level = _context.Levels.FirstOrDefault(x => x.Id == techTalkDto.LevelId)
            //     Level = dummyLevel
            // };

            var techTalks = new Faker<TechTalk>()
            .StrictMode(true)
            .RuleFor(t => t.Id, f => f.Random.Number(1, 1000))
            .RuleFor(t => t.TechTalkName, f => f.Lorem.Word())
            .RuleFor(t => t.CategoryId, f => f.Random.Number(1, 5))
            .RuleFor(t => t.Category, new Category
            {
                Id = fakeDataCreator.Random.Number(1, 5),
                CategoryName = fakeDataCreator.PickRandom(categoryNames),
                Description = fakeDataCreator.PickRandom(categoryDescriptions)
            })
            .RuleFor(t => t.LevelId, f => f.Random.Number(1, 4))
            .RuleFor(t => t.Level, dummyLevel);

            var dummyTechTalks = techTalks.Generate(1000);

            Console.WriteLine("Sending message to queue");

            dummyTechTalks.ForEach(tt => _messageQueue.SendMessage(tt));

            // _messageQueue.SendMessage(techTalk);

            return Ok();
        }

    }
}
