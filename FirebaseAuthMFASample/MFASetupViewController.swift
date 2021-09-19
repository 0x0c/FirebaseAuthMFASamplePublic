//
//  MFASetupViewController.swift
//  FirebaseAuthMFASample
//
//  Created by Akira Matsuda on 2021/09/19.
//

import Firebase
import PhoneNumberKit
import UIKit

class MFASetupViewController: UIViewController {
    @IBOutlet private var phoneNumberTextField: UITextField!
    @IBOutlet private var codeTextField: UITextField!
    private let phoneNumberKit = PhoneNumberKit()
    private var verificationId: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction private func registerPhoneNumber(_ sender: Any) {
        guard let user = Auth.auth().currentUser,
              let phoneNumber = phoneNumberTextField.text else {
            print("error")
            return
        }
        do {
            let number = try phoneNumberKit.parse(phoneNumber)
            user.multiFactor.getSessionWithCompletion { session, error in
                if let error = error {
                    print(error)
                    return
                }
                PhoneAuthProvider.provider().verifyPhoneNumber(
                    number.numberString,
                    uiDelegate: nil,
                    multiFactorSession: session
                ) { [weak self] verificationId, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    guard let weakSelf = self else {
                        return
                    }
                    weakSelf.verificationId = verificationId
                }
            }
        }
        catch {
            print(error)
        }
    }

    @IBAction private func validateCode(_ sender: Any) {
        guard let verificationId = verificationId else {
            print("verificationId is nil")
            return
        }
        guard let code = codeTextField.text else {
            print("code is nil")
            return
        }
        guard let user = Auth.auth().currentUser else {
            print("currentUser is nil")
            return
        }
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationId,
            verificationCode: code
        )
        let assertion = PhoneMultiFactorGenerator.assertion(with: credential)
        user.multiFactor.enroll(with: assertion, displayName: "") { error in
            if let error = error {
                print(error)
            }
        }
    }
}
