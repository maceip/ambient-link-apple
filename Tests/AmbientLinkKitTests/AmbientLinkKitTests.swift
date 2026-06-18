import Testing
import Foundation
@testable import AmbientLinkKit

@Suite struct SessionDecoding {
    @Test func parsesRelayStatusPayload() throws {
        let json = """
        { "sessions": [
            { "session_id": "a1", "agent": "claude", "cwd": "/Users/me/proj", "state": "BUSY", "preview": "thinking" },
            { "session_id": "b2", "agent": "codex", "cwd": "/Users/me/other", "state": "DEAD" }
        ] }
        """.data(using: .utf8)!

        let sessions = try Session.list(from: json)
        #expect(sessions.count == 2)
        #expect(sessions[0].agent == "claude")
        #expect(sessions[0].state == .busy)
        #expect(sessions[0].shortCwd == "proj")
        #expect(sessions[0].isLive == true)
        #expect(sessions[1].isLive == false)
    }

    @Test func toleratesMissingFields() throws {
        let json = #"{ "sessions": [ { "agent": "cursor" } ] }"#.data(using: .utf8)!
        let sessions = try Session.list(from: json)
        #expect(sessions.count == 1)
        #expect(sessions[0].state == .idle)
    }
}
