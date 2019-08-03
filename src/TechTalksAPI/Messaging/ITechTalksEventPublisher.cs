using TechTalksModel;
using TechTalksModel.DTO;

namespace TechTalksAPI.Messaging
{
    public interface ITechTalksEventPublisher
    {
        void SendMessage(TechTalkDTO talk);

        void SendMessage(TechTalk talk);
    }
}