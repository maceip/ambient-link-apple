import Foundation
import FoundationModels

/// Natural-language layer over Ambient Link, powered by the **Foundation Models
/// framework** — the same on-device model that backs Apple Intelligence / Siri AI.
///
/// It exposes a `Tool` so the model can pull live session state from the relay on
/// demand, and uses a `@Generable` type to get a structured briefing back ("which
/// agent needs me, and why") that the visionOS UI can render directly.
///
/// Example:
/// ```swift
/// let assistant = SiriAssistant()
/// if assistant.isAvailable {
///     let brief = try await assistant.briefing()
///     print(brief.headline)            // "Claude is blocked on a permission prompt"
/// }
/// ```
public struct SiriAssistant: Sendable {

    private let relay: RelayClient

    public init(relay: RelayClient = RelayClient()) {
        self.relay = relay
    }

    /// Whether Apple Intelligence / the on-device model is usable on this device.
    public var isAvailable: Bool {
        switch SystemLanguageModel.default.availability {
        case .available: return true
        default: return false
        }
    }

    /// A structured, model-generated summary of the current agent landscape.
    @Generable
    public struct Briefing: Sendable {
        @Guide(description: "One-line summary of what most needs the user's attention.")
        public var headline: String

        @Guide(description: "How many agent sessions are currently live.")
        public var liveCount: Int

        @Guide(description: "The session_id the user should look at first, or empty if none.")
        public var focusSessionId: String
    }

    /// Tool the model calls to read current sessions from the relay.
    struct SessionsTool: Tool {
        let relay: RelayClient
        let name = "getSessions"
        let description = "Returns the user's current live coding-agent sessions and their state."

        @Generable
        struct Arguments {
            @Guide(description: "If true, return only live (non-dead) sessions.")
            var onlyLive: Bool
        }

        func call(arguments: Arguments) async throws -> ToolOutput {
            let all = try await relay.fetchSessions()
            let sessions = arguments.onlyLive ? all.filter(\.isLive) : all
            let lines = sessions.map {
                "\($0.sessionId) | \($0.agent) | \($0.state.rawValue) | \($0.shortCwd) | \($0.preview)"
            }
            return ToolOutput(lines.isEmpty ? "no sessions" : lines.joined(separator: "\n"))
        }
    }

    private func makeSession() -> LanguageModelSession {
        LanguageModelSession(
            model: SystemLanguageModel.default,
            tools: [SessionsTool(relay: relay)],
            instructions: """
            You are the Ambient Link assistant for someone running AI coding agents
            (Cursor, Claude, Codex). Use the getSessions tool to read live state.
            Be terse and glanceable — this is read on glasses and a Vision Pro HUD.
            Prioritize sessions that are blocked or awaiting the user.
            """
        )
    }

    /// Free-form question, e.g. "what's my Claude session doing?"
    public func ask(_ prompt: String) async throws -> String {
        let session = makeSession()
        let response = try await session.respond(to: prompt)
        return response.content
    }

    /// Structured briefing for the UI to render without parsing prose.
    public func briefing() async throws -> Briefing {
        let session = makeSession()
        let response = try await session.respond(
            to: "Give me a briefing of my current agent sessions.",
            generating: Briefing.self
        )
        return response.content
    }
}
