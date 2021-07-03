//
//  AppDelegate.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/05/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "Main")
        self.window?.makeKeyAndVisible()
        return true
    }

    func application(_ application: UIApplication, continue continueUserActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        guard continueUserActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = continueUserActivity.webpageURL, let _ = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }
        // TODO: - Handle received URL
        debugPrint(url)
        return true
    }
}
