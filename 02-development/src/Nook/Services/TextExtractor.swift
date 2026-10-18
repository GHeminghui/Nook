import Foundation
import PDFKit

enum TextExtractor {
    static func plainText(fromHTML html: String) -> String {
        var out = ""
        var inTag = false
        for ch in html {
            if ch == "<" { inTag = true; continue }
            if ch == ">" { inTag = false; out.append(" "); continue }
            if !inTag { out.append(ch) }
        }
        return out.split(whereSeparator: { $0 == " " || $0.isNewline })
            .joined(separator: " ")
    }

    static func extract(from url: URL, kind: ItemKind) -> String {
        switch kind {
        case .pdf:
            guard let doc = PDFDocumentWrapper.document(at: url) else { return "" }
            return doc
        case .html:
            let html = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
            return plainText(fromHTML: html)
        default:
            return ""
        }
    }
}

private enum PDFDocumentWrapper {
    static func document(at url: URL) -> String? {
        guard let doc = PDFDocument(url: url) else { return nil }
        return (0..<doc.pageCount)
            .compactMap { doc.page(at: $0)?.string }
            .joined(separator: "\n")
    }
}
