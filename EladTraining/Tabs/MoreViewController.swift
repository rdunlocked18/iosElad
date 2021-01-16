//
//  MoreViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//
import UIKit
import PMAlertController
import Firebase
import Nuke
import Toast_Swift
import AVFoundation
import AVKit
import FirebaseStorage


class MoreViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //ui vars
    @IBOutlet weak var nameSuperProfile:UILabel!
    @IBOutlet weak var phoneSuperProfile:UILabel!
    @IBOutlet weak var emailSuperProfile:UILabel!
    @IBOutlet weak var packageSuperProfile:UILabel!
    @IBOutlet weak var sessionsSuperProfile:UILabel!
    @IBOutlet weak var dpSuperProfile:UIImageView!
    
    @IBOutlet weak var uploadNewPhoto: UIButton!
    

    
    // [Edit configuration here ...]
    // Build a picker with your configuration
    
    //database vars
    var ref : DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    var nameGet:String!
    var phoneNumberGet:String!
    var emailGer:String!
    var ageGet:String!
    var imageUrl:String!
    
    
    var userRef : DatabaseReference!
   
    @IBOutlet weak var data1: UILabel!
    @IBOutlet weak var data2: UILabel!
    @IBOutlet weak var data3: UILabel!
    @IBOutlet weak var data4: UILabel!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    
    @IBOutlet weak var tabBar: UISegmentedControl!
    @IBAction func editProfilePressed(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "createProfile") as! CreateProfileViewController
        newViewController.modalPresentationStyle = .popover
              self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func tabChanged(_ sender: Any) {
        if tabBar.selectedSegmentIndex == 0 {
            readUserDetails()
        } else if tabBar.selectedSegmentIndex == 1 {
            readPackageDetails()
        }
        
    }
    
    func readPackageDetails()  {
        self.userRef.child("userPackages").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let endDate = value?["endDate"] as? String ?? ""
            let startDate = value?["startDate"] as? String ?? ""
            let packageId = value?["packageId"] as? String ?? ""
            let sessions = value?["sessions"] as? String ?? ""
            let punishment = value?["punishment"] as? Bool ?? false
            
            
//            self.data1.font = UIFont.appRegularFontWith(size: 17)
//            self.data2.font = UIFont.appRegularFontWith(size: 17)
//            self.data3.font = UIFont.appRegularFontWith(size: 17)
//            self.data4.font = UIFont.appRegularFontWith(size: 17)
//
//            self.data1.text = packageId
//            self.data2.text = sessions
//            self.data3.text = "Session ends on \(endDate)"
//
//            if punishment {
//                self.data4.textColor = .red
//                self.data4.text = "You are on Punishment"
//                self.img4.image = UIImage(named: "punishment")
//            } else {
//                self.data4.isHidden = true
//                self.img4.isHidden = true
//            }
//
//            self.img1.image = UIImage(named: "money")
//            self.img2.image = UIImage(named: "dumbell")
//            self.img3.image = UIImage(systemName: "calender")
           
            
            
            
        }
    }
    
    func readUserDetails(){
        self.userRef.child("userDetails").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let birthday = value?["birthday"] as? String ?? ""
            let height = value?["height"] as? String ?? ""
            let weight = value?["weight"] as? String ?? ""
            let gendet = value?["gender"] as? String ?? ""
            
            
//            self.data1.font = UIFont.appRegularFontWith(size: 17)
//            self.data2.font = UIFont.appRegularFontWith(size: 17)
//            self.data3.font = UIFont.appRegularFontWith(size: 17)
//            self.data4.font = UIFont.appRegularFontWith(size: 17)
//
//            self.data1.text = "\(weight) KG"
//            self.data2.text = "\(height) CM"
//            self.data3.text = birthday
//            self.data4.isHidden = true
//
//            self.img1.image = UIImage(named: "weight")
//            self.img2.image = UIImage(named: "heightset")
//            self.img3.image = UIImage(named: "birthday")
//            self.img4.isHidden = true
            
            
            
        }
        
    }
    
    
    
    
    @IBAction func tapCameraButton() {
    let picker = UIImagePickerController()
    picker.allowsEditing = true
    picker.delegate = self
    present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

     guard let im: UIImage = info[.editedImage] as? UIImage else { return }
     guard let d: Data = im.jpegData(compressionQuality: 0.5) else { return }

     let md = StorageMetadata()
     md.contentType = "image/png"

        let Storref = Storage.storage().reference().child("userProfileImages").child("\(userID!)")

        Storref.putData(d, metadata: md) { (metadata, error) in
         if error == nil {
            Storref.downloadURL(completion: { (url, error) in
                 print("Done, url is \(String(describing: url))")
                Nuke.loadImage(with: ImageRequest(url: url!, processors: [
                                         ImageProcessors.Circle()
                                       ]), into: self.dpSuperProfile)
                self.ref.child("userDetails").child("imgurl").setValue("\(url!)")
             })
         }else{
             print("error \(String(describing: error))")
         }
     }

     dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userRef = Database.database().reference().child("Users").child(userID!)
        
        //MARK:- check date with classes and return tableview only if class is present on that day
        ref = Database.database().reference().child("Users").child(userID!);
        ref.child("userDetails").observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.nameGet = value?["fullName"] as? String ?? ""
            self.phoneNumberGet = value?["phone"] as? String ?? ""
            self.emailGer = value?["email"] as? String ?? ""
            self.ageGet = value?["age"] as? String ?? ""
            self.imageUrl = value?["imgurl"] as? String ?? ""

            let name = value?["fullName"] as? String ?? ""
            let phone  = value?["phone"] as? String ?? ""
            let email = value?["email"] as? String ?? ""
            let age = value?["age"] as? String ?? ""
            let img = value?["imageUrl"] as? String ?? ""

            self.nameSuperProfile.text = name
            //self.phoneSuperProfile.text = phone
            self.emailSuperProfile.text = email


            print(self.nameGet ?? "def")


            if img == "" || img == nil  || img == "null"{

            }else{
                Nuke.loadImage(with: ImageRequest(url: URL(string: img)!, processors: [
                    ImageProcessors.Circle()

                ]), into: self.dpSuperProfile)
            }

        })
        {
            (error) in
            print(error.localizedDescription)
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Profile"
    
        
        
        

        
        
        
        //font configs
        
        self.nameSuperProfile.font = UIFont.appBoldFontWith(size: 25)
//        self.phoneSuperProfile.font = UIFont.appRegularFontWith(size: 16)
        self.emailSuperProfile.font = UIFont.appRegularFontWith(size: 16)

        self.nameSuperProfile.textColor = .black
        //self.phoneSuperProfile.textColor = .black
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

