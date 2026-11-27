# desc: .NET SDK 10 (Ubuntu apt)
# default: off
# check: has dotnet
apt_install dotnet-sdk-10.0
ok "dotnet $(dotnet --version)"
