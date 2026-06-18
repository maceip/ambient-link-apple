import Testing
import Foundation
@testable import AmbientLinkKit

// Session JSON decoding now lives in core-apple (AmbientLinkCoreTests). These tests
// cover AmbientLinkKit's own surface and confirm it sees the shared core types via
// the @_exported import.

@Suite struct SessionEntityMapping {
    @Test func mapsSessionFields() {
        let s = Session(
            sessionId: "a1", agent: "claude",
            cwd: "/Users/me/proj", state: .busy, preview: "thinking"
        )
        let entity = SessionEntity(s)
        #expect(entity.id == "a1")
        #expect(entity.agent == "claude")
        #expect(entity.cwd == "proj")        // shortCwd
        #expect(entity.state == "BUSY")
        #expect(entity.preview == "thinking")
    }

    @Test func sharedCoreTypesAreVisible() {
        // Compiles only if the @_exported import surfaces the core types through the kit.
        let s = Session(sessionId: "x", agent: "cursor", cwd: "/a/b", state: .idle)
        #expect(s.isLive == true)
        #expect(s.label == "cursor: b")
    }
}
