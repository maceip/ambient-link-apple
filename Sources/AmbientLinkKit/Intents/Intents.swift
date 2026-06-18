import AppIntents

/// "Hey Siri, what are my agents doing?" — runs the on-device Foundation Models
/// briefing and speaks/show the result, no app launch required.
public struct ShowSessionsIntent: AppIntent {
    public static let title: LocalizedStringResource = "Show Agent Sessions"
    public static let description = IntentDescription(
        "Summarizes your live coding-agent sessions and which one needs attention."
    )
    // Surfaces the result inline (Siri snippet / Spotlight) rather than opening the app.
    public static let openAppWhenRun = false

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let assistant = SiriAssistant()
        guard assistant.isAvailable else {
            let sessions = try await RelayClient().fetchSessions().filter(\.isLive)
            return .result(dialog: "\(sessions.count) live agent session(s).")
        }
        let brief = try await assistant.briefing()
        return .result(dialog: IntentDialog(stringLiteral: brief.headline))
    }
}

/// "Reply to my Claude session" — sends a quick nudge/answer to an agent via the relay.
public struct ReplyToAgentIntent: AppIntent {
    public static let title: LocalizedStringResource = "Reply to Agent"
    public static let description = IntentDescription("Send a quick reply to a coding-agent session.")
    public static let openAppWhenRun = false

    @Parameter(title: "Session")
    public var session: SessionEntity

    @Parameter(title: "Message")
    public var message: String

    public init() {}
    public init(session: SessionEntity, message: String) {
        self.session = session
        self.message = message
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        try await RelayClient().reply(to: session.id, text: message)
        return .result(dialog: "Sent to \(session.agent).")
    }
}

/// Zero-config Siri phrases + Spotlight/Shortcuts entries.
public struct AmbientLinkShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ShowSessionsIntent(),
            phrases: [
                "What are my agents doing in \(.applicationName)",
                "Show my \(.applicationName) sessions",
            ],
            shortTitle: "Agent Sessions",
            systemImageName: "sparkles"
        )
    }
}
