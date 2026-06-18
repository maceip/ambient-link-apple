import SwiftUI
import AmbientLinkKit

/// Volumetric window: agent tiles laid out in a shallow slab the user can walk
/// around. A lighter-weight alternative to the full immersive space.
struct SessionVolumeView: View {
    @Environment(SessionStore.self) private var store

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(store.live) { session in
                VStack(alignment: .leading, spacing: 6) {
                    Circle()
                        .fill(Color.agent(session.agent))
                        .frame(width: 14, height: 14)
                    Text(session.agent).font(.headline)
                    Text(session.shortCwd)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: .rect(cornerRadius: 18))
                .hoverEffect()
            }
        }
        .padding()
        .glassBackgroundEffect()
    }
}
