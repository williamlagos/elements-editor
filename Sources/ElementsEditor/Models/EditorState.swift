import Foundation
import ElementsCore

public struct EditorEntity: Identifiable {
    public let id = UUID()
    public var name: String
    public var hitPoints: Double
    public var speedX: Int
    public var speedY: Int
    public var posX: Int
    public var posY: Int
    public var width: Int
    public var height: Int
}

public enum TileType: Int32, CaseIterable, Identifiable {
    case empty = 0
    case floor = 1
    case wall = 2
    case water = 3
    case hazard = 4

    public var id: Int32 { rawValue }

    public var title: String {
        switch self {
        case .empty: return "Empty"
        case .floor: return "Floor"
        case .wall: return "Wall"
        case .water: return "Water"
        case .hazard: return "Hazard"
        }
    }

    public var colorHex: String {
        switch self {
        case .empty: return "#1F2421"
        case .floor: return "#4E6E5D"
        case .wall: return "#D4A373"
        case .water: return "#3A86FF"
        case .hazard: return "#E63946"
        }
    }
}

@MainActor
public final class EditorState: ObservableObject {
    public let cols: Int = 20
    public let rows: Int = 18

    @Published public var selectedTile: TileType = .wall
    @Published public var grid: [[TileType]] = []
    @Published public var entities: [EditorEntity] = []
    @Published public var selectedEntityIndex: Int? = nil
    @Published public var statusMessage: String = "Ready"

    // Backed by C++ Elements engine
    private var cppEngine: Elements

    public init() {
        self.cppEngine = Elements(true)
        self.grid = Array(repeating: Array(repeating: .floor, count: rows), count: cols)

        // Initialize outer walls
        for c in 0..<cols {
            grid[c][0] = .wall
            grid[c][rows - 1] = .wall
        }
        for r in 0..<rows {
            grid[0][r] = .wall
            grid[cols - 1][r] = .wall
        }

        // Add default characters into C++ Elements
        addEntity(name: "Hero", hp: 100, x: 2, y: 2, spdX: 1, spdY: 0)
        addEntity(name: "Galaga_Drone", hp: 50, x: 10, y: 3, spdX: 0, spdY: 1)
        addEntity(name: "Chest", hp: 20, x: 15, y: 12, spdX: 0, spdY: 0)
    }

    public func setTile(col: Int, row: Int) {
        guard col >= 0, col < cols, row >= 0, row < rows else { return }
        grid[col][row] = selectedTile
    }

    public func addEntity(name: String, hp: Double, x: Int, y: Int, spdX: Int, spdY: Int) {
        var elem = Element(std.string(name))
        elem.whichPosition(Int32(x), Int32(y))
        elem.whichSpeed(Int32(spdX), Int32(spdY))
        elem.whichSize(16, 16)
        if hp < 100 {
            elem.hurtElement(100 - hp)
        }

        cppEngine.addElement(std.string(name))

        let newEntity = EditorEntity(
            name: String(elem.getName()),
            hitPoints: elem.getHitPoints(),
            speedX: Int(elem.getSpeedX()),
            speedY: Int(elem.getSpeedY()),
            posX: Int(elem.getPositionX()),
            posY: Int(elem.getPositionY()),
            width: Int(elem.getWidth()),
            height: Int(elem.getHeight())
        )
        entities.append(newEntity)
        selectedEntityIndex = entities.count - 1
        statusMessage = "Added entity '\(name)' via C++ Elements"
    }

    public func removeSelectedEntity() {
        guard let idx = selectedEntityIndex, idx < entities.count else { return }
        let removed = entities.remove(at: idx)
        cppEngine.remElement()
        selectedEntityIndex = entities.isEmpty ? nil : 0
        statusMessage = "Removed entity '\(removed.name)'"
    }

    public func hurtSelectedEntity(by points: Double) {
        guard let idx = selectedEntityIndex, idx < entities.count else { return }
        entities[idx].hitPoints = max(0, entities[idx].hitPoints - points)
        statusMessage = "Damaged \(entities[idx].name) by \(Int(points)) HP"
    }

    public func healSelectedEntity(by points: Double) {
        guard let idx = selectedEntityIndex, idx < entities.count else { return }
        entities[idx].hitPoints += points
        statusMessage = "Healed \(entities[idx].name) by \(Int(points)) HP"
    }

    /// Syncs local grid into C++ Matrix
    public func createCppMatrix() -> IntMatrix {
        var mat = IntMatrix(Int32(cols), Int32(rows), 0)
        for c in 0..<cols {
            for r in 0..<rows {
                mat.set(Int32(c), Int32(r), grid[c][r].rawValue)
            }
        }
        return mat
    }
}
