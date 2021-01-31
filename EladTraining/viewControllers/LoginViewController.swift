//
//  LoginViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 07/12/20.
//

import Firebase
import FirebaseAuth
import FlagPhoneNumber
import MaterialComponents
import Toast_Swift
import TransitionButton
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var passwordInp: UITextField!
    @IBOutlet var emailAddressInp: UITextField!
    
    @IBOutlet var forgotPassBtn: MDCButton!
    @IBOutlet var proceedBtn: TransitionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        forgotPassBtn.addTarget(self, action: #selector(switchToForget), for:   .touchUpInside)
        
    }
    @objc
    func switchToForget() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "verifyOtp") as! VerifyOtpViewController
        
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true)
        
    }
    
    
    @objc
    func loginTry() {
        let email: String = emailAddressInp.text ?? ""
        let password: String = passwordInp.text ?? ""
        proceedBtn.startAnimation()
        if email == "" || password == "" {
            let alert = UIAlertController(title: "Error !", message: "Email ID or Password is empty", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.proceedBtn.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.5)
        } else {
            
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                self.proceedBtn.stopAnimation(animationStyle: .expand, revertAfterDelay: 1) {
                    Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
                        guard self != nil else { return }
                        if error == nil {
              
                                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "superHome") as! SuperHomeViewController
                                    self?.present(newViewController, animated: true)
                              

                            self?.view.makeToast("Logged in Successfully")
                        } else {
                            print("\(String(describing: error?.localizedDescription))")
                            self?.view.makeToast("Error Logginng In")
                        }

                    
                    }
                }
               
            }
            
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
                let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
                backgroundQueue.async(execute: {
                    
                    sleep(2) // 3: Do your networking task or background work here.
                    
                    
                   
                })
        

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailAddressInp.font = UIFont.appRegularFontWith(size: 17)
        passwordInp.font =  UIFont.appRegularFontWith(size: 17)
        emailAddressInp.addPadding(padding: .left(10))
        passwordInp.addPadding(padding: .left(10))
        emailAddressInp.layer.cornerRadius = 10.0
        emailAddressInp.layer.borderWidth = 1.0
        emailAddressInp.layer.borderColor = UIColor.black.cgColor
        passwordInp.layer.cornerRadius = 10.0
        passwordInp.layer.borderWidth = 1.0
        passwordInp.layer.borderColor = UIColor.black.cgColor
        
        
        passwordInp.textContentType = .password
        proceedBtn.addTarget(self, action: #selector(loginTry), for: .touchUpInside)
        
        Auth.auth().addStateDidChangeListener { _, user in
            if user != nil {
                // User is signed in. Show home screen
                print("success user alreaddy logged in")
                self.view.makeToast("Already Signed in")
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "superHome") as! SuperHomeViewController
                self.present(newViewController, animated: true, completion: nil)
            } else {
                // No User is signed in. Show user the login screen
                self.view.makeToast("Login To Continue")
            }
        }
    }
}
