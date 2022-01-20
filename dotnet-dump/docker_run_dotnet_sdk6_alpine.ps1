# run me from the group of folders containing your crashdumps
# the current directory will be mounted under /dumps
#
# note: docker tag
# -alpine for alpine
# -focal for ubuntu
#
# to install the dotnet-dump run the following:
# dotnet tool install -g dotnet-dump && export PATH="$PATH:/root/.dotnet/tools"
docker run -it --rm --name dotnet_sdk6_alpine -v ${pwd}:/dumps mcr.microsoft.com/dotnet/sdk:6.0-alpine