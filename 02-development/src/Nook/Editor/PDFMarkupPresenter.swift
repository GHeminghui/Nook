import UIKit
import QuickLook

/// 以 UIKit 原生模态方式呈现 Quick Look，确保其自带的工具栏（完成 / 标注入口）正常显示。
@MainActor
final class PDFMarkupPresenter: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    static let shared = PDFMarkupPresenter()

    private var url: URL?
    private var onSaved: ((URL) -> Void)?
    private var isPresenting = false
    private var isOpening = false

    /// 打开 PDF：先提示加载状态（必要时等 iCloud 下载），再呈现 Quick Look。
    func open(url: URL, onSaved: @escaping (URL) -> Void) {
        guard !isOpening, !isPresenting else { return }
        isOpening = true
        PDFLoadingOverlay.shared.show(
            Self.needsDownload(url) ? String(localized: "正在从 iCloud 下载…") : String(localized: "正在打开…")
        )

        Task { @MainActor in
            await Self.ensureDownloaded(url)
            isOpening = false
            PDFLoadingOverlay.shared.update(String(localized: "正在打开…"))
            present(url: url, onSaved: onSaved)
        }
    }

    func present(url: URL, onSaved: @escaping (URL) -> Void) {
        guard let host = Self.topViewController() else {
            PDFLoadingOverlay.shared.hide()
            return
        }
        isPresenting = true
        self.url = url
        self.onSaved = onSaved

        let preview = QLPreviewController()
        preview.dataSource = self
        preview.delegate = self
        preview.modalPresentationStyle = .fullScreen
        host.present(preview, animated: true) {
            // 呈现动画结束后给系统预览一点首帧渲染时间，随后淡出浮层。
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 200_000_000)
                PDFLoadingOverlay.shared.hide()
            }
        }
    }

    func previewControllerDidDismiss(_ previewController: QLPreviewController) {
        isPresenting = false
        PDFLoadingOverlay.shared.hide()
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

// MARK: - iCloud 下载状态

extension PDFMarkupPresenter {
    /// 文件是否还只在 iCloud 上（本地没有完整副本）。
    static func needsDownload(_ url: URL) -> Bool {
        guard let values = try? url.resourceValues(
            forKeys: [.isUbiquitousItemKey, .ubiquitousItemDownloadingStatusKey]
        ), values.isUbiquitousItem == true else {
            return false
        }
        return values.ubiquitousItemDownloadingStatus != .current
    }

    /// 触发下载并短暂等待，超时后也允许继续打开（Quick Look 会自己显示下载进度）。
    static func ensureDownloaded(_ url: URL, timeout: TimeInterval = 3) async {
        guard needsDownload(url) else { return }
        try? FileManager.default.startDownloadingUbiquitousItem(at: url)

        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if !needsDownload(url) { return }
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
    }
}
