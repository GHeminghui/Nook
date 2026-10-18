import Testing
import Foundation
@testable import Nook

@Suite struct SearchFilterTests {
    private let item = SearchService.Snapshot(
        id: UUID(), folderID: UUID(), folderAncestors: [UUID()],
        fileName: "函数专项练习.pdf", textContent: "一次函数 与 二次函数",
        tagIDs: [UUID(), UUID()]
    )

    @Test func matchesTextInFileName() {
        var c = SearchService.Criteria(); c.text = "函数"
        #expect(SearchService.matches(item, c))
    }
    @Test func matchesTextInContent() {
        var c = SearchService.Criteria(); c.text = "二次"
        #expect(SearchService.matches(item, c))
    }
    @Test func rejectsWhenTextMissing() {
        var c = SearchService.Criteria(); c.text = "英语"
        #expect(!SearchService.matches(item, c))
    }
    @Test func folderScopeExcludesOutsiders() {
        var c = SearchService.Criteria(); c.folderScope = UUID()
        #expect(!SearchService.matches(item, c))
    }
    @Test func matchAllTagsRequiresEveryTag() {
        var c = SearchService.Criteria(); c.tagIDs = Set(item.tagIDs); c.matchAllTags = true
        #expect(SearchService.matches(item, c))
        c.tagIDs.insert(UUID())
        #expect(!SearchService.matches(item, c))
    }
    @Test func matchAnyTagRequiresOne() {
        var c = SearchService.Criteria(); c.tagIDs = [UUID()]; c.matchAllTags = false
        #expect(!SearchService.matches(item, c))
    }
}
