import Testing
@testable import Nook

@Suite struct PathSanitizerTests {
    @Test func replacesForbiddenCharacters() {
        #expect(PathSanitizer.sanitize("a/b:c?d") == "a_b_c_d")
    }
    @Test func fallsBackOnEmpty() {
        #expect(PathSanitizer.sanitize("   ") == "未命名")
    }
    @Test func detectsTraversal() {
        #expect(PathSanitizer.isSafe(relativePath: "数学/../秘密") == false)
        #expect(PathSanitizer.isSafe(relativePath: "数学/高一/函数.pdf") == true)
    }
}
