import SwiftUI
import UIKit

struct AdHelper {
    static func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Could not find root view controller")
            completion(false)
            return
        }
    }
}
