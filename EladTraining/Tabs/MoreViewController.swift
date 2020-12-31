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

class MoreViewController: UIViewController {
    //ui vars
    @IBOutlet weak var nameSuperProfile:UILabel!
    @IBOutlet weak var phoneSuperProfile:UILabel!
    @IBOutlet weak var emailSuperProfile:UILabel!
    @IBOutlet weak var packageSuperProfile:UILabel!
    @IBOutlet weak var sessionsSuperProfile:UILabel!
    @IBOutlet weak var dpSuperProfile:UIImageView!
    
    @IBOutlet weak var uploadNewPhoto: UIButton!
    

    var config = YPImagePickerConfiguration()
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
    @IBOutlet weak var profileTabel:UITableView!
    let viewNames:[String] = [
        "Your Classes",
        "Penalties",
        "Support" ,
        "Logout"]
    @objc
    func editProfile() {
        let blurView = UIVisualEffectView()
        blurView.frame = view.frame
        blurView.effect = UIBlurEffect(style: .regular)
        let alertVC = PMAlertController(title: "Edit Profile", description: phoneNumberGet,image: nil, style: .alert)
        alertVC.addTextField {
            (nameField) in
            nameField?.placeholder = "Name"
            nameField?.text = nameGet
        }
        alertVC.addTextField{
            (emailField) in
            emailField?.placeholder =  "Email"
            emailField?.text = emailGer
        }
        alertVC.addTextField{
            (ageField) in
            ageField?.placeholder =  "DOB"
            ageField?.text = ageGet
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
            self.ref.setValue(
                [
                    "age":  alertVC.textFields[2].text! ,
                    "email": alertVC.textFields[1].text! ,
                    "fullName": alertVC.textFields[0].text! ,
                    "imageUrl": self.imageUrl,
                    "phone" : self.phoneNumberGet,
                    "userRole": "user"
                ])
            {
                (error, ref) in
                if error == nil{
                    print("Data Stored User Created")
                    self.readAgain()
                }
            }
            for subview in self.view.subviews {
                if subview.isKind(of: UIVisualEffectView.self) {
                    subview.removeFromSuperview()
                }
            }
        }))
        view.addSubview(blurView)
        self.present(alertVC, animated: true, completion: nil)
       
    }
    
    @objc
    func startPicker(){
        
       print("hello")
        let picker = YPImagePicker(configuration: config)
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = true
        config.usesFrontCamera = false
        config.showsPhotoFilters = true
        config.showsVideoTrimmer = true
        config.shouldSaveNewPicturesToAlbum = true
        config.startOnScreen = YPPickerScreen.photo
        config.screens = [.library, .photo]
        config.showsCrop = .none
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesStatusBar = true
        config.hidesBottomBar = false
        config.hidesCancelButton = false
        config.preferredStatusBarStyle = UIStatusBarStyle.default
        config.library.options = nil
        config.library.onlySquare = false
        config.library.isSquareByDefault = true
        config.library.minWidthForItem = nil
        config.library.mediaType = YPlibraryMediaType.photo
        config.library.defaultMultipleSelection = false
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = false
        config.library.preselectedItems = nil

        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage) // Transformed image, can be nil
                print(photo.exifMeta) // Print exif meta data of original image.
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        present(picker, animated: true, completion: nil)
       
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        profileTabel.delegate = self
//        profileTabel.dataSource = self
        self.title = "Profile"
        uploadNewPhoto.addTarget(self, action: #selector(startPicker), for: .touchUpInside)
        let btnRefresh = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.compose, target: self, action: #selector(editProfile))
        navigationItem.rightBarButtonItem = btnRefresh
        self.navigationItem.largeTitleDisplayMode = .always
    }

    // MARK: - didLoad
    override func viewDidAppear(_ animated: Bool) {
        ref = Database.database().reference().child("Users").child(userID ?? "").child("userDetails");
        ref.observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.nameGet = value?["fullName"] as? String ?? ""
            self.phoneNumberGet = value?["phone"] as? String ?? ""
            self.emailGer = value?["email"] as? String ?? ""
            self.ageGet = value?["age"] as? String ?? ""
            self.imageUrl = value?["imageUrl"] as? String ?? ""
            
            self.nameSuperProfile.text = self.nameGet
            self.phoneSuperProfile.text = self.phoneNumberGet
            self.emailSuperProfile.text = self.emailGer
            
            print(self.nameGet ?? "def")
            Nuke.loadImage(with: ImageRequest(url: URL(string: self.imageUrl)!, processors: [
                ImageProcessors.Circle()
            ]), into: self.dpSuperProfile)
        })
        {
            (error) in
            print(error.localizedDescription)
        }
    }

    func readAgain() {
        ref = Database.database().reference().child("Users").child(userID ?? "").child("userDetails");
        ref.observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.nameGet = value?["fullName"] as? String ?? ""
            self.phoneNumberGet = value?["phone"] as? String ?? ""
            self.emailGer = value?["email"] as? String ?? ""
            self.ageGet = value?["age"] as? String ?? ""
            self.imageUrl = value?["imageUrl"] as? String ?? ""
           // print(self.nameGet ?? "")
        })
        {
            (error) in
            print(error.localizedDescription)
        }
    }

}
extension MoreViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            print(String(describing:"row at Edit Profile Clicked"))
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
        else if(indexPath.row == 1){
            print(String(describing:"row at Your Classes Clicked"))
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
        else if(indexPath.row == 2){
            print(String(describing:"row at Settings Clicked"))
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
        else if(indexPath.row == 3){
            print(String(describing:"row at Support Clicked"))
            
//            do {
//                try //Auth.auth().signOut()
//            //self.view.makeToast("Logging Out...",image: UIImage(named: "power"))
//
//
//            }
//            catch { print("already logged out") }
//
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    }

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
