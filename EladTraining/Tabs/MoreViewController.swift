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
import YPImagePicker
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
            let img = value?["imgurl"] as! String
                
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
      //  uploadNewPhoto.addTarget(self, action: #selector(startPicker), for: .touchUpInside)
        
        
        
        
        
//        let storageRef = Storage.storage().reference().child("userProfileImages").child("\(self.userID!).jepg")
//        if let uploadData = photo.image.jpegData(compressionQuality: 0.4) {
//            storageRef.putData(uploadData, metadata: nil) { (meta, error) in
//                if error == nil {
//
//                    storageRef.downloadURL(completion: { (url, error) in
//
//                        print(url?.absoluteString ?? "")
//                        self.ref.child("userDetails").child("imgurl").setValue("\(url!)")
//                        Nuke.loadImage(with: ImageRequest(url: url!, processors: [
//                            ImageProcessors.Circle()
//                        ]), into: self.dpSuperProfile)
//                                    })
//
//
//                }
//            }
//
//    }
        
        
        
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
extension MoreViewController: YPImagePickerDelegate {
    func noPhotos() {}

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true// indexPath.row != 2
    }
}
