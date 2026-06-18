import SwiftUI
import AmbientLinkKit

/// Primary 2D window: live session list + an on-device "ask Siri" briefing.
struct SessionListView: View {
    @Environment(SessionStore.self) private var store
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    @State private var briefing: String?
    @State private var thinking = false

    var body: some View {
        NavigationStack {
            List {
                if let briefing {
                    Section {
                        Label(briefing, systemImage: "sparkles")
                            .font(.headline)
                    }
                }

                Section("Live sessions") {
                    if store.live.isEmpty {
                        Text("no live agents")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.live) { session in
                            SessionRow(session: session)
                        }
                    }
                }
            }
            .navigationTitle("Ambient Link")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { Task { await runBriefing() } } label: {
                        Label("Ask", systemImage: "sparkles")
                    }
                    .disabled(thinking)
                }
                ToolbarItem(placement: .bottomOrnament) {
                    Button("Enter Space") {
                        Task { await openImmersiveSpace(id: "sessions-space") }
                    }
                }
            }
            .refreshable { await store.refresh() }
        }
        .glassBackgroundEffect()
    }

    /// Calls the Foundation Models assistant for a one-line briefing.
    private func runBriefing() async {
        thinking = true
        defer { thinking = false }
        let assistant = SiriAssistant()
        guard assistant.isAvailable else {
            briefing = "\(store.live.count) live session(s)."
            return
        }
        briefing = (try? await assistant.briefing())?.headline ?? "Couldn't generate a briefing."
    }
}

struct SessionRow: View {
    @Environment(SessionStore.self) private var store
    let session: Session

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.agent(session.agent))
                .frame(width: 12, height: 12)
            VStack(alignment: .leading, spacing: 2) {
                Text(session.label).font(.headline)
                Text(session.preview.isEmpty ? session.state.rawValue.lowercased() : session.preview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .swipeActions {
            Button("Nudge") {
                Task { await store.reply(to: session, text: "👋 checking in") }
            }
        }
    }
}

extension Color {
    /// Per-agent accent palette shared with the glasses + web surfaces.
    static func agent(_ name: String) -> Color {
        switch name.lowercased() {
        case "claude": return Color(red: 0.85, green: 0.47, blue: 0.34)
        case "codex":  return Color(red: 0.06, green: 0.64, blue: 0.50)
        case "cursor": return Color(white: 0.9)
        default:       return .gray
        }
    }
}
