//
//  BookPitchViewController.swift
//  Habits
//
//  Created by Michael Forrest on 24/04/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

import UIKit
//import AuthenticationServices
import Locksmith
enum EmailCaptureError: Error{
    case emailMissing
    case fullNameMissing
    case keychainError
}
class BookPitchViewController: UIViewController{
    @IBOutlet weak var signUpNowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didPressSignUpNow(_ sender: Any) {
        let url = URL(string: "https://goodtohear.co.uk/free?short=1")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        UserDefaults.standard.set(true, forKey: "has-tapped-sign-up-on-book-pitch")
        NotificationCenter.default.post(name: BookPromoStatusUpdated, object: nil)
        performSegue(withIdentifier: "Exit", sender: nil)
//        if #available(iOS 13, *){
//            let appleIDProvider = ASAuthorizationAppleIDProvider()
//            let request = appleIDProvider.createRequest()
//            request.requestedScopes = [.fullName,.email]
//            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//            authorizationController.delegate = self
//            authorizationController.presentationContextProvider = self
//            authorizationController.performRequests()
//        }
    }
    func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?){
        
    }
    func showPasswordCredentialAlert(username: String, password: String){
        
    }
    func saveUserInKeychain(email: String?, fullName: PersonNameComponents?) {
        do {
            guard let email = email else { throw EmailCaptureError.emailMissing }
            guard let fullName = fullName else { throw EmailCaptureError.fullNameMissing }
            try Locksmith.saveData(data: [
                "email": email,
                "givenName": fullName.givenName ?? "",
                "familyName": fullName.familyName ?? ""
            ], forUserAccount: "myUserAccount")
        } catch  {
            // do something
        }
    }
    
}
//@available(iOS 13, *)
//extension BookPitchViewController:ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding {
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return self.view.window!
//    }
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        switch(authorization.credential){
//        case let appleIDCredential as ASAuthorizationAppleIDCredential:
//            // Create an account in your system.
//            let userIdentifier = appleIDCredential.user
//            let fullName = appleIDCredential.fullName
//            let email = appleIDCredential.email
//            self.saveUserInKeychain(email: email, fullName: fullName)
//            //                   // For the purpose of this demo app, store the `userIdentifier` in the keychain.
//            //                   self.saveUserInKeychain(userIdentifier)
//            //
//            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
//            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
//
//        case let passwordCredential as ASPasswordCredential:
//
//            // Sign in using an existing iCloud Keychain credential.
//            let username = passwordCredential.user
//            let password = passwordCredential.password
//
//            // For the purpose of this demo app, show the password credential as an alert.
//            DispatchQueue.main.async {
//                self.showPasswordCredentialAlert(username: username, password: password)
//            }
//
//        default:
//            break
//        }
//    }
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//
//    }
//}
