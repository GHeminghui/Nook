import Foundation

enum LibraryLayout {
    static let rootFolderName = "Library"
    static let metaDirName = ".nook"

    static func relativePath(folderNames: [String], fileName: String) -> String {
        ([rootFolderName] + folderNames + [fileName]).joined(separator: "/")
    }
}
