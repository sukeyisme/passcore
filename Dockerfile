ARG DOTNET_VERSION=3.1
FROM mcr.microsoft.com/dotnet/core/sdk:$DOTNET_VERSION-alpine AS build

# Disable the invariant mode (set in base image)
RUN apk add --no-cache \
    icu-libs \
    nodejs \
    nodejs-npm

WORKDIR /build

COPY . .

RUN dotnet restore
RUN dotnet publish -c Release -o /publish /p:PASSCORE_PROVIDER=LDAP

FROM mcr.microsoft.com/dotnet/core/aspnet:$DOTNET_VERSION-alpine AS release

WORKDIR /app

RUN mv /app/appsettings.json /config/ \
&& ln -s /config/appsettings.json /app/appsettings.json

COPY --from=build /publish .

EXPOSE 80
CMD ["dotnet", "/app/Unosquare.PassCore.Web.dll"]
