import SwiftUI

struct SyncStatusView: View {
    let enabled: Bool

    var body: some View {
        Label(enabled ? "iCloud 同步已开启" : "仅本机（未登录 iCloud）",
              systemImage: enabled ? "icloud.fill" : "icloud.slash")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
