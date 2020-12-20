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
class MoreViewController: UIViewController {
    //ui vars
    @IBOutlet weak var nameSuperProfile:UILabel!
    @IBOutlet weak var phoneSuperProfile:UILabel!
    @IBOutlet weak var emailSuperProfile:UILabel!
    @IBOutlet weak var packageSuperProfile:UILabel!
    @IBOutlet weak var sessionsSuperProfile:UILabel!
    @IBOutlet weak var dpSuperProfile:UIImageView!
    
    

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

    override func viewDidLoad() {
        super.viewDidLoad()
        profileTabel.delegate = self
        profileTabel.dataSource = self
        self.title = "Profile"
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
            print(self.nameGet)
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
            
            do {
                try //Auth.auth().signOut()
                self.view.makeToast("Logging Out...",image: UIImage(named: "power"))
                
                
            }
            catch { print("already logged out") }
            
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    }

}
extension MoreViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath)
        cell.textLabel?.text = viewNames[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.font = UIFont(name: "Poppins-Medium", size: 18)
        cell.imageView?.frame = CGRect(x:0,y:0,width: 24,height:24);
        cell.textLabel?.textColor = UIColor.white
        if(indexPath.row == 0)
        {
            cell.imageView?.image = UIImage(systemName: "pencil.circle")
        }
        else if(indexPath.row == 1){
            cell.imageView?.image = UIImage(systemName: "person.fill.viewfinder")
        }
        else if(indexPath.row == 2){
            cell.imageView?.image = UIImage(systemName: "gear")
        }
        else if(indexPath.row == 3){
            cell.imageView?.image = UIImage(systemName: "phone.connection")
        }
        else{
            cell.imageView?.image = UIImage(systemName: "gear")
        }
        return cell
    }

}

