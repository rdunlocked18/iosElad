//
//  VerifyOtpViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 09/12/20.
//

import UIKit
import Firebase
import FirebaseAuth

class VerifyOtpViewController: UIViewController {
    
    @IBOutlet weak var verifyBtn: UIButton!
    let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
    @IBOutlet weak var otpText: UITextField!
    
    var comingId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(verificationID)
        
        
    }
    
    @IBAction func onVerifyPressed(_ sender: Any) {
        
        guard let otpCode = otpText.text else {
            return
        }
        
   // print(comingId)
     let credientials = PhoneAuthProvider.provider().credential(withVerificationID: comingId, verificationCode: otpCode)
        
        
        Auth.auth().signIn(with: credientials) { (success, error) in
            if error == nil{
                print("success")
                
            }else{
                print("Failed to signin with otp ",error?.localizedDescription)
                let alert = UIAlertController(title: "OTP Failed", message: "Failed To Verify The OTP Entered Please Reenter the OTP", preferredStyle: UIAlertController.Style.alert)
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                //self.dismiss(animated: true, completion: nil) //end verify screen
                
            }
        }
        
        
        
    }
    
    
}
