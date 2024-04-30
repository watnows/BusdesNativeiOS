import SwiftUI

struct WebView: View {
    var pageURL: String
    var body: some View {
        WebViewModel(url: pageURL)
    }
}

#Preview {
    WebView(pageURL: "https://google.com")
}
