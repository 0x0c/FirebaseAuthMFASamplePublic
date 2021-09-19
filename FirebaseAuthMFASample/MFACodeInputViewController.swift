//
//  MFACodeInputViewController.swift
//  FirebaseAuthMFASample
//
//  Created by Akira Matsuda on 2021/09/19.
//

import Firebase
import JGProgressHUD
import UIKit

class MFACodeInputViewController: UIViewController {
    @IBOutlet private var codeTextField: UITextField!
    var verificationId: String?
    var resolver: MultiFactorResolver?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction private func didDoneButtonPress(_ sender: Any) {
        guard let resolver = resolver,
              let verificationId = verificationId,
              let code = codeTextField.text else {
            return
        }
        let hud = JGProgressHUD()
        hud.show(in: view)
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationId,
            verificationCode: code
        )
        let assertion = PhoneMultiFactorGenerator.assertion(with: credential)
        resolver.resolveSignIn(with: assertion) { [unowned self] result, error in
            if let error = error {
                print(error)
                return
            }
            print(result.debugDescription)
            hud.dismiss()
            self.dismiss(animated: true)
        }
    }
}
