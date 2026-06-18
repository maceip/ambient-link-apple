import SwiftUI
import RealityKit
import AmbientLinkKit

/// Full mixed-immersion space: each live session becomes a floating panel placed
/// in an arc in front of the user, so agents live "in the room" like ambient HUD
/// cards. Uses RealityView SwiftUI attachments anchored to world space.
struct ImmersiveSessionsView: View {
    @Environment(SessionStore.self) private var store

    var body: some View {
        RealityView { content, attachments in
            layout(attachments: attachments, into: content)
        } update: { content, attachments in
            // Re-place panels as the live set changes.
            content.entities.removeAll()
            layout(attachments: attachments, into: content)
        } attachments: {
            ForEach(store.live) { session in
                Attachment(id: session.id) {
                    SessionPanel(session: session)
                }
            }
        }
    }

    /// Arrange panels along a gentle arc ~1.5 m out at eye level.
    private func layout(attachments: RealityViewAttachments, into content: RealityViewContent) {
        let sessions = store.live
        let radius: Float = 1.5
        let spread: Float = .pi / 3   // 60° total fan
        let count = max(sessions.count, 1)

        for (i, session) in sessions.enumerated() {
            guard let entity = attachments.entity(for: session.id) else { continue }
            let t = count == 1 ? 0.5 : Float(i) / Float(count - 1)
            let angle = -spread / 2 + spread * t
            entity.position = SIMD3(
                x: radius * sin(angle),
                y: 1.5,
                z: -radius * cos(angle)
            )
            entity.look(at: SIMD3(0, 1.5, 0), from: entity.position, relativeTo: nil)
            content.add(entity)
        }
    }
}

private struct SessionPanel: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Circle().fill(Color.agent(session.agent)).frame(width: 12, height: 12)
                Text(session.agent).font(.headline)
            }
            Text(session.shortCwd).font(.subheadline).foregroundStyle(.secondary)
            if !session.preview.isEmpty {
                Text(session.preview).font(.caption).lineLimit(2)
            }
        }
        .padding(16)
        .frame(width: 260, alignment: .leading)
        .background(.regularMaterial, in: .rect(cornerRadius: 20))
        .glassBackgroundEffect()
    }
}
