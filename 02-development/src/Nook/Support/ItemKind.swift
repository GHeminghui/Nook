import Foundation
import UniformTypeIdentifiers

enum ItemKind: String, Codable, CaseIterable {
    case pdf, image, html, other

    static func from(extension ext: String) -> ItemKind {
        switch ext.lowercased() {
        case "pdf": return .pdf
        case "png", "jpg", "jpeg", "heic", "gif", "webp": return .image
        case "html", "htm": return .html
        default: return .other
        }
    }

    static func from(url: URL) -> ItemKind {
        let ext = url.pathExtension
        if let type = UTType(filenameExtension: ext) {
            if type.conforms(to: .pdf) { return .pdf }
            if type.conforms(to: .image) { return .image }
            if type.conforms(to: .html) { return .html }
        }
        return from(extension: ext)
    }
}
