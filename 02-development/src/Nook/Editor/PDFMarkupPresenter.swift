import UIKit
import QuickLook

/// 以 UIKit 原生模态方式呈现 Quick Look，确保其自带的工具栏（完成 / 标注入口）正常显示。
@MainActor
final class PDFMarkupPresenter: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    static let shared = PDFMarkupPresenter()

    private var url: URL?
    private var onSaved: ((URL) -> Void)?
    private var isPresenting = false

    func present(url: URL, onSaved: @escaping (URL) -> Void) {
        guard !isPresenting, let host = Self.topViewController() else { return }
        isPresenting = true
        self.url = url
        self.onSaved = onSaved

        let preview = QLPreviewController()
        preview.dataSource = self
        preview.delegate = self
        preview.modalPresentationStyle = .fullScreen
        host.present(preview, animated: true)
    }

    func previewControllerDidDismiss(_ previewController: QLPreviewController) {
        isPresenting = false
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        url == nil ? 0 : 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
        (url ?? URL(fileURLWithPath: "/")) as NSURL
    }

    /// Quick Look 默认只读，必须显式允许编辑才会出现标注入口。
    func previewController(
        _ controller: QLPreviewController,
        editingModeFor previewItem: any QLPreviewItem
    ) -> QLPreviewItemEditingMode {
        .updateContents
    }

    func previewController(
        _ controller: QLPreviewController,
        didSaveEditedCopyOf previewItem: any QLPreviewItem,
        at modifiedContentsURL: URL
    ) {
        onSaved?(modifiedContentsURL)
    }

    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: any QLPreviewItem) {
        if let url {
            onSaved?(url)
        }
    }

    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        guard var top = scene?.windows.first(where: \.isKeyWindow)?.rootViewController else {
            return nil
        }
        // 只沿着真正在窗口里的控制器往下找，避免把呈现目标落到已脱离层级的控制器上。
        while let presented = top.presentedViewController,
              presented.viewIfLoaded?.window != nil {
            top = presented
        }
        return top
    }
}
