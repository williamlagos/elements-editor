import SwiftUI

public struct SidebarView: View {
    @ObservedObject var state: EditorState
    @State private var showingExportSheet = false
    @State private var exportedJSON = ""
    @State private var newEntityName = "Invader"

    public init(state: EditorState) {
        self.state = state
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            VStack(alignment: .leading, spacing: 4) {
                Text("Elements Editor")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("C++ Primitives + Analogue Pocket")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // 1. Tile Palette
            VStack(alignment: .leading, spacing: 8) {
                Text("Terrain Palette")
                    .font(.headline)

                Picker("Tile", selection: $state.selectedTile) {
                    ForEach(TileType.allCases) { tile in
                        Text(tile.title).tag(tile)
                    }
                }
                .pickerStyle(.segmented)
            }

            Divider()

            // 2. Entities (Backed by C++ Element)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Entities (\(state.entities.count))")
                        .font(.headline)
                    Spacer()
                    Button("+ Add") {
                        state.addEntity(
                            name: newEntityName,
                            hp: 75,
                            x: Int.random(in: 2...17),
                            y: Int.random(in: 2...15),
                            spdX: 1,
                            spdY: 1
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }

                List(selection: $state.selectedEntityIndex) {
                    ForEach(0..<state.entities.count, id: \.self) { idx in
                        let ent = state.entities[idx]
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(ent.name)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("HP: \(Int(ent.hitPoints))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text("Pos: (\(ent.posX), \(ent.posY)) | Spd: (\(ent.speedX), \(ent.speedY))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .tag(idx)
                    }
                }
                .frame(maxHeight: 180)

                if let idx = state.selectedEntityIndex, state.entities.indices.contains(idx) {
                    HStack {
                        Button("Hurt -20") {
                            state.hurtSelectedEntity(by: 20)
                        }
                        .controlSize(.small)

                        Button("Heal +20") {
                            state.healSelectedEntity(by: 20)
                        }
                        .controlSize(.small)

                        Spacer()

                        Button("Delete") {
                            state.removeSelectedEntity()
                        }
                        .controlSize(.small)
                        .foregroundColor(.red)
                    }
                }
            }

            Divider()

            // 3. Exporter Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Export Target")
                    .font(.headline)

                Button("Export to GB Studio (.gbsres)") {
                    exportedJSON = GBStudioExporter.exportScene(state: state, sceneName: "Dinamo_Scene")
                    showingExportSheet = true
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            // Status bar
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text(state.statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(minWidth: 260, maxWidth: 300)
        .sheet(isPresented: $showingExportSheet) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Exported GB Studio Scene (.gbsres)")
                    .font(.headline)

                ScrollView {
                    Text(exportedJSON)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(nsColor: .textBackgroundColor))
                }
                .frame(width: 500, height: 350)

                HStack {
                    Spacer()
                    Button("Close") {
                        showingExportSheet = false
                    }
                }
            }
            .padding()
        }
    }
}
