//
//  WebView.swift
//  BusdesNativeiOS
//
//  Created by 黒川龍之介 on 2024/04/29.
//

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
