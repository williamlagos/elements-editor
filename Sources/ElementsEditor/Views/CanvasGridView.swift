import SwiftUI

public struct CanvasGridView: View {
    @ObservedObject var state: EditorState
    private let cellSize: CGFloat = 26

    public init(state: EditorState) {
        self.state = state
    }

    public var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Analogue Pocket Viewport (20 × 18 Tiles)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Grid: \(state.cols) × \(state.rows)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            ZStack {
                // Background board
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .shadow(radius: 4)

                // Grid Cells
                VStack(spacing: 1) {
                    ForEach(0..<state.rows, id: \.self) { row in
                        HStack(spacing: 1) {
                            ForEach(0..<state.cols, id: \.self) { col in
                                cellView(col: col, row: row)
                                    .onTapGesture {
                                        state.setTile(col: col, row: row)
                                    }
                            }
                        }
                    }
                }
                .padding(12)

                // Entities overlay
                ForEach(state.entities) { entity in
                    entityBadge(entity)
                }
            }
            .frame(width: CGFloat(state.cols) * cellSize + 24,
                   height: CGFloat(state.rows) * cellSize + 24)
        }
        .padding()
    }

    @ViewBuilder
    private func cellView(col: Int, row: Int) -> some View {
        let tile = state.grid[col][row]
        Rectangle()
            .fill(colorForTile(tile))
            .frame(width: cellSize, height: cellSize)
            .border(Color.black.opacity(0.15), width: 0.5)
    }

    @ViewBuilder
    private func entityBadge(_ entity: EditorEntity) -> some View {
        let xOffset = CGFloat(entity.posX) * cellSize + 12 + cellSize / 2
        let yOffset = CGFloat(entity.posY) * cellSize + 12 + cellSize / 2
        let isSelected = state.selectedEntityIndex.flatMap { state.entities.indices.contains($0) ? state.entities[$0].id == entity.id : false } ?? false

        Circle()
            .fill(Color.orange)
            .frame(width: 18, height: 18)
            .overlay(
                Text(String(entity.name.prefix(1)))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            )
            .overlay(
                Circle()
                    .stroke(isSelected ? Color.white : Color.black, lineWidth: isSelected ? 2 : 1)
            )
            .position(x: xOffset, y: yOffset)
    }

    private func colorForTile(_ tile: TileType) -> Color {
        switch tile {
        case .empty: return Color(red: 0.12, green: 0.14, blue: 0.13)
        case .floor: return Color(red: 0.31, green: 0.43, blue: 0.36)
        case .wall: return Color(red: 0.83, green: 0.64, blue: 0.45)
        case .water: return Color(red: 0.23, green: 0.53, blue: 0.98)
        case .hazard: return Color(red: 0.90, green: 0.22, blue: 0.27)
        }
    }
}
