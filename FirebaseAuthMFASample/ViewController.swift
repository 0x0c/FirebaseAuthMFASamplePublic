//
//  ViewController.swift
//  FirebaseAuthMFASample
//
//  Created by Akira Matsuda on 2021/09/18.
//

import Firebase
import Rswift
import UIKit

class ViewController: UIViewController {
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var stateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didLinkAssign),
            name: NSNotification.Name(rawValue: "LinkAssign"),
            object: nil
        )
        if Auth.auth().currentUser != nil {
            stateLabel.text = "Success"
        }
        else {
            stateLabel.text = "Not signed in"
        }
    }

    @IBAction private func didSignInButtonPress(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: "Email")
        UserDefaults.standard.set(nil, forKey: "Link")
        guard let email = emailTextField.text else {
            return
        }
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://firauthmfasamplee00c8.page.link/open")
        actionCodeSettings.handleCodeInApp = true
        Auth.auth().sendSignInLink(
            toEmail: email,
            actionCodeSettings: actionCodeSettings
        ) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            UserDefaults.standard.set(email, forKey: "Email")
        }
    }

    @objc
    private func didLinkAssign() {
        guard let email = UserDefaults.standard.string(forKey: "Email"),
              let link = UserDefaults.standard.string(forKey: "Link") else {
            return
        }
        Auth.auth().signIn(withEmail: email, link: link) { [unowned self] _, error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.secondFactorRequired.rawValue {
                    let resolver = error.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    self.presentMultiFactorSelectViewController(resolver: resolver)
                }
                self.stateLabel.text = error.localizedDescription
                print(error)
                return
            }
            self.stateLabel.text = "Success"
        }
    }

    @IBAction private func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            stateLabel.text = "Sign out"
        }
        catch {
            print(error.localizedDescription)
            stateLabel.text = error.localizedDescription
        }
    }

    private func presentMultiFactorSelectViewController(resolver: MultiFactorResolver) {
        let alert = UIAlertController(
            title: "You need to proceed MFA to login.",
            message: "Select your prefered method.",
            preferredStyle: .alert
        )
        for hint in resolver.hints {
            alert.addAction(
                UIAlertAction(
                    title: hint.displayName,
                    style: .default,
                    handler: { _ in
                        if hint.factorID == PhoneMultiFactorID {
                            PhoneAuthProvider.provider().verifyPhoneNumber(
                                with: hint as! PhoneMultiFactorInfo,
                                uiDelegate: nil,
                                multiFactorSession: resolver.session
                            ) { [unowned self] verificationId, error in
                                if let error = error {
                                    print(error)
                                    return
                                }
                                let codeInputViewController = R.storyboard.mfaCodeInputViewController.instantiateInitialViewController()!
                                codeInputViewController.verificationId = verificationId
                                codeInputViewController.resolver = resolver
                                self.present(
                                    codeInputViewController,
                                    animated: true
                                )
                            }
                        }
                    }
                )
            )
        }
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        present(alert, animated: true)
    }
}
