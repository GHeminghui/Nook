import SwiftUI

struct SearchBar: View {
    @Binding var criteria: SearchService.Criteria

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("搜索文件名或正文", text: $criteria.text)
                .textFieldStyle(.plain)
            if !criteria.text.isEmpty {
                Button {
                    criteria.text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
