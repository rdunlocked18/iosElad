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
    @IBOutlet weak var emailSuperProfile:UILabel!
    @IBOutlet weak var dpSuperProfile:UIImageView!
    
    @IBOutlet weak var uploadNewPhoto: UIButton!
    

    
    //extras
    @IBOutlet weak var daysLeftTitle: UILabel!
    @IBOutlet weak var daysleftMid: UILabel!
    
    @IBOutlet weak var bookedTitle: UILabel!
    @IBOutlet weak var bookedMid: UILabel!
    
    @IBOutlet weak var sessionsLbl: UILabel!
    @IBOutlet weak var validUntilLbl: UILabel!
    
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    
    
    //database vars
    var ref : DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    var nameGet:String!
    var phoneNumberGet:String!
    var emailGer:String!
    var ageGet:String!
    var imageUrl:String!
    
    
    var userRef : DatabaseReference!
    var classesRef : DatabaseReference!

    
    @IBOutlet weak var data1: UILabel!
    @IBOutlet weak var data2: UILabel!
    @IBOutlet weak var data3: UILabel!
    @IBOutlet weak var data4: UILabel!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    
    
    func readPackageDetails()  {
        self.userRef.child("userPackages").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let endDate = value?["endDate"] as? Int ?? 0
            //let startDate = value?["startDate"] as? String ?? ""
           // let packageId = value?["packageId"] as? String ?? ""
            let sessions = value?["sessions"] as? Int ?? 0
            let punishment = value?["punishment"] as? Bool ?? false
            

            
            
            let timestamp = Int(NSDate().timeIntervalSince1970)
            //let timeStamp = Date.currentTimeMillis()
            print("current \(timestamp)")
            
            
            let date = Date(timeIntervalSince1970: TimeInterval(endDate))
            let sdate = Date(timeIntervalSince1970: TimeInterval(timestamp))
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd/MM/yyyy" //Specify your format that you want
            
            let end = dateFormatter.string(from: date)
            let start = dateFormatter.string(from: sdate)
            
            
            let days = date.days(from: sdate)
            
           
            
            
            
                
                self.sessionsLbl.text = "\(sessions)"
                self.validUntilLbl.text = "Till  \(end)"
                
                self.daysleftMid.text  = "\(days)"
            
            
           
            
            
        }
    }
    
    func readUserClassesDetails()  {
        userRef.child("userClasses").observe(.value) { (snapshot) in
            if snapshot.childrenCount == nil {
                self.bookedMid.text = "0"
            } else {
                self.bookedMid.text = "\(snapshot.childrenCount)"
            }
            
            
            
        }
        
    }
    
    func readUserDetails(){
        self.userRef.child("userDetails").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let birthday = value?["birthday"] as? String ?? ""
            let height = value?["height"] as? String ?? ""
            let weight = value?["weight"] as? String ?? ""
            let gendet = value?["gender"] as? String ?? ""
            
            
            

            
            
            
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
        
        
        
        userRef.child("userClasses").observe(.value) { (snapshot) in
            if snapshot.childrenCount == 0 {
                self.bookedMid.text = "0"
            } else {
                self.bookedMid.text = "\(snapshot.childrenCount)"
            }
            
            
            
        }
        self.readPackageDetails()
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
            let weight = value?["weight"] as? String ?? ""
            let height = value?["height"] as? String ?? ""

            self.nameSuperProfile.text = name
            //self.phoneSuperProfile.text = phone
            self.emailSuperProfile.text = email
            self.weightLbl.text = "Weight = \(weight) KG"
            self.heightLbl.text = "Height = \(height) CM"
            
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

