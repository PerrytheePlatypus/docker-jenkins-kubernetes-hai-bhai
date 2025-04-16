# Stage 1: Base image for runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Stage 2: Build image
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy ONLY the .csproj file from the project subdirectory
COPY ["DotNetWebAPP/DotNetWebAPP.csproj", "DotNetWebAPP/"]
RUN dotnet restore "DotNetWebAPP/DotNetWebAPP.csproj"

# Copy remaining files and build
COPY . .
WORKDIR "/src/DotNetWebAPP"
RUN dotnet build "DotNetWebAPP.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Stage 3: Publish
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "DotNetWebAPP.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Stage 4: Final image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DotNetWebAPP.dll"]
