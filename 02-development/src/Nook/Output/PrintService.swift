import UIKit

enum PrintService {
    @MainActor
    static func printItem(url: URL) {
        let controller = UIPrintInteractionController.shared
        controller.printingItem = url
        controller.present(animated: true)
    }
}
