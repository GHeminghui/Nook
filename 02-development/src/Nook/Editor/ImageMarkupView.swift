import SwiftUI
import PencilKit
import UIKit

struct ImageMarkupView: View {
    let item: Item
    let store: LibraryStore

    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var saveError: String?

    private var url: URL { store.absoluteURL(for: item) }

    var body: some View {
        NavigationStack {
            Group {
                if let image {
                    GeometryReader { geometry in
                        let fitted = fittedSize(for: image.size, in: geometry.size)
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                            PencilCanvasView(canvasView: canvasView, toolPicker: toolPicker)
                                .frame(width: fitted.width, height: fitted.height)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .overlay(alignment: .bottom) {
                        Text("用手指或 Apple Pencil 在图片上标注")
                            .font(.footnote)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.bottom, 12)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("标注图片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("清除") {
                        canvasView.drawing = PKDrawing()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                }
            }
            .onAppear {
                if image == nil {
                    image = UIImage(contentsOfFile: url.path)
                }
            }
            .alert("无法保存", isPresented: Binding(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("知道了", role: .cancel) { saveError = nil }
            } message: {
                Text(saveError ?? "")
            }
        }
    }

    private func fittedSize(for imageSize: CGSize, in container: CGSize) -> CGSize {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }
        let scale = min(container.width / imageSize.width, container.height / imageSize.height)
        return CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    }

    private func save() {
        guard let image else { return }
        let ext = url.pathExtension.lowercased()
        guard ["png", "jpg", "jpeg"].contains(ext) else {
            saveError = String(format: String(localized: "暂不支持编辑 .%@ 图片，请先转为 PNG/JPG"), ext)
            return
        }

        let size = image.size
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let result = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
            let drawing = canvasView.drawing.image(
                from: CGRect(origin: .zero, size: canvasView.bounds.size),
                scale: image.scale
            )
            drawing.draw(in: CGRect(origin: .zero, size: size))
        }

        let data: Data?
        if ext == "png" {
            data = result.pngData()
        } else {
            data = result.jpegData(compressionQuality: 0.9)
        }

        guard let data else {
            saveError = String(localized: "图片编码失败")
            return
        }

        do {
            try data.write(to: url, options: .atomic)
            store.markEdited(item)
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}
