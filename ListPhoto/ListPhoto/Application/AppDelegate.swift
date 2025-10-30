import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let view = WelcomeViewController()
       // let view = TVIOS()
        let nav = UINavigationController(rootViewController: view)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        return true
    }

     static var orientationLock = UIInterfaceOrientationMask.portrait
     func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
         return AppDelegate.orientationLock
     }
}

