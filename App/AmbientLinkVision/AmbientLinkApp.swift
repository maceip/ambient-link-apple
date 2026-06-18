import SwiftUI
import AmbientLinkKit

/// visionOS frontend for Ambient Link.
///
/// Three scenes:
///  - a 2D **window** with the session list (the everyday surface),
///  - a **volumetric** window that floats agent tiles in a slab,
///  - a full **ImmersiveSpace** that places sessions in the room.
///
/// The shared `SessionStore` (from AmbientLinkKit) is injected into the
/// environment so every scene reads the same live relay state.
@main
struct AmbientLinkApp: App {
    @State private var store = SessionStore()

    var body: some Scene {
        WindowGroup(id: "sessions") {
            SessionListView()
                .environment(store)
                .task { store.start() }
        }
        .defaultSize(width: 460, height: 640)

        WindowGroup(id: "sessions-volume") {
            SessionVolumeView()
                .environment(store)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.4, depth: 0.4, in: .meters)

        ImmersiveSpace(id: "sessions-space") {
            ImmersiveSessionsView()
                .environment(store)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
