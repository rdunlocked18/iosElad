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
import Toast_Swift
import iOSDropDown
import DatePicker




class CreateProfileViewController: UIViewController  {
    
    var ref = Database.database().reference()
    @IBOutlet weak var fullName: MDCTextField!
    @IBOutlet weak var phoneNumberGet: MDCTextField!
  
    @IBOutlet weak var heightTv: MDCTextField!
    @IBOutlet weak var genderTv: DropDown!
    
    @IBOutlet weak var dobTv: MDCTextField!
    @IBOutlet weak var weightTv: MDCTextField!
   
    
    
    @IBOutlet weak var createEmail: MDCTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        genderTv.optionArray = ["Male", "Female", "Other"]
        genderTv.didSelect { (selected, index, id) in
                print(selected)
        }
        dobTv.addTarget(self, action: #selector(todaySet), for: .touchDown)
        
    }
    
    @objc
    func todaySet(textField: UITextField){
        let minDate = DatePickerHelper.shared.dateFrom(day: 1, month: 12, year: 1950)!
        let maxDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 2015)!
        let today = Date()
        // Create picker object
        let datePicker = DatePicker()
        // Setup
        
        datePicker.setup(beginWith: today, min: minDate, max: maxDate) {
            (selected, date) in
            if selected, let selectedDate = date {
                let ofd:String = "\(selectedDate.day())/\(selectedDate.month())/\(selectedDate.year())"
                self.dobTv.text = ofd
                //self.filterTableWithDate(ofDate: ofd)
            }
            else {
                print("Cancelled")
            }
        }
        // Display
        datePicker.show(in: self )
        
        
       
        
    }
  
    override func viewWillAppear(_ animated: Bool) {
        var phone:String?
        var name:String?
        
        ref.child("Users").child(Auth.auth().currentUser?.uid ?? "").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            phone = value?["phone"] as? String ??  ""
            name = value?["fullName"] as? String ?? ""
            
        }
    
        if phone == "" || name == "" {
            
            self.view.makeToast("Create Profile")
            
        } else {
            //throw out of the view to Home Screen
           
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "superHome") as! SuperHomeViewController
                  self.present(newViewController, animated: true, completion: nil)
            print("switch")
            
            self.view.makeToast("You Can update you profile in Settings")
            
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool)  {
        
        
        
        
        //text Colors
        fullName.textColor = UIColor.black
        phoneNumberGet.textColor = UIColor.black
        createEmail.textColor = UIColor.black
        dobTv.textColor = UIColor.black
        heightTv.textColor = UIColor.black
        weightTv.textColor =  UIColor.black
        genderTv.textColor =  UIColor.black
        
        //iconColors
        fullName.clearButton.tintColor =  UIColor.black
        dobTv.clearButton.tintColor = UIColor.black
        phoneNumberGet.clearButton.tintColor = UIColor.black
        heightTv.clearButton.tintColor =  UIColor.black
        weightTv.clearButton.tintColor =  UIColor.black
       // genderTv.clearButton.tintColor =  UIColor.black
        
        
        //fonts
        fullName.font =  UIFont.appRegularFontWith(size: 15)
        dobTv.font = UIFont.appRegularFontWith(size: 15)
        phoneNumberGet.font = UIFont.appRegularFontWith(size: 15)
        createEmail.font = UIFont.appRegularFontWith(size: 15)
        heightTv.font =  UIFont.appRegularFontWith(size: 15)
        weightTv.font =  UIFont.appRegularFontWith(size: 15)
        genderTv.font =  UIFont.appRegularFontWith(size: 15)
        
        
        //placeholder
        fullName.placeholderLabel.font =  UIFont.appRegularFontWith(size: 15)
        dobTv.placeholderLabel.font = UIFont.appRegularFontWith(size: 15)
        phoneNumberGet.placeholderLabel.font = UIFont.appRegularFontWith(size: 15)
        createEmail.placeholderLabel.font = UIFont.appRegularFontWith(size: 15)
        heightTv.placeholderLabel.font =  UIFont.appRegularFontWith(size: 15)
        weightTv.placeholderLabel.font =  UIFont.appRegularFontWith(size: 15)
       // genderTv.placeholderLabel.font =  UIFont.appRegularFontWith(size: 15)
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                //print("Current user Phone = \(String(describing: user?.phoneNumber))")
                self.createEmail.text = user?.email
                
          } else {
            // No User is signed in. Show user the login screen
            
          }
        }
       
        
        
    }
    
    @IBAction func onFinishPressed(_ sender: Any) {
        
        sendMainDataToFb()
    }
    func sendMainDataToFb(){
        if fullName.text == "" || phoneNumberGet.text == "" || dobTv.text == "" || heightTv.text == "" || weightTv.text == ""
            || dobTv.text == "" || createEmail.text == "" {
            
            self.view.makeToast("One Of the Fields is Empty")
            
            
        } else{
          ref.child("Users").child(Auth.auth().currentUser?.uid ?? "").child("userDetails").setValue(
            [
            
                "email": createEmail.text!,
                "fullName": fullName.text!,
                "imageUrl": "null",
                "phone" : phoneNumberGet.text!,
                "height" : heightTv.text!,
                "userRole": "user",
                "weight" : weightTv.text!,
                "gender"  : genderTv.text!,
                "dateOfBirth" : dobTv.text!,
                
                
            ]) { (error, ref) in
            if error == nil{
                print("Data Stored User Created")
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "superHome") as! HomeViewController
                      self.present(newViewController, animated: true, completion: nil)
                
            }else {
                print("Failed To Store Data \(String(describing: error?.localizedDescription))")
            }
          }
        
    
        }
    }
    

}

