//
//  LoginViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 07/12/20.
//

import UIKit
import Firebase
import FlagPhoneNumber
import FirebaseAuth
import MaterialComponents



class LoginViewController: UIViewController {
    @IBOutlet weak var countryCode: MDCTextField!
    @IBOutlet weak var phoneNumber: FPNTextField!
    var completeNumber : String? = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    
        
        phoneNumber.displayMode = .picker
        phoneNumber.textColor = UIColor.white
        phoneNumber.adjustsFontSizeToFitWidth = true
        phoneNumber.textAlignment = .center
        phoneNumber.placeholder = "999-999-9999"
        phoneNumber.delegate = self
    
       
        
        
        
               
    }
    
//    func viewConfigs(){
//        phoneNumber.textColor = UIColor.white
//        phoneNumber.clearButton.tintColor = UIColor.white
//        countryCode.textColor = UIColor.white
//        countryCode.clearButton.tintColor = UIColor.white
//
//    }
    override func viewDidAppear(_ animated: Bool){
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
            // User is signed in. Show home screen
                print("success user alreaddy logged in")

                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "createProfile") as! CreateProfileViewController
                      self.present(newViewController, animated: true, completion: nil)
          } else {
            // No User is signed in. Show user the login screen
            
          }
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "proceedSeg"{
            
             let NumberCom:String = phoneNumber.getFormattedPhoneNumber(format: .E164) ?? "E164: nil"

            PhoneAuthProvider.provider().verifyPhoneNumber(NumberCom , uiDelegate: nil) { (verificationId,ers) in
                if ers == nil {
                    //print(verificationId as Any)
                    UserDefaults.standard.set(verificationId, forKey: "authVerificationID")
                    let destinationView = segue.destination as! VerifyOtpViewController
                    destinationView.modalPresentationStyle = .fullScreen
                    destinationView.comingId = verificationId!
                }else{
                    print("Unable to Send verification Id Check Log \(ers?.localizedDescription ?? "")")
                }
            }
            
        }
    }
    
}
extension LoginViewController: FPNTextFieldDelegate {
    

    func fpnDisplayCountryList() {}

    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {

        print(
            isValid,
            textField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil",
            textField.getFormattedPhoneNumber(format: .International) ?? "International: nil",
            textField.getFormattedPhoneNumber(format: .National) ?? "National: nil",
            textField.getFormattedPhoneNumber(format: .RFC3966) ?? "RFC3966: nil",
            textField.getRawPhoneNumber() ?? "Raw: nil"
        )
    }

    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
    }
    
}
