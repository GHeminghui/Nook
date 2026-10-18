import Testing
import Foundation
@testable import Nook

@Suite struct DragPayloadTests {
    @Test func roundTripsItem() {
        let id = UUID()
        #expect(DragPayload.parse(DragPayload.item(id)) == .item(id))
    }

    @Test func roundTripsFolder() {
        let id = UUID()
        #expect(DragPayload.parse(DragPayload.folder(id)) == .folder(id))
    }

    @Test func rejectsUnknownPayload() {
        #expect(DragPayload.parse("tag:\(UUID().uuidString)") == nil)
        #expect(DragPayload.parse("item:not-a-uuid") == nil)
        #expect(DragPayload.parse("item") == nil)
    }
}
