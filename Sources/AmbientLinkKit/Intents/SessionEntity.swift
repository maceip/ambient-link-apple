import AppIntents
import AmbientLinkCore

/// App Intents view of a relay session.
///
/// Exposing sessions as an `AppEntity` is what lets Siri, Spotlight, and
/// Shortcuts reference them by natural language ("reply to my Claude session")
/// and contributes them to the on-device semantic index. The visionOS app's
/// `View Annotations` can map list rows to these entities so the user can talk
/// about what's on screen ("open that one").
public struct SessionEntity: AppEntity, Identifiable {
    public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Agent Session")
    public static let defaultQuery = SessionQuery()

    public let id: String
    public let agent: String
    public let cwd: String
    public let state: String
    public let preview: String

    public init(_ s: Session) {
        self.id = s.sessionId
        self.agent = s.agent
        self.cwd = s.shortCwd
        self.state = s.state.rawValue
        self.preview = s.preview
    }

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(agent) — \(cwd)",
            subtitle: "\(preview.isEmpty ? state.lowercased() : preview)"
        )
    }
}

/// Resolves `SessionEntity` values from the live relay.
public struct SessionQuery: EntityQuery {
    public init() {}

    private var store: RelayClient { RelayClient() }

    public func entities(for identifiers: [SessionEntity.ID]) async throws -> [SessionEntity] {
        let all = try await store.fetchSessions()
        let wanted = Set(identifiers)
        return all.filter { wanted.contains($0.sessionId) }.map(SessionEntity.init)
    }

    public func suggestedEntities() async throws -> [SessionEntity] {
        try await store.fetchSessions().filter(\.isLive).map(SessionEntity.init)
    }
}
