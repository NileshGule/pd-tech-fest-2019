#FROM mcr.microsoft.com/dotnet/core/sdk:3.0  AS build-env
FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build-env

WORKDIR /app

COPY TechTalksMQProducer /TechTalksMQProducer/
COPY TechTalksModel /TechTalksModel/

COPY NuGet.config ./

WORKDIR /TechTalksMQProducer
RUN dotnet restore

#COPY . ./

RUN dotnet publish --configuration Release --output releaseOutput --no-restore

#build runtime image
#FROM mcr.microsoft.com/dotnet/core/aspnet:3.0
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim


WORKDIR /TechTalksMQProducer

COPY --from=build-env /TechTalksMQProducer/releaseOutput ./

#run the container as non-root user
USER 1000

ENTRYPOINT ["dotnet", "TechTalksMQProducer.dll"]
