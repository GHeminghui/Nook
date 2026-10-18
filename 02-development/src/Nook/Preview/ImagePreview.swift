import SwiftUI

struct ImagePreview: View {
    let url: URL

    var body: some View {
        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            ScrollView([.horizontal, .vertical]) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        } else {
            ContentUnavailableView("无法显示图片", systemImage: "photo")
        }
    }
}
