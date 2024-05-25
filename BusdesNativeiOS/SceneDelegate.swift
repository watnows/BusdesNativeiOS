import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        let window = UIWindow(windowScene: windowScene)

        let tabBarController = UITabBarController()
        let firstViewController = UINavigationController(rootViewController: HomeViewController())
        firstViewController.tabBarItem = UITabBarItem(title: "Next bus", image: UIImage(systemName: "deskclock"), tag: 0)

        let secondViewController = UINavigationController(rootViewController: TimeTableViewController())
        secondViewController.tabBarItem = UITabBarItem(title: "Timetable", image: UIImage(systemName: "calendar.badge.clock"), tag: 1)

        tabBarController.viewControllers = [firstViewController, secondViewController]
        window.rootViewController = tabBarController
        self.window = window
        self.window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
