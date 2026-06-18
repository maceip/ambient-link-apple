# ambient-link-apple

Ambient Link surface for **Apple platforms**, with **visionOS** as the frontend.

The Apple sibling of [`ambient-link-meta`](https://github.com/maceip/ambient-link-meta)
and [`ambient-link-google`](https://github.com/maceip/ambient-link-google). It renders
live coding-agent sessions (Cursor / Claude / Codex) from the Ambient Link relay, and
makes them conversational through **Apple Intelligence / Siri AI**.

> Status: **scaffold / placeholder**. The wiring targets the real WWDC26 APIs
> (Foundation Models framework, App Intents schemas, visionOS RealityKit). Symbol
> shapes are current as of iOS/visionOS 26; pin to the SDK you build against.

## What's wired

| Area | API | File |
|---|---|---|
| Relay client + model | `URLSession`, `@Observable` store | `Sources/AmbientLinkKit/{RelayClient,Session}.swift` |
| **Siri AI / on-device LLM** | **Foundation Models** (`SystemLanguageModel`, `LanguageModelSession`, `@Generable`, `Tool`) | `Sources/AmbientLinkKit/SiriAssistant.swift` |
| **Siri / Spotlight / Shortcuts** | **App Intents** (`AppEntity`, `AppIntent`, `AppShortcutsProvider`) | `Sources/AmbientLinkKit/Intents/*` |
| **visionOS frontend** | SwiftUI + RealityKit (window, volumetric, ImmersiveSpace) | `App/AmbientLinkVision/*` |

### Foundation Models (the "Siri AI" brain)

`SiriAssistant` opens a `LanguageModelSession` against the same on-device model that
powers Apple Intelligence, and gives it a **`Tool`** (`getSessions`) that pulls live
state from the relay. It returns either prose (`ask(_:)`) or a structured
`@Generable Briefing` (`briefing()`) the UI renders without parsing text.

### App Intents (discoverable by Siri without phrases)

- `SessionEntity` / `SessionQuery` expose sessions to Siri, Spotlight, and the
  on-device semantic index. visionOS **View Annotations** can map list rows to these
  entities so the user can talk about what's on screen.
- `ShowSessionsIntent` — "what are my agents doing?" → on-device briefing, no app launch.
- `ReplyToAgentIntent` — "reply to my Claude session" → routes a nudge via the relay.
- `AmbientLinkShortcuts` registers zero-config Siri phrases.

### visionOS frontend

Three scenes share one `SessionStore`:
- a 2D **window** session list with an "Ask" (Foundation Models) button,
- a **volumetric** window of agent tiles,
- a mixed **ImmersiveSpace** that fans session panels in an arc around the user.

## Layout

```
Package.swift                              # AmbientLinkKit library (shared core)
Sources/AmbientLinkKit/
  Session.swift                            # model + relay JSON decoding
  RelayClient.swift                        # relay I/O + @Observable SessionStore
  SiriAssistant.swift                      # Foundation Models session + Tool
  Intents/
    SessionEntity.swift                    # AppEntity + query
    Intents.swift                          # ShowSessions / ReplyToAgent / Shortcuts
Tests/AmbientLinkKitTests/                 # swift test
App/AmbientLinkVision/                     # visionOS app target sources (add in Xcode)
  AmbientLinkApp.swift                     # @main: window + volume + ImmersiveSpace
  SessionListView.swift                    # primary window UI
  SessionVolumeView.swift                  # volumetric tiles
  ImmersiveSessionsView.swift              # RealityKit panels in space
```

## Build

The shared kit builds with SwiftPM:

```bash
swift build
swift test
```

The **visionOS app** is an Xcode app target (SwiftPM can't emit a visionOS `.app`):

1. Create a visionOS App in Xcode (SwiftUI lifecycle).
2. Add this package as a local dependency and link `AmbientLinkKit`.
3. Add the `App/AmbientLinkVision/*.swift` files to the app target (delete the
   Xcode-generated `App.swift`).
4. Foundation Models + App Intents need no extra entitlement, but require a device
   (or sim) with **Apple Intelligence** enabled to exercise `SiriAssistant`.

## Relay

Reuses the existing Ambient Link relay (same one the Meta + Google apps read):

```
GET  https://public.computer/ambient-link/status   ->  { sessions: [...] }
POST https://public.computer/ambient-link/ingest   <-  quick replies
```

Override by constructing `RelayClient(baseURL:)` with your own host.
