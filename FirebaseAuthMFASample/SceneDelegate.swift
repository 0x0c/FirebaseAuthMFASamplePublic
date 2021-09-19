//
//  SceneDelegate.swift
//  FirebaseAuthMFASample
//
//  Created by Akira Matsuda on 2021/09/18.
//

import Firebase
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        // https://prograils.com/firebase-dynamic-links-in-ios13-with-scene-delegate
        guard let userActivity = connectionOptions.userActivities.first(where: { $0.webpageURL != nil }),
              let url = userActivity.webpageURL else {
            return
        }
        DynamicLinks.dynamicLinks().handleUniversalLink(url) { _, error in
            guard let error = error else {
                return
            }
            print(error)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // https://github.com/firebase/quickstart-ios/blob/master/authentication/AuthenticationExample/SceneDelegate.swift
        if let incomingURL = userActivity.webpageURL {
            handleIncomingDynamicLink(incomingURL)
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    private func handleIncomingDynamicLink(_ incomingURL: URL) {
        DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
            guard error == nil else {
                return print("ⓧ Error in \(#function): \(error!.localizedDescription)")
            }

            guard let link = dynamicLink?.url?.absoluteString else { return }

            if Auth.auth().isSignIn(withEmailLink: link) {
                // Save the link as it will be used in the next step to complete login
                UserDefaults.standard.set(link, forKey: "Link")

                // Post a notification to the PasswordlessViewController to resume authentication
                NotificationCenter.default
                    .post(Notification(name: Notification.Name("LinkAssign")))
            }
        }
    }
}
