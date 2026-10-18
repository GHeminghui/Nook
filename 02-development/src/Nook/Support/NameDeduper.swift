import Foundation

enum NameDeduper {
    static func uniqueName(_ desired: String, existing: Set<String>) -> String {
        guard existing.contains(desired) else { return desired }
        let url = URL(fileURLWithPath: desired)
        let ext = url.pathExtension
        let base = url.deletingPathExtension().lastPathComponent
        var i = 1
        while true {
            let candidate = ext.isEmpty ? "\(base) (\(i))" : "\(base) (\(i)).\(ext)"
            if !existing.contains(candidate) { return candidate }
            i += 1
        }
    }
}
