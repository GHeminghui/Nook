import Testing

@Suite struct SmokeTests {
    @Test func appTargetCompiles() {
        #expect(1 + 1 == 2)
    }
}
