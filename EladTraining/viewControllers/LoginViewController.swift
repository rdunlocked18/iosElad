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
import Toast_Swift



class LoginViewController: UIViewController {
    @IBOutlet weak var passwordInp: MDCTextField!
    @IBOutlet weak var emailAddressInp: MDCTextField!
    
    @IBOutlet weak var forgotPassBtn: MDCButton!
    @IBOutlet weak var proceedBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    
        
        
      
        
        
               
    }
    
    
    @objc
    func  loginTry(){
        let email:String = emailAddressInp.text ?? ""
        let password:String  = passwordInp.text ?? ""
        
        
        
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            if error == nil{
                self?.view.makeToast("Logged in Successfully")
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                               let newViewController = storyBoard.instantiateViewController(withIdentifier: "superHome") as! SuperHomeViewController
                self?.present(newViewController, animated: true, completion: nil)
            }else {
                print("\(String(describing: error?.localizedDescription))")
                self?.view.makeToast("Error Logginng In")
            }
            
          // ...
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        
        
        emailAddressInp.placeholderLabel.font = UIFont.appRegularFontWith(size: 17)
        passwordInp.placeholderLabel.font = UIFont.appRegularFontWith(size: 17)
        proceedBtn.addTarget(self, action: #selector(loginTry), for: .touchUpInside)
        
        
        
        
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
            // User is signed in. Show home screen
                print("success user alreaddy logged in")
                self.view.makeToast("Already Signed in")
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "superHome") as! SuperHomeViewController
                      self.present(newViewController, animated: true, completion: nil)
          } else {
            // No User is signed in. Show user the login screen
            self.view.makeToast("Login To Continue")
            
          }
        }
        
    }

    
    
}
