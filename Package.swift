// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "tic_tac_toe",
    products: [
        .executable( name: "tic_tac_toe", targets: [ "tic_tac_toe" ] )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "tic_tac_toe",
            dependencies: [],
            path: "./Sources"
        )
    ]
)