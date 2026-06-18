// Re-export the shared core so downstream targets that `import AmbientLinkKit`
// (the visionOS app, tests) transparently see Session / RelayClient / SessionStore /
// GlassLink / EphemeralBuffer / Throttle without importing AmbientLinkCore directly.
@_exported import AmbientLinkCore
