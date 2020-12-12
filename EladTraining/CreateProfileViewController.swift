//
//  CreateProfileViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 09/12/20.
//

import UIKit
import MaterialComponents
import Firebase
import FirebaseDatabase


class CreateProfileViewController: UIViewController {
    
    var ref = Database.database().reference()
    @IBOutlet weak var fullName: MDCTextField!
    @IBOutlet weak var phoneNumberGet: MDCTextField!
  
    
    @IBOutlet weak var createAge: MDCTextField!
    
    
    @IBOutlet weak var createEmail: MDCTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

       
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //text Colors
        fullName.textColor = UIColor.white
        phoneNumberGet.textColor = UIColor.white
        createEmail.textColor = UIColor.white
        createAge.textColor = UIColor.white
        
        
        //iconColors
        fullName.clearButton.tintColor = UIColor.white
        phoneNumberGet.clearButton.tintColor = UIColor.white
        createEmail.clearButton.tintColor = UIColor.white
        createAge.clearButton.tintColor = UIColor.white
        
        
        
    
        phoneNumberGet.isEnabled = false
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                print("Current user Phone = \(String(describing: user?.phoneNumber))")
                self.phoneNumberGet.text = user?.phoneNumber
                
          } else {
            // No User is signed in. Show user the login screen
            
          }
        }
        
    }
    
    @IBAction func onFinishPressed(_ sender: Any) {
        
        sendMainDataToFb()
    }
    func sendMainDataToFb(){
        
          ref.child("Users").child(Auth.auth().currentUser?.uid ?? "").child("userDetails").setValue(
            [
                "age": createAge.text!,
                "email": createEmail.text!,
                "fullName": fullName.text!,
                "imageUrl": "",
                "phone" : phoneNumberGet.text,
                "userRole": "user"
            ]) { (error, ref) in
            if error == nil{
                print("Data Stored User Created")
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "superHome") as! SuperHomeViewController
                      self.present(newViewController, animated: true, completion: nil)
                
            }else {
                print("Failed To Store Data \(String(describing: error?.localizedDescription))")
            }
          }
        
    
        
    }
    

}

