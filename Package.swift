// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "elements-editor",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "ElementsEditor",
            targets: ["ElementsEditor"]
        )
    ],
    dependencies: [
        .package(path: "../elements")
    ],
    targets: [
        .executableTarget(
            name: "ElementsEditor",
            dependencies: [
                .product(name: "ElementsCore", package: "elements")
            ],
            path: "Sources/ElementsEditor",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        )
    ],
    cxxLanguageStandard: .cxx17
)
