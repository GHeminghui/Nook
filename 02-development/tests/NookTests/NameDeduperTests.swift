import Testing
@testable import Nook

@Suite struct NameDeduperTests {
    @Test func keepsNameWhenUnique() {
        #expect(NameDeduper.uniqueName("函数.pdf", existing: []) == "函数.pdf")
    }
    @Test func appendsCounterOnConflict() {
        let existing: Set<String> = ["函数.pdf"]
        #expect(NameDeduper.uniqueName("函数.pdf", existing: existing) == "函数 (1).pdf")
    }
    @Test func incrementsUntilFree() {
        let existing: Set<String> = ["函数.pdf", "函数 (1).pdf", "函数 (2).pdf"]
        #expect(NameDeduper.uniqueName("函数.pdf", existing: existing) == "函数 (3).pdf")
    }
    @Test func handlesNoExtension() {
        let existing: Set<String> = ["未命名"]
        #expect(NameDeduper.uniqueName("未命名", existing: existing) == "未命名 (1)")
    }
}
