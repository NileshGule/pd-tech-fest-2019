FROM microsoft/aspnetcore-build AS build-env

WORKDIR /app

# COPY TechTalksMQConsumer /TechTalksMQConsumer/
COPY . /TechTalksMQConsumer/
COPY TechTalksModel /TechTalksModel/

COPY NuGet.config ./

WORKDIR /TechTalksMQConsumer
RUN dotnet restore

COPY . ./

RUN dotnet publish --configuration Release --output releaseOutput --no-restore

#build runtime image
FROM microsoft/aspnetcore

WORKDIR /TechTalksMQConsumer

COPY --from=build-env /TechTalksMQConsumer/releaseOutput ./

ENTRYPOINT ["dotnet", "TechTalksMQConsumer.dll"]
