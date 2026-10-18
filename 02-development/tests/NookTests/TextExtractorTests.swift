import Testing
@testable import Nook

@Suite struct TextExtractorTests {
    @Test func stripsHTMLTags() {
        let html = "<html><body><h1>函数</h1><p>二次函数</p></body></html>"
        let text = TextExtractor.plainText(fromHTML: html)
        #expect(text.contains("函数"))
        #expect(!text.contains("<"))
    }
}
