import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let view = WelcomeViewController()
<<<<<<< HEAD

=======
>>>>>>> 3404a3230b2633a709d53b397211244b9c4e1f7e
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

