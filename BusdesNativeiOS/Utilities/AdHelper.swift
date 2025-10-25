import SwiftUI
import UIKit
import os.log

struct AdHelper {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.busdes", category: "AdHelper")

    static func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let _ = windowScene.windows.first?.rootViewController else {
            logger.error("Could not find root view controller")
            completion(false)
            return
        }
    }
}
