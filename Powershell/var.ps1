$currentWorkingDirectory = (Get-Location).Path | Split-Path -Parent
$helmRootDirectory = Join-Path $currentWorkingDirectory "helm"
$projectRootDirectory = Join-Path $currentWorkingDirectory "k8s"
$techTalksProducerRootDirectory = Join-Path $projectRootDirectory "TechTalksProducer"
$techTalksConsumerRootDirectory = Join-Path $projectRootDirectory "TechTalksConsumer"
$autoScalarRootDirectory = Join-Path $projectRootDirectory "AutoScaledConsumer"
