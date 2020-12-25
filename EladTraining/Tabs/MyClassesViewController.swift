//
//  MyClassesViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//

import UIKit
import Firebase
import FirebaseDatabase
import Nuke
import MaterialComponents.MaterialBottomSheet

class MyClassesViewController: UIViewController {
    
    
    
    @IBOutlet weak var myclassView: UIView!
    
    
    @IBOutlet weak var myClassesTableView: UITableView!
    var classNamesList:[String] = []
    var classFulldetList = [ScheduleClasses]()
    
    var ref:DatabaseReference!
    
    
    
    //All vars of the data
    var authUid:String! = Auth.auth().currentUser?.uid
    var userClassesRef:DatabaseReference!
    var classesRef:DatabaseReference!
    var userPkgRef:DatabaseReference!
    
    
    
    
    
    @objc
    func checkAction(sender : UITapGestureRecognizer) {
        let viewController: ViewController = ViewController()
        // Initialize the bottom sheet with the view controller just created
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        // At this point perform any customizations, like adding a slider, for example.
        // Present the bottom sheet
        present(bottomSheet, animated: true, completion: nil)
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Classes"
      
        //inits of database vars
       userClassesRef = Database.database().reference().child("Users").child(authUid).child("userClasses")
        
        classesRef = Database.database().reference().child("Classes").child("").child("usersJoined")
        
        userPkgRef = Database.database().reference().child("Users").child(authUid).child("userPackages")
        
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.myclassView.addGestureRecognizer(gesture)

        
        
        myClassesTableView.dataSource = self
        myClassesTableView.delegate = self
        
        
        ref = Database.database().reference()
       
            ref.child("Users").child(authUid).child("userClasses").observe(.value) { snapshot in
                for child in snapshot.children {
                    let ns = child as! DataSnapshot
                    let dict = ns.value as! String
                    self.classNamesList.append(dict)
                print(self.classNamesList)
              }
                self.myClassesTableView.reloadData()
            }
        
        
    }
    
    func readUsersJoinedData()  {
        ref.child("Users").child(authUid).child("userClasses").observe(.value) { snapshot in
            for child in snapshot.children {
                let ns = child as! DataSnapshot
                let dict = ns.value as! String
                self.classNamesList.append(dict)
            print(self.classNamesList)
          }
            self.myClassesTableView.reloadData()
        }
    
    }
    func readUserpkgData() {
        
    }
        
    func readClassesData(){
        //MARK:- Get Firebase Data
        ref.child("Classes").observe(DataEventType.value,with:{
            (snapshot) in
            if snapshot.childrenCount > 0{
                self.classFulldetList.removeAll()
                for classesSch in snapshot.children.allObjects as![DataSnapshot]{
                    let classesSchObject = classesSch.value as? [String:AnyObject]
                    
                    let id = classesSchObject?["id"]
                    let capacity = classesSchObject?["capacity"]
                    let coach = classesSchObject?["coach"]
                    let date = classesSchObject?["date"]
                    let description = classesSchObject?["description"]
                    let name = classesSchObject?["name"]
                    let timings = classesSchObject?["timings"]
                    let usersJoined = classesSchObject?["usersJoined"]
                    let lister = ScheduleClasses(id:id as! String?,capacity: capacity as? Int, coach: (coach as! String), date: (date as? String), description: (description as! String), name: name as? String, timings: timings as? String,userJoined: usersJoined as! [String]?)
                    self.classFulldetList.append(lister)
                }
                
            }
        })
        
        
        
        
        
    }
    
    
override func viewDidAppear(_ animated: Bool) {
    self.myClassesTableView.backgroundColor = UIColor(named: "someCyan")
    self.myClassesTableView.showActivityIndicator()
}
}
        
extension MyClassesViewController : UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classNamesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myClassesTableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath) as! MyClassesCellTableViewCell
        
        myClassesTableView.hideActivityIndicator()
        cell.classNameLbl?.text =  classNamesList[indexPath.row]
    
        return cell
        
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let cell = self.myClassesTableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath) as! MyClassesCellTableViewCell
        
        self.myClassesTableView.hideActivityIndicator()

        
        // 1
            let shareAction = UITableViewRowAction(style: .default, title: "Leave Class" , handler: { (action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            // 2
                let shareMenu = UIAlertController(title: "Confirm Leave \(self.classNamesList[indexPath.row]) ?" , message: "Are You Sure want to Leave the class ? This might lead to punishment if you leave the class just within 8 hours duration", preferredStyle: .alert)
                    
                let twitterAction = UIAlertAction(title: "Sure", style: .default, handler: { _ in handleTrue()})
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                func handleTrue(){
                    print("hello")
                    // punishment
                    // if current time is equal to or less than class timings minus 8 hours then apply punishment}
                    // else refund the sessions i.e add plus session back to user
                    // and remove all the details from userClasses, classes -> userJoined
                    // @todo add variable : isActive and onPunishment
                    
                    
                    
                    
                    
                    
                    
                }
                
            shareMenu.addAction(twitterAction)
            shareMenu.addAction(cancelAction)
                    
            self.present(shareMenu, animated: true, completion: nil)
            })

       
            return [shareAction]
    }
    
    
    
    
}





