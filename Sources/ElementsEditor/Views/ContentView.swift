import SwiftUI

public struct ContentView: View {
    @StateObject private var state = EditorState()

    public init() {}

    public var body: some View {
        NavigationSplitView {
            SidebarView(state: state)
        } detail: {
            CanvasGridView(state: state)
        }
        .frame(minWidth: 880, minHeight: 600)
    }
}
