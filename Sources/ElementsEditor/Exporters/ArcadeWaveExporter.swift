import Foundation
import ElementsCore

/// Exports Arcade formation grids and flight waves generated with C++ ElementsCore into standardized JSON
@MainActor
public struct ArcadeWaveExporter {

    public struct FormationSlot: Codable {
        public let row: Int
        public let col: Int
        public let type: String
        public let health: Int
        public let points: Int
        public let divePoints: Int
    }

    public struct SubWave: Codable {
        public let type: String
        public let row: Int
        public let col: Int
        public let path: String
        public let delay: Double
    }

    public struct ArcadeStage: Codable {
        public let stage: Int
        public let formationSlots: [FormationSlot]
        public let subwaves: [SubWave]
    }

    /// Generates standard arcade Galaga wave definitions
    public static func generateDefaultArcadeWave() -> ArcadeStage {
        var slots: [FormationSlot] = []

        // Row 0: 4 Bosses
        for c in [3, 4, 5, 6] {
            slots.append(FormationSlot(row: 0, col: c, type: "boss", health: 2, points: 150, divePoints: 400))
        }

        // Row 1: 8 Butterflies
        for c in 1...8 {
            slots.append(FormationSlot(row: 1, col: c, type: "butterfly", health: 1, points: 80, divePoints: 160))
        }

        // Row 2: 8 Bees
        for c in 1...8 {
            slots.append(FormationSlot(row: 2, col: c, type: "bee", health: 1, points: 50, divePoints: 100))
        }

        // Row 3: 10 Bees
        for c in 0...9 {
            slots.append(FormationSlot(row: 3, col: c, type: "bee", health: 1, points: 50, divePoints: 100))
        }

        // Entrance subwaves
        var subwaves: [SubWave] = []

        // Subwave 1: Bosses & Butterflies from top
        let sw1: [(String, Int, Int, String)] = [
            ("boss", 0, 4, "topLeft"), ("boss", 0, 5, "topRight"),
            ("boss", 0, 3, "topLeft"), ("boss", 0, 6, "topRight"),
            ("butterfly", 1, 4, "topLeft"), ("butterfly", 1, 5, "topRight"),
            ("butterfly", 1, 3, "topLeft"), ("butterfly", 1, 6, "topRight")
        ]
        for (i, item) in sw1.enumerated() {
            subwaves.append(SubWave(type: item.0, row: item.1, col: item.2, path: item.3, delay: Double(i) * 0.2))
        }

        // Subwave 2: Butterflies & Bees from sides
        let sw2: [(String, Int, Int, String)] = [
            ("butterfly", 1, 1, "leftSide"), ("butterfly", 1, 8, "rightSide"),
            ("butterfly", 1, 2, "leftSide"), ("butterfly", 1, 7, "rightSide"),
            ("bee", 2, 4, "leftSide"), ("bee", 2, 5, "rightSide"),
            ("bee", 2, 3, "leftSide"), ("bee", 2, 6, "rightSide")
        ]
        for (i, item) in sw2.enumerated() {
            subwaves.append(SubWave(type: item.0, row: item.1, col: item.2, path: item.3, delay: 1.8 + Double(i) * 0.2))
        }

        return ArcadeStage(stage: 1, formationSlots: slots, subwaves: subwaves)
    }

    public static func exportToJsonString(stage: ArcadeStage) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(stage), let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "{}"
    }

    public static func exportToFile(targetPath: String, stage: ArcadeStage? = nil) throws {
        let actualStage = stage ?? generateDefaultArcadeWave()
        let jsonStr = exportToJsonString(stage: actualStage)
        try jsonStr.write(toFile: targetPath, atomically: true, encoding: .utf8)
    }
}
