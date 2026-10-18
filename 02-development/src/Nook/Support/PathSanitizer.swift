import Foundation

enum PathSanitizer {
    private static let forbidden = CharacterSet(charactersIn: "/\\:*?\"<>|")

    static func sanitize(_ name: String) -> String {
        let cleaned = name.components(separatedBy: forbidden).joined(separator: "_")
        let trimmed = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "未命名" : trimmed
    }

    static func isSafe(relativePath: String) -> Bool {
        !relativePath.split(separator: "/").contains("..")
    }
}
