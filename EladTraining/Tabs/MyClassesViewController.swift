//
//  MyClassesViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//

import BLTNBoard
import Firebase
import FirebaseDatabase
import Nuke
import UIKit
import EmptyDataSet_Swift
class MyClassesViewController: UIViewController {
    var bulletinManager: BLTNItemManager?
    
    @IBOutlet var myclassView: UIView!
    
    @IBOutlet var myClassesTableView: UITableView!
    var userJoinedClassesList: [String] = []
    var classFulldetList = [ScheduleClasses]()
    var packageDetailsList = [UserPackageModel]()
    
    var ref: DatabaseReference!
    
    // All vars of the data
    var authUid: String! = Auth.auth().currentUser?.uid
    var userClassesRef: DatabaseReference!
    var classesRef: DatabaseReference!
    var userPkgRef: DatabaseReference!
    var userRef: DatabaseReference!
    
    // packageDetails
    
    var packageId: String?
    var endDate: String?
    var startDate: String?
    var isActive: Bool?
    var sessions: Int?
    var punishmentTimeStamp: Int?
    var punishment: Bool?
    let refreshControl = UIRefreshControl()
    
    @objc
    func checkAction(sender: UITapGestureRecognizer) {
        let boardManagere: BLTNItemManager = {
            let item = BLTNPageItem(title: "My Classes")
            item.requiresCloseButton = false
            item.descriptionText = "This screen shows the list of upcoming classes that you have joined. The class items are sorted in an increasing manner with respect to their timings You can leave any class if you want,by swiping class card towards left "
            // item.image = UIImage(named: "circleLogo")
//                    item.actionButtonTitle = "Okay,I understood"
            item.appearance.descriptionFontSize = 14
            item.alternativeButtonTitle = "Drag Down To Dismiss"
                    
            item.isDismissable = true
            item.appearance.alternativeButtonTitleColor = .black
                    
//                    item.actionHandler = {(item: BLTNActionItem) in
//                            print("Action button tapped")
//                       // BLTNItemManager.dismissBulletin(BLTNItemManager)
//                    }
            item.alternativeHandler = { (_: BLTNActionItem) in
                print("Action button tapped")
            }
        
            return BLTNItemManager(rootItem: item)
        
        }()
        
        boardManagere.backgroundViewStyle = .blurredDark
        
        boardManagere.showBulletin(above: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // MARK: - check date with classes and return tableview only if class is present on that day
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Classes"
        
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        // inits of database vars
        
        // self.navigationController?.navigationBar.backgroundColor = .black
        userClassesRef = Database.database().reference().child("Users").child(authUid).child("userClasses")
        
        classesRef = Database.database().reference().child("Classes")
        
        userPkgRef = Database.database().reference().child("Users").child(authUid).child("userPackages")
        
        userRef = Database.database().reference().child("Users").child(authUid)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(checkAction))
        myclassView.addGestureRecognizer(gesture)
        
        myClassesTableView.dataSource = self
        myClassesTableView.delegate = self
        myClassesTableView.refreshControl = refreshControl
        myClassesTableView.emptyDataSetDelegate = self
        myClassesTableView.emptyDataSetSource = self
        
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
     
//    func hitNotification(classId: String, className: String, timeStamp: Int) {
//        let center = UNUserNotificationCenter.current()
//        let content = UNMutableNotificationContent()
//        content.title = "Hey ! Reminder for your class "
//        content.body = " your class \("testing") is after 30 mins"
//        content.sound = UNNotificationSound.default
//        content.categoryIdentifier = "yourIdentifier"
//        content.userInfo = ["example": "information"] // You can retrieve this when displaying notification
//
//        // Setup trigger time
//        var calendar = Calendar.current
//        calendar.timeZone = TimeZone.current
//        let testDate = Date() + 5 // Set this to whatever date you need
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeStamp - 1800), repeats: false)
//        // Create request
//        let uniqueID = UUID().uuidString // Keep a record of this if necessary
//        let request = UNNotificationRequest(identifier: classId, content: content, trigger: trigger)
//        center.add(request) // Add the notification request
//        print("time \(TimeInterval(timeStamp - 1800))")
//    }
    
    @objc
    func refresh(sender: AnyObject) {
        // Updating your data here...

        myClassesTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func getClassesFromIds() {
        classesRef.observe(.value) { _ in
            for ds in self.userJoinedClassesList {
                if self.userJoinedClassesList.isEmpty {
                    print("not joined")
                } else {
                    print("value of \(ds)")
                    self.readClassesData(classId: [ds])
                }
            }
        }
    }
    
    func readUserpkgData() {
        // MARK: - Get Firebase Data

        userPkgRef.observeSingleEvent(of: .value, with: {
            snapshot in
            
            let value = snapshot.value as? NSDictionary
            
            self.packageId = value?["packageId"] as? String ?? ""
            self.endDate = value?["endDate"] as? String ?? ""
            self.startDate = value?["startDate"] as? String ?? ""
            self.isActive = value?["active"] as? Bool ?? true
            self.sessions = value?["sessions"] as? Int ?? 0
            self.punishment = value?["punishment"] as? Bool ?? false
            self.punishmentTimeStamp = value?["punishmentTimeStamp"] as? Int ?? 0
            // let  = userPackageDetailsObject?["sessions"]
            print(" inside 8 less \(String(describing: self.packageId))")
         
        })
    }
    
    func readClassesData(classId: [String]) {
        // MARK: - Get Firebase Data

        print("Got class id \(classId)")
        ref.child("Classes").observe(DataEventType.value, with: {
            snapshot in
            if snapshot.childrenCount > 0 {
                self.classFulldetList.removeAll()
                for classesSch in snapshot.children.allObjects as! [DataSnapshot] {
                    let classesSchObject = classesSch.value as? [String: AnyObject]
                    
                    let id = classesSchObject?["id"]
                    let capacity = classesSchObject?["capacity"]
                    let coach = classesSchObject?["coach"]
                    let date = classesSchObject?["date"]
                    let description = classesSchObject?["description"]
                    let name = classesSchObject?["name"]
                    let startTime = classesSchObject?["startTime"]
                    let endTime = classesSchObject?["endTime"]
                    var timings = "\(String(describing: startTime)) - \(String(describing: endTime))"
                    let timeStamp = classesSchObject?["timestamp"]
                    let usersJoined = classesSchObject?["usersJoined"]
                    
                    let lister = ScheduleClasses(id: id as? String, capacity: capacity as? Int, coach: coach as? String, date: date as? String, description: description as? String, name: name as? String,startTime: startTime as? String,endTime: endTime as? String, timestamp: timeStamp as? Int, userJoined: usersJoined as! [String]?)
                    
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
        myClassesTableView.rowHeight = 170
        myClassesTableView.reloadData()
    }
    
}

extension MyClassesViewController: UITableViewDelegate, UITableViewDataSource , EmptyDataSetDelegate , EmptyDataSetSource{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classFulldetList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myClassesTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyClassesCellTableViewCell
        
        myClassesTableView.hideActivityIndicator()
        let addedClasses: ScheduleClasses
        addedClasses = classFulldetList[indexPath.row]
        cell.classNameLbl?.text = addedClasses.name
        cell.classDateLbl?.text = addedClasses.date
        cell.classTimeLbl?.text = "\(addedClasses.startTime) - \(addedClasses.endTime)"
        
        // setup ui
        cell.classNameLbl.font = UIFont.appBoldFontWith(size: 22)
        cell.classDateLbl.font = UIFont.appRegularFontWith(size: 17)
        cell.classTimeLbl.font = UIFont.appRegularFontWith(size: 17)
       // hitNotification(classId: addedClasses.id, className: addedClasses.name, timeStamp: addedClasses.timestamp)
        
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cell = myClassesTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyClassesCellTableViewCell
        
        myClassesTableView.hideActivityIndicator()
        let addedClasses: ScheduleClasses
        addedClasses = classFulldetList[indexPath.row]
        
        // 1
        let shareAction = UITableViewRowAction(style: .default, title: "Leave Class", handler: { (_: UITableViewRowAction, _: IndexPath) -> Void in
            // 2
            let shareMenu = UIAlertController(title: "Confirm Leave \(addedClasses.name) ?", message: "Are You Sure want to Leave the class ? This might lead to punishment if you leave the class just within 8 hours duration", preferredStyle: .alert)
            
            let twitterAction = UIAlertAction(title: "Sure", style: .default, handler: { _ in handleTrue() })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            func handleTrue() {
                print("hello")
                // punishment
                // if current time is equal to or less than class timings minus 8 hours then apply punishment}
                // else refund the sessions i.e add plus session back to user
                // and remove all the details from userClasses, classes -> userJoined
                // @todo add variable : isActive and onPunishment
                let gotTimeStamp = addedClasses.timestamp
                print("got time \(gotTimeStamp)")
                
                let timestamp = Int(NSDate().timeIntervalSince1970)
                // let timeStamp = Date.currentTimeMillis()
                print("current \(timestamp)")
                
                // To get the hours
                
                let difference = Int(gotTimeStamp - timestamp)
                let inHours = difference / 3600
                print("date is \(inHours)")
                
                // MARK: - Logic for main punishment and set value of array
                
                print(addedClasses.usersJoined)
                
//                if (inHours <= 8){
//                    //apply punishment
//
//                    if self.isActive!  {
//                        if self.punishment! {
//                            self.view.makeToast("Already on Punishment")
//                        }else{
//
//                            let currentPunishmentTimeStamp = Int(NSDate().timeIntervalSince1970)
//                            self.userPkgRef.child("punishment").setValue(true)
//                            self.userPkgRef.child("punishmentTimeStamp") .setValue(currentPunishmentTimeStamp)
//                            self.view.makeToast("Punishment Applied Classes Disabled")
//
//                        }
//                    } else {
//                        self.view.makeToast("package is not active ask admins")
//                    }
//
//                    print ("inside 8 less \(String(describing: self.packageId!))")
//
//                }else {
                // remove without punishment
                self.userPkgRef.child("punishment").setValue(false) { error, _ in
                    self.userPkgRef.child("punishmentTimeStamp").setValue(0)
                    // @add refund session here and remove the classId from userClasses & remove the uid from class-> usersJoined
                    // remove Id from userClasses and remove uid from usersJoined from Class Id
                    self.userPkgRef.child("sessions").setValue(self.sessions! + 1)
                                
                    var usersInClassList: [String] = addedClasses.usersJoined
                    for users in usersInClassList {
                        if users == self.authUid {
                            print("user is present")
                            usersInClassList.remove(at: usersInClassList.firstIndex(of: self.authUid)!)
                            print("removed list : \(usersInClassList)")
                            // push the new lst now
                            // setval(newlist)/
                            // push value to the classes > ClassesId > usersJoined > ["",""]
                            if !usersInClassList.isEmpty {
                                self.classesRef.child(addedClasses.id).child("usersJoined").setValue(usersInClassList) { error, _ in
                                    if error == nil {
                                        print("Pushedup")
                                        self.classFulldetList.removeAll()
                                        self.myClassesTableView.beginUpdates()
                                        self.myClassesTableView.reloadData()
                                    } else {
                                        print("push faied ")
                                    }
                                }
                            } else {
                                self.classesRef.child(addedClasses.id).child("usersJoined").removeValue()
                                self.classFulldetList.removeAll()
                                self.myClassesTableView.beginUpdates()
                                self.myClassesTableView.reloadData()
                            }
                        }
                    }
                    var userClssjoinedIdList: [String] = self.userJoinedClassesList
                    print(userClssjoinedIdList)
                    for classId in userClssjoinedIdList {
                        if classId == addedClasses.id {
                            userClssjoinedIdList.remove(at: userClssjoinedIdList.firstIndex(of: addedClasses.id)!)
                            print("id in user list \(userClssjoinedIdList)")
                            // push value to the user > authid > userClasses > ["",""]
                            if !userClssjoinedIdList.isEmpty {
                                self.userClassesRef.setValue(userClssjoinedIdList) { error, _ in
                                    if error == nil {
                                        print("Pushedup")
                                        self.classFulldetList.removeAll()
                                        self.myClassesTableView.beginUpdates()
                                        self.myClassesTableView.reloadData()
                                    } else {
                                        print("push faied ")
                                    }
                                }
                            } else {
                                self.userClassesRef.removeValue()
                                self.classFulldetList.removeAll()
                                self.myClassesTableView.beginUpdates()
                                self.myClassesTableView.reloadData()
                            }
                        }
                    }
                }
            }
            
            shareMenu.addAction(twitterAction)
            shareMenu.addAction(cancelAction)
            
            self.present(shareMenu, animated: true, completion: nil)
        })
        
        return [shareAction]
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let quote = "No Classes Joined."
        let font = UIFont.appBoldFontWith(size: 20 )
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.firstLineHeadIndent = 5.0
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
            .paragraphStyle : paragraphStyle
        ]
        let attributedQuote = NSAttributedString(string: quote, attributes: attributes)
        return attributedQuote
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let quote = "Join a class to view it here"
        let font = UIFont.appRegularFontWith(size: 15 )
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.firstLineHeadIndent = 5.0
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
            .paragraphStyle : paragraphStyle
        ]
        let attributedQuote = NSAttributedString(string: quote, attributes: attributes)
        return attributedQuote
    }
      
       
       //MARK: - DZNEmptyDataSetDelegate Methods
       func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
           return true
       }
       
}
