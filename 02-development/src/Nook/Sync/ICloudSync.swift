import Foundation

enum ICloudSync {
    static let containerIdentifier = "iCloud.com.hmh.nook"

    static var isEnabled: Bool {
        FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) != nil
    }

    static func libraryRoot() -> URL {
        if let container = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) {
            return container.appendingPathComponent("Documents", isDirectory: true)
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// 旧版本把资料放在 Documents/Library，升级后把内容上移一层，保证已有资料仍可访问。
    static func migrateLegacyLibraryIfNeeded() {
        let fm = FileManager.default
        let root = libraryRoot()
        let legacy = root.appendingPathComponent("Library", isDirectory: true)
        guard fm.fileExists(atPath: legacy.path) else { return }

        let contents = (try? fm.contentsOfDirectory(at: legacy, includingPropertiesForKeys: nil)) ?? []
        for url in contents {
            let destination = root.appendingPathComponent(url.lastPathComponent)
            if !fm.fileExists(atPath: destination.path) {
                try? fm.moveItem(at: url, to: destination)
            }
        }
        try? fm.removeItem(at: legacy)
    }
}
