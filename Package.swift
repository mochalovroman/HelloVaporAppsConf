import PackageDescription

let package = Package(
    name: "HelloVaporAppsConf",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/postgresql-provider", majorVersion: 2),
        .Package(url: "https://github.com/vapor/auth-provider.git", majorVersion: 1)
    ],
    exclude: [
        "Config",
        "Localization",
        "Public",
        "Resources",
        ]
)
