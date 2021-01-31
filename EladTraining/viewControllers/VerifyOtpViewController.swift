//
//  VerifyOtpViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 09/12/20.
//

import UIKit
import Firebase
import FirebaseAuth
import Toast_Swift
import MaterialComponents

class VerifyOtpViewController: UIViewController {
    
    @IBOutlet weak var emailTf: MDCOutlinedTextField!
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var backtoLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Password Reset"
        navigationItem.largeTitleDisplayMode = .always
        confirmBtn.addTarget(self, action: #selector(getResetLink), for: .touchUpInside)
        
     
        
        
        
    }
    @IBAction func backtoLogin(_ sender: Any) {
        
        
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "loginVc") as! LoginViewController
        newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true)
    }
    @objc
    func  getResetLink()   {
        let emailget = emailTf.text
        if emailget == "" {
            let alert = UIAlertController(title: "Alert", message: "Email ID is empty", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else {
        
            Auth.auth().sendPasswordReset(withEmail: emailget!) { error in
          // ...
            if error == nil{
                self.view.makeToast("Reset Instructions sent to your Email")
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                               let newViewController = storyBoard.instantiateViewController(withIdentifier: "superHome") as! SuperHomeViewController
                self.present(newViewController, animated: true, completion: nil)
            }else{
                self.view.makeToast("Retry !l")
            }
        }
    }
    }
    
        
    
}
