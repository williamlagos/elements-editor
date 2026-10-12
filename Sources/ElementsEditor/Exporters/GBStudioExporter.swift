import Foundation

@MainActor
public struct GBStudioExporter {
    public static func exportScene(state: EditorState, sceneName: String = "Exported_Scene") -> String {
        var actorsList: [[String: Any]] = []

        for (idx, entity) in state.entities.enumerated() {
            let actorDict: [String: Any] = [
                "_resourceType": "actor",
                "id": UUID().uuidString.lowercased(),
                "_index": idx,
                "symbol": "actor_\(entity.name.lowercased())",
                "name": entity.name,
                "x": entity.posX,
                "y": entity.posY,
                "frame": 0,
                "animate": false,
                "spriteSheetId": "",
                "direction": "down",
                "moveSpeed": 1,
                "animSpeed": 15,
                "isPinned": false,
                "persistent": false,
                "collisionGroup": "",
                "script": [],
                "startScript": [],
                "updateScript": [],
                "hit1Script": [],
                "hit2Script": [],
                "hit3Script": []
            ]
            actorsList.append(actorDict)
        }

        // Build flat collision byte array: 0 for floor, 1 for walls/hazards
        var collisionBytes: [Int] = []
        for r in 0..<state.rows {
            for c in 0..<state.cols {
                let tile = state.grid[c][r]
                collisionBytes.append((tile == .wall || tile == .hazard) ? 1 : 0)
            }
        }

        let sceneDict: [String: Any] = [
            "_resourceType": "scene",
            "id": UUID().uuidString.lowercased(),
            "_index": 0,
            "type": "TOPDOWN",
            "name": sceneName,
            "symbol": "scene_\(sceneName.lowercased())",
            "x": 0,
            "y": 0,
            "width": state.cols,
            "height": state.rows,
            "backgroundId": "",
            "tilesetId": "",
            "paletteIds": [],
            "spritePaletteIds": [],
            "autoFadeSpeed": 1,
            "actors": actorsList,
            "collisions": collisionBytes
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: sceneDict, options: [.prettyPrinted, .sortedKeys]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }

        return "{}"
    }

    public static func exportToFile(state: EditorState, targetPath: String, sceneName: String = "Exported_Scene") throws {
        let jsonString = exportScene(state: state, sceneName: sceneName)
        try jsonString.write(toFile: targetPath, atomically: true, encoding: .utf8)
    }
}
