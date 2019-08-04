using TechTalksModel;
using TechTalksModel.DTO;
using System.Collections.Generic;

namespace TechTalksAPI.Messaging
{
    public interface ITechTalksEventPublisher
    {
        void SendMessage(TechTalkDTO talk);

        void SendMessage(TechTalk talk);

        void SendMessages(List<TechTalk> talks);
    }
}