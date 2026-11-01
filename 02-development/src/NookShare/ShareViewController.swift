import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
    private let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        label.text = String(localized: "正在存入知栈…")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        handleInputs()
    }

    private func handleInputs() {
        let providers = (extensionContext?.inputItems as? [NSExtensionItem])?
            .flatMap { $0.attachments ?? [] } ?? []

        guard !providers.isEmpty else {
            finish(message: String(localized: "没有可保存的内容"))
            return
        }

        let group = DispatchGroup()
        for provider in providers {
            group.enter()
            let type = provider.registeredTypeIdentifiers.first ?? UTType.data.identifier
            provider.loadFileRepresentation(forTypeIdentifier: type) { url, _ in
                if let url {
                    ShareInbox.copy(url: url, suggestedName: provider.suggestedName)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.finish(message: String(localized: "已存入知栈"))
        }
    }

    private func finish(message: String) {
        label.text = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil)
        }
    }
}

enum ShareInbox {
    static let appGroupID = "group.com.hmh.app"

    static var inboxURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("Inbox", isDirectory: true)
    }

    static func copy(url: URL, suggestedName: String?) {
        let fm = FileManager.default
        guard let dir = inboxURL else { return }
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)

        var name = suggestedName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if name.isEmpty { name = url.lastPathComponent }
        if (name as NSString).pathExtension.isEmpty, !url.pathExtension.isEmpty {
            name += ".\(url.pathExtension)"
        }

        let ext = (name as NSString).pathExtension
        let stem = (name as NSString).deletingPathExtension
        var candidate = name
        var index = 1
        while fm.fileExists(atPath: dir.appendingPathComponent(candidate).path) {
            candidate = ext.isEmpty ? "\(stem) (\(index))" : "\(stem) (\(index)).\(ext)"
            index += 1
        }

        try? fm.copyItem(at: url, to: dir.appendingPathComponent(candidate))
    }
}
