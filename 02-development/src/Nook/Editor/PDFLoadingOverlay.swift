import UIKit

/// 覆盖在 App 之上的轻量加载浮层。
/// Quick Look 是系统进程，加载期间会先显示空白页，用独立窗口把浮层盖在上面，避免出现"没反应"的空档。
@MainActor
final class PDFLoadingOverlay {
    static let shared = PDFLoadingOverlay()

    private var window: UIWindow?
    private let messageLabel = UILabel()

    func show(_ message: String) {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            return
        }
        if window == nil {
            buildWindow(scene: scene)
        }
        messageLabel.text = message
        window?.isHidden = false
    }

    func update(_ message: String) {
        messageLabel.text = message
    }

    func hide() {
        guard let window else { return }
        self.window = nil
        UIView.animate(withDuration: 0.15, animations: {
            window.alpha = 0
        }, completion: { _ in
            window.isHidden = true
        })
    }

    private func buildWindow(scene: UIWindowScene) {
        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        window.isUserInteractionEnabled = false

        let root = UIViewController()
        root.view.backgroundColor = .clear

        let container = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()

        messageLabel.font = .preferredFont(forTextStyle: .callout)
        messageLabel.textColor = .label
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [spinner, messageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24)
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.contentView.addSubview(stack)
        root.view.addSubview(container)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: container.contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.contentView.bottomAnchor),
            container.centerXAnchor.constraint(equalTo: root.view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: root.view.centerYAnchor),
            container.widthAnchor.constraint(lessThanOrEqualToConstant: 280)
        ])

        window.rootViewController = root
        self.window = window
    }
}
