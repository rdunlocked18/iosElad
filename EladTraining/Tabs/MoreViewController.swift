//
//  MoreViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//
import AVFoundation
import AVKit
import Firebase
import FirebaseStorage
import Nuke
import PMAlertController
import Toast_Swift
import UIKit

class MoreViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // ui vars
    @IBOutlet var nameSuperProfile: UILabel!
    @IBOutlet var emailSuperProfile: UILabel!
    @IBOutlet var dpSuperProfile: UIImageView!
    
    // functional buttons
    @IBOutlet var uploadNewPhoto: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var viewProfileButton: UIButton!
    
    // extras
    @IBOutlet var daysLeftTitle: UILabel!
    @IBOutlet var daysleftMid: UILabel!
    
    @IBOutlet var bookedTitle: UILabel!
    @IBOutlet var bookedMid: UILabel!
    
    @IBOutlet var sessionsLbl: UILabel!
    @IBOutlet var validUntilLbl: UILabel!
    
    @IBOutlet var weightLbl: UILabel!
    @IBOutlet var heightLbl: UILabel!
    
    // database vars
    var ref: DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    var nameGet: String!
    var phoneNumberGet: String!
    var emailGer: String!
    var ageGet: String!
    var imageUrl: String!
    var heightGet: String!
    var weightGet: String!
    
    var userRef: DatabaseReference!
    var classesRef: DatabaseReference!

    @objc
    func editProfile() {
        let blurView = UIVisualEffectView()
        blurView.frame = view.frame
        blurView.effect = UIBlurEffect(style: .systemChromeMaterial)
        let alertVC = PMAlertController(title: "Edit Profile", description: phoneNumberGet, image: nil, style: .alert)
        alertVC.addTextField {
            nameField in
            nameField?.placeholder = "Name"
            nameField?.text = nameGet
        }
        alertVC.addTextField {
            emailField in
            emailField?.placeholder = "Email"
            emailField?.text = emailGer
        }
        alertVC.addTextField {
            ageField in
            ageField?.placeholder = "DOB"
            ageField?.text = ageGet
        }
        alertVC.addTextField {
            weightFeild in
            weightFeild?.placeholder = "Weight(in KG)"
            weightFeild?.text = weightGet
        }
        alertVC.addTextField {
            heightField in
            heightField?.placeholder = "Height(in CM)"
            heightField?.text = heightGet
        }
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: {
            () -> Void in
            print("Capture action Cancel")
            for subview in self.view.subviews {
                if subview.isKind(of: UIVisualEffectView.self) {
                    subview.removeFromSuperview()
                }
            }
        }))
        alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: {
            () in
            print("Capture action OK")
                
            self.userRef.child("userDetails").child("fullName").setValue(alertVC.textFields[0].text ?? self.nameGet)
            self.userRef.child("userDetails").child("email").setValue(alertVC.textFields[1].text ?? self.ageGet)
            self.userRef.child("userDetails").child("dob").setValue(alertVC.textFields[2].text ?? self.weightGet)
            self.userRef.child("userDetails").child("weight").setValue(alertVC.textFields[3].text ?? self.heightGet)
            self.userRef.child("userDetails").child("height").setValue(alertVC.textFields[4].text ?? self.heightGet)
//                self.userRef.child("userDetails").child("fullname").setValue(alertVC.textFields[0].text! ?? "")
//                self.userRef.child("userDetails").child("fullname").setValue(alertVC.textFields[0].text! ?? "")
                
            for subview in self.view.subviews {
                if subview.isKind(of: UIVisualEffectView.self) {
                    self.readUserDetails()
                    subview.removeFromSuperview()
                }
            }
        }))
        view.addSubview(blurView)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc
    func logoutProfile() {
        let destroyAction = UIAlertAction(title: "Logout",
                                          style: .destructive) { _ in
            // Respond to user selection of the action
            do {
                try

                    Auth.auth().signOut()
                self.view.makeToast("Logout Success")
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "loginVc") as! LoginViewController
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true, completion: nil)

            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) { _ in
            // Respond to user selection of the action
            // self.dismiss(animated: true)
        }
                
        let alert = UIAlertController(title: "Confirm Logout ?",
                                      message: "Are you sure you want to signout ?",
                                      preferredStyle: .actionSheet)
        alert.addAction(destroyAction)
        alert.addAction(cancelAction)
                
        self.present(alert, animated: true)
    }
    
    func readPackageDetails() {
        self.userRef.child("userPackages").observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            let endDate = value?["endDate"] as? Int ?? 0
            // let startDate = value?["startDate"] as? String ?? ""
            // let packageId = value?["packageId"] as? String ?? ""
            let sessions = value?["sessions"] as? Int ?? 0
            let punishment = value?["punishment"] as? Bool ?? false
            
            let timestamp = Int(NSDate().timeIntervalSince1970)
            // let timeStamp = Date.currentTimeMillis()
            print("current \(timestamp)")
            
            let date = Date(timeIntervalSince1970: TimeInterval(endDate))
            let sdate = Date(timeIntervalSince1970: TimeInterval(timestamp))
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT") // Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd/MM/yyyy" // Specify your format that you want
            
            let end = dateFormatter.string(from: date)
            let start = dateFormatter.string(from: sdate)
            
            let days = date.days(from: sdate)
            
            self.sessionsLbl.text = "\(sessions)"
            self.validUntilLbl.text = "Till  \(end)"
                
            self.daysleftMid.text = "\(days)"
        }
    }
    
    func readUserClassesDetails() {
        self.userRef.child("userClasses").observe(.value) { snapshot in
            if snapshot.childrenCount == nil {
                self.bookedMid.text = "0"
            } else {
                self.bookedMid.text = "\(snapshot.childrenCount)"
            }
        }
    }
    
    func readUserDetails() {
        self.userRef.child("userDetails").observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            self.nameGet = value?["fullName"] as? String ?? ""
            self.phoneNumberGet = value?["phone"] as? String ?? ""
            self.emailGer = value?["email"] as? String ?? ""
            self.ageGet = value?["dob"] as? String ?? ""
            self.imageUrl = value?["imgurl"] as? String ?? ""

            let name = value?["fullName"] as? String ?? ""
            let phone = value?["phone"] as? String ?? ""
            let email = value?["email"] as? String ?? ""
            
            let img = value?["imageUrl"] as? String ?? ""
            let weight = value?["weight"] as? String ?? ""
            let height = value?["height"] as? String ?? ""
            
            self.nameSuperProfile.text = name
            // self.phoneSuperProfile.text = phone
            self.emailSuperProfile.text = email
            self.weightLbl.text = "Weight = \(weight) KG"
            self.heightLbl.text = "Height = \(height) CM"
            self.heightGet = height
            self.weightGet = weight
        }
    }
    
    @IBAction func tapCameraButton() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
        guard let im: UIImage = info[.editedImage] as? UIImage else { return }
        guard let d: Data = im.jpegData(compressionQuality: 0.5) else { return }

        let md = StorageMetadata()
        md.contentType = "image/png"

        let Storref = Storage.storage().reference().child("userProfileImages").child("\(self.userID!)")

        Storref.putData(d, metadata: md) { _, error in
            if error == nil {
                Storref.downloadURL(completion: { url, _ in
                    print("Done, url is \(String(describing: url))")
                    Nuke.loadImage(with: ImageRequest(url: url!, processors: [
                        ImageProcessors.Circle()
                    ]), into: self.dpSuperProfile)
                    self.ref.child("userDetails").child("imageUrl").setValue("\(url!)")
                })
            } else {
                print("error \(String(describing: error))")
            }
        }

        dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.userRef = Database.database().reference().child("Users").child(self.userID!)
        self.readUserDetails()
        
        self.userRef.child("userClasses").observe(.value) { snapshot in
            if snapshot.childrenCount == 0 {
                self.bookedMid.text = "0"
            } else {
                self.bookedMid.text = "\(snapshot.childrenCount)"
            }
        }
        self.readPackageDetails()

        // MARK: - check date with classes and return tableview only if class is present on that day

        self.ref = Database.database().reference().child("Users").child(self.userID!)
        self.ref.child("userDetails").observeSingleEvent(of: .value, with: {
            snapshot in
            let value = snapshot.value as? NSDictionary
            self.nameGet = value?["fullName"] as? String ?? ""
            self.phoneNumberGet = value?["phone"] as? String ?? ""
            self.emailGer = value?["email"] as? String ?? ""
            self.ageGet = value?["dob"] as? String ?? ""
            self.imageUrl = value?["imgurl"] as? String ?? ""

            let name = value?["fullName"] as? String ?? ""
            let phone = value?["phone"] as? String ?? ""
            let email = value?["email"] as? String ?? ""
            let age = value?["age"] as? String ?? ""
            let img = value?["imageUrl"] as? String ?? ""
            let weight = value?["weight"] as? String ?? ""
            let height = value?["height"] as? String ?? ""
            
            self.nameSuperProfile.text = name
            // self.phoneSuperProfile.text = phone
            self.emailSuperProfile.text = email
            self.weightLbl.text = "Weight = \(weight) KG"
            self.heightLbl.text = "Height = \(height) CM"
            
            print(self.nameGet ?? "def")

            if img == "" || img == nil || img == "null" {
            } else {
                Nuke.loadImage(with: ImageRequest(url: URL(string: img)!, processors: [
                    ImageProcessors.Circle()

                ]), into: self.dpSuperProfile)
            }

        }) {
            error in
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Profile"
        
        self.editButton.addTarget(self, action: #selector(self.editProfile), for: .touchUpInside)
        self.logoutButton.addTarget(self, action: #selector(self.logoutProfile), for: .touchUpInside)
        self.nameSuperProfile.font = UIFont.appBoldFontWith(size: 25)
//        self.phoneSuperProfile.font = UIFont.appRegularFontWith(size: 16)
        self.emailSuperProfile.font = UIFont.appRegularFontWith(size: 16)

        self.nameSuperProfile.textColor = .black
       
        self.emailSuperProfile.textColor = .black
    }

    // MARK: - didLoad
}

extension MoreViewController {
    /* Gives a resolution for the video by URL */
    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}

// YPImagePickerDelegate
