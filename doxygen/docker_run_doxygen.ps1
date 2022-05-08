Write-Host "See https://github.com/CluedIn-io/ImpTools/tree/master/doxygen"
Write-Host "Run this command in the docker container cli and wait 10 to 15 minutes"
Write-Host "cd /src && doxygen"
docker run -it --rm --name CluedIn.Doxygen -v ${pwd}:/src starlabio/doxygen