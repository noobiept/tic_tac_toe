// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "tic_tac_toe",
    products: [
        .executable( name: "tic_tac_toe", targets: [ "tic_tac_toe" ] )
    ],
    dependencies: [
        .package( url: "https://github.com/onevcat/Rainbow", .upToNextMajor( from: "3.1.0" ) ),
    ],
    targets: [
        .target(
            name: "tic_tac_toe",
            dependencies: [
                "Rainbow",
            ],
            path: "./Sources"
        )
    ]
)
