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

        guard continueUserActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = continueUserActivity.webpageURL, let _ = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else {
            return false
        }

        /// URLクエリーからvalue抽出
        /// - Note: Locationは不要であれば削除する
        guard let nfcTag = url.queryValue(for: "NFCTag"),
              let location = url.queryValue(for: "Location"),
              let employeeNumber = UserdefaultsUtil.get()
        else {
            return false
        }

        APIClient.fetch(nfcTag: nfcTag, employeeNumber: employeeNumber) { result in
            // TODO: - Error handling
            /// NotificationCenterでMain画面に通知してアラートなど
        }
        return true
    }
}

extension URL {
    func queryValue(for key: String) -> String? {
        let queryItems = URLComponents(string: absoluteString)?.queryItems
        return queryItems?.filter { $0.name == key }.compactMap { $0.value }.first
    }
}
