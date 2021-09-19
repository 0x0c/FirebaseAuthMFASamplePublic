//
//  AppDelegate.swift
//  FirebaseAuthMFASample
//
//  Created by Akira Matsuda on 2021/09/18.
//

import Firebase
import IQKeyboardManagerSwift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    func application(
        _ application: UIApplication,
        open url: URL,
        sourceApplication: String?,
        annotation: Any
    ) -> Bool {
        if handlePasswordlessSignIn(withURL: url) {
            return true
        }
        if DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) != nil {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            return true
        }
        return true
    }

    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return application(
            app,
            open: url,
            sourceApplication: options[
                UIApplication.OpenURLOptionsKey
                    .sourceApplication
            ] as? String,
            annotation: ""
        )
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        let handled = DynamicLinks.dynamicLinks()
            .handleUniversalLink(userActivity.webpageURL!) { _, error in
                if let error = error {
                    print(error)
                }
            }

        return handled
    }

    func handlePasswordlessSignIn(withURL url: URL) -> Bool {
        let link = url.absoluteString
        if Auth.auth().isSignIn(withEmailLink: link) == false {
            UserDefaults.standard.set(link, forKey: "Link")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LinkAssign"), object: nil)
            print("success handle passwordless sign in")
            return true
        }
        return false
    }
}
