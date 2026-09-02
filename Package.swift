// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacMenubarCalendar",
    defaultLocalization: "zh-Hant",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "MacMenubarCalendar",
            targets: ["MacMenubarCalendar"]
        )
    ],
    targets: [
        .executableTarget(
            name: "MacMenubarCalendar",
            path: "MacMenubarCalendar",
            exclude: [
                "Resources/Info.plist",
                "Resources/MacMenubarCalendar.entitlements"
            ],
            resources: [
                .process("Resources/en.lproj"),
                .process("Resources/zh-Hant.lproj")
            ]
        ),
        .testTarget(
            name: "MacMenubarCalendarTests",
            dependencies: ["MacMenubarCalendar"],
            path: "MacMenubarCalendarTests"
        )
    ]
)
