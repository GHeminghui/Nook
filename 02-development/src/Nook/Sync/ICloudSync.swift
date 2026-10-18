import Foundation

enum ICloudSync {
    static let containerIdentifier = "iCloud.com.hmh.nook"

    static var isEnabled: Bool {
        FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) != nil
    }

    static func libraryRoot() -> URL {
        if let container = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) {
            return container.appendingPathComponent("Documents/Library", isDirectory: true)
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Library", isDirectory: true)
    }
}
