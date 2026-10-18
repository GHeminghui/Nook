import SwiftUI
import PencilKit

struct PencilCanvasView: UIViewRepresentable {
    let canvasView: PKCanvasView
    let toolPicker: PKToolPicker?
    var autoShowToolPicker: Bool = true
    var hideToolPickerOnDismantle: Bool = true

    func makeCoordinator() -> Coordinator {
        Coordinator(
            toolPicker: toolPicker,
            hideToolPickerOnDismantle: hideToolPickerOnDismantle
        )
    }

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.isScrollEnabled = false

        if let toolPicker {
            toolPicker.addObserver(canvasView)
            if autoShowToolPicker {
                DispatchQueue.main.async {
                    toolPicker.setVisible(true, forFirstResponder: canvasView)
                    canvasView.becomeFirstResponder()
                }
            }
        }
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    static func dismantleUIView(_ uiView: PKCanvasView, coordinator: Coordinator) {
        if let toolPicker = coordinator.toolPicker {
            toolPicker.removeObserver(uiView)
            if coordinator.hideToolPickerOnDismantle {
                toolPicker.setVisible(false, forFirstResponder: uiView)
            }
        }
        if coordinator.hideToolPickerOnDismantle {
            uiView.resignFirstResponder()
        }
    }

    final class Coordinator {
        let toolPicker: PKToolPicker?
        let hideToolPickerOnDismantle: Bool

        init(toolPicker: PKToolPicker?, hideToolPickerOnDismantle: Bool) {
            self.toolPicker = toolPicker
            self.hideToolPickerOnDismantle = hideToolPickerOnDismantle
        }
    }
}
