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
//import ClockKit

class MyClassesViewController: UIViewController {
    
    
    
    @IBOutlet weak var myclassView: UIView!
    
    
    @IBOutlet weak var myClassesTableView: UITableView!
    var userJoinedClassesList:[String] = []
    var classFulldetList = [ScheduleClasses]()
    var packageDetailsList = [UserPackageModel]()
    
    
    var ref:DatabaseReference!
    
    
    
    //All vars of the data
    var authUid:String! = Auth.auth().currentUser?.uid
    var userClassesRef:DatabaseReference!
    var classesRef:DatabaseReference!
    var userPkgRef:DatabaseReference!
    var userRef:DatabaseReference!
    
    
    
    
    // packageDetails
    
    
    var packageId:String?
    var endDate:String?
    var startDate:String?
    var isActive:Bool?
    var sessions:Int?
    var punishmentTimeStamp:Int?
    var punishment : Bool?
    let refreshControl = UIRefreshControl()
    
    @objc
    func checkAction(sender : UITapGestureRecognizer) {
        let viewController: ViewController = ViewController()
        // Initialize the bottom sheet with the view controller just created
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        // At this point perform any customizations, like adding a slider, for example.
        // Present the bottom sheet
        present(bottomSheet, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK:- check date with classes and return tableview only if class is present on that day
       
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Classes"
        
        
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        //inits of database vars
        
        //self.navigationController?.navigationBar.backgroundColor = .black
        userClassesRef = Database.database().reference().child("Users").child(authUid).child("userClasses")
        
        classesRef = Database.database().reference().child("Classes")
        
        userPkgRef = Database.database().reference().child("Users").child(authUid).child("userPackages")
        
        userRef = Database.database().reference().child("Users").child(authUid)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.myclassView.addGestureRecognizer(gesture)
        
        
        
        myClassesTableView.dataSource = self
        myClassesTableView.delegate = self
        myClassesTableView.refreshControl = refreshControl
        
        ref = Database.database().reference()
        
        ref.child("Users").child(authUid).child("userClasses").observe(.value) { snapshot in
            for child in snapshot.children {
                let ns = child as! DataSnapshot
                let dict = ns.value as! String
                self.userJoinedClassesList.append(dict)
                print(self.userJoinedClassesList)
                
                
            }
            
            self.readClassesData(classId: self.userJoinedClassesList)
            
        }
        readUserpkgData()
        
    }
     
    func hitNotification(classId: String, className: String, timeStamp: Int){
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Hey ! Reminder for your class "
        content.body = " your class \("testing") is after 30 mins"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "yourIdentifier"
        content.userInfo = ["example": "information"] // You can retrieve this when displaying notification

        // Setup trigger time
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let testDate = Date() + 5 // Set this to whatever date you need
        //let trigger = UNCalendarNotificationTrigger(dateMatching: startDate, repeats: false)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeStamp - 1800), repeats: false)
        // Create request
        let uniqueID = UUID().uuidString // Keep a record of this if necessary
        let request = UNNotificationRequest(identifier: classId, content: content, trigger: trigger)
        center.add(request) // Add the notification request
        print("time \(TimeInterval(timeStamp - 1800))")
    }
    
    @objc
    func refresh(sender:AnyObject)
    {
        // Updating your data here...

        self.myClassesTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func getClassesFromIds(){
        classesRef.observe(.value) { (snapshot) in
            for ds in self.userJoinedClassesList {
                if(self.userJoinedClassesList.isEmpty){
                    print("not joined")
                }else{
                    print("value of \(ds)")
                    self.readClassesData(classId: [ds])
                    
                }
            }
            
        }
        
    }
    
    
    func readUserpkgData() {
        
        //MARK:- Get Firebase Data
        self.userPkgRef.observeSingleEvent(of:.value,with: {
            (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            self.packageId = value?["packageId"] as? String  ?? ""
            self.endDate = value?["endDate"] as? String ?? ""
            self.startDate = value?["startDate"] as? String ?? ""
            self.isActive = value?["active"] as? Bool ?? true
            self.sessions = value?["sessions"] as? Int ?? 0
            self.punishment = value?["punishment"] as? Bool ?? false
            self.punishmentTimeStamp = value?["punishmentTimeStamp"] as? Int ?? 0
            //let  = userPackageDetailsObject?["sessions"]
            print (" inside 8 less \(String(describing: self.packageId))")
         
            
        })
    }
    
    func readClassesData(classId:[String]){
        //MARK:- Get Firebase Data
        print("Got class id \(classId)")
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
                    let timeStamp = classesSchObject?["timeStamp"]
                    let usersJoined = classesSchObject?["usersJoined"]
                    
                    let lister = ScheduleClasses(id:id as! String?,capacity: capacity as? Int, coach: (coach as! String), date: (date as? String), description: (description as! String), name: name as? String, timings: timings as? String,timestamp: timeStamp as? Int,userJoined: usersJoined as! [String]?)
                    
                    print(self.classFulldetList)
                    
                    for ids in classId {
                        if ids == id as! String {
                            self.classFulldetList.append(lister)
                            print("my joined classes \(self.classFulldetList.count)")
                            
                        }
                        
                    }
                    
                }
                self.myClassesTableView.reloadData()
            }
            
                
           
            
        })
        self.myClassesTableView.rowHeight = 155
        self.myClassesTableView.reloadData()
//        if classFulldetList.isEmpty{
//
//            self.view.makeToast("No Classes Found")
//            self.myClassesTableView.hideActivityIndicator()
//            self.myClassesTableView.removeFromSuperview()
//
//        }else {
//
//        }
        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //self.myClassesTableView.backgroundColor = .white
        //self.myClassesTableView.showActivityIndicator()
       // self.myClassesTableView.rowHeight = 155
    }
}

extension MyClassesViewController : UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classFulldetList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myClassesTableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath) as! MyClassesCellTableViewCell
        
        myClassesTableView.hideActivityIndicator()
        let addedClasses : ScheduleClasses
        addedClasses = classFulldetList[indexPath.row]
        cell.classNameLbl?.text =  addedClasses.name
        cell.classDateLbl?.text = addedClasses.date
        cell.classTimeLbl?.text = addedClasses.timings
        
        
        //setup ui
        cell.classNameLbl.font = UIFont.appBoldFontWith(size: 22)
        cell.classDateLbl.font = UIFont.appRegularFontWith(size: 17)
        cell.classTimeLbl.font = UIFont.appRegularFontWith(size: 17)
        hitNotification(classId: addedClasses.id, className: addedClasses.name ,timeStamp: addedClasses.timestamp)
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let cell = self.myClassesTableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath) as! MyClassesCellTableViewCell
        
        
        
        self.myClassesTableView.hideActivityIndicator()
        let addedClasses : ScheduleClasses
        addedClasses = classFulldetList[indexPath.row]
        
        
        // 1
        let shareAction = UITableViewRowAction(style: .default, title: "Leave Class" , handler: { (action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            // 2
            let shareMenu = UIAlertController(title: "Confirm Leave \(addedClasses.name) ?" , message: "Are You Sure want to Leave the class ? This might lead to punishment if you leave the class just within 8 hours duration", preferredStyle: .alert)
            
            let twitterAction = UIAlertAction(title: "Sure", style: .default, handler: { _ in handleTrue()})
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            func handleTrue(){
                print("hello")
                // punishment
                // if current time is equal to or less than class timings minus 8 hours then apply punishment}
                // else refund the sessions i.e add plus session back to user
                // and remove all the details from userClasses, classes -> userJoined
                // @todo add variable : isActive and onPunishment
                let gotTimeStamp = addedClasses.timestamp
                print("got time \(gotTimeStamp)")
                
                
                let timestamp = Int(NSDate().timeIntervalSince1970)
                //let timeStamp = Date.currentTimeMillis()
                print("current \(timestamp)")
                
                
                // To get the hours
                
                let difference = Int(gotTimeStamp-timestamp)
                let inHours = difference / 3600
                print ("date is \(inHours)")
                
                
                // MARK:- Logic for main punishment and set value of array
                
                print(addedClasses.usersJoined)
                
               
                
                if (inHours <= 8){
                    //apply punishment
                    
                    if self.isActive!  {
                        if self.punishment! {
                            self.view.makeToast("Already on Punishment")
                        }else{

                            let currentPunishmentTimeStamp = Int(NSDate().timeIntervalSince1970)
                            self.userPkgRef.child("punishment").setValue(true)
                            self.userPkgRef.child("punishmentTimeStamp") .setValue(currentPunishmentTimeStamp)
                            self.view.makeToast("Punishment Applied Classes Disabled")
                            
                        }
                    } else {
                        self.view.makeToast("package is not active ask admins")
                    }
                    
                    print ("inside 8 less \(String(describing: self.packageId!))")
                    
                }else {
                    // remove without punishment
                    if self.isActive!  {
                        if self.punishment! {
                            self.view.makeToast("Already on Punishment")
                        }else{
                            self.userPkgRef.child("punishment").setValue(false) { (error, ref) in
                                self.userPkgRef.child("punishmentTimeStamp") .setValue(0)
                                // @add refund session here and remove the classId from userClasses & remove the uid from class-> usersJoined
                                // remove Id from userClasses and remove uid from usersJoined from Class Id
                                self.userPkgRef.child("sessions").setValue(self.sessions! + 1)
                                
                                
                                var usersInClassList:[String] = addedClasses.usersJoined
                                for users in usersInClassList {
                                    if users == self.authUid {
                                        print("user is present")
                                        usersInClassList.remove(at: usersInClassList.firstIndex(of: self.authUid)!)
                                        print("removed list : \(usersInClassList)")
                                        //push the new lst now
                                        // setval(newlist)/
                                        //push value to the classes > ClassesId > usersJoined > ["",""]
                                        if !usersInClassList.isEmpty{
                                        self.classesRef.child(addedClasses.id).child("usersJoined").setValue(usersInClassList) { (error, ref) in
                                            if error == nil {
                                                print("Pushedup")
                                            } else {
                                                print("push faied ")
                                            }
                                            
                                        }
                                        }else{
                                            self.classesRef.child(addedClasses.id).child("usersJoined").removeValue()
                                        }
                                    
                                        
                                    }
                                    
                                }
                                var userClssjoinedIdList:[String] = self.userJoinedClassesList
                                print(userClssjoinedIdList)
                                for classId in userClssjoinedIdList {
                                    if classId == addedClasses.id {
                                        userClssjoinedIdList.remove(at: userClssjoinedIdList.firstIndex(of: addedClasses.id)!)
                                        print("id in user list \(userClssjoinedIdList)")
                                        //push value to the user > authid > userClasses > ["",""]
                                        if !userClssjoinedIdList.isEmpty {
                                            self.userClassesRef.setValue(userClssjoinedIdList) { (error, ref) in
                                                if error == nil {
                                                    print("Pushedup")
                                                } else {
                                                    print("push faied ")
                                                }
                                            }
                                        }else {
                                            self.userClassesRef.removeValue()
                                        }
                                        
                                        
                                    }
                                }
                                //print("removed list : \(usersInClassList)")
                                
                                
                                
                                // view refresh
                                self.classFulldetList.removeAll()
                                self.myClassesTableView.beginUpdates()
                                self.myClassesTableView.reloadData()
                                
                                
                            }
                            
                            
                            
                        }
                        
                    }
                    print ("outside 8 less \(String(describing: self.packageId!))")
                    
                }
                
                
                
                
                
            }
            
            shareMenu.addAction(twitterAction)
            shareMenu.addAction(cancelAction)
            
            self.present(shareMenu, animated: true, completion: nil)
        })
        
        
        return [shareAction]
    }
    
    
    
    
}
