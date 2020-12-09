//
//  LoginViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 07/12/20.
//

import UIKit
import Firebase
import MRCountryPicker


class LoginViewController: UIViewController {
    @IBOutlet weak var countryCode: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    var completeNumber : String? = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
               
    }
    
   

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "proceedSeg"{
            guard let NumberCom:String = phoneNumber.text else{return}

            PhoneAuthProvider.provider().verifyPhoneNumber(NumberCom , uiDelegate: nil) { (verificationId,ers) in
                if ers == nil {
                    //print(verificationId as Any)
                    UserDefaults.standard.set(verificationId, forKey: "authVerificationID")
                    let destinationView = segue.destination as! VerifyOtpViewController
                    destinationView.comingId = verificationId!
                }else{
                    print("Unable to Send verification Id Check Log",ers?.localizedDescription)
                }
            }
            
        }
    }
    
}
