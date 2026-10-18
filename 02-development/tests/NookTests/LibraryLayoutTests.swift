import Testing
@testable import Nook

@Suite struct LibraryLayoutTests {
    @Test func buildsNestedRelativePath() {
        let p = LibraryLayout.relativePath(folderNames: ["数学", "高一", "函数"], fileName: "习题.pdf")
        #expect(p == "Library/数学/高一/函数/习题.pdf")
    }
    @Test func rootFilePath() {
        #expect(LibraryLayout.relativePath(folderNames: [], fileName: "a.html") == "Library/a.html")
    }
    @Test func metaDirIsHidden() {
        #expect(LibraryLayout.metaDirName == ".nook")
    }
}
