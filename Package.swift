import PackageDescription

let package = Package(
    name: "Todo",
    dependencies: [
        .Package(url: "https://github.com/Zewo/Epoch.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/Middleware.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/briancroom/Sideburns.git", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/Zewo/WebSocket.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/PostgreSQL.git", majorVersion: 0, minor: 1),
    ]
)
