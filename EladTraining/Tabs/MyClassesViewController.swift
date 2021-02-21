//
//  MyClassesViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//

import BLTNBoard
import EmptyDataSet_Swift
import Firebase
import FirebaseDatabase
import Nuke
import UIKit
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
        readDataAndPopulate()
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Classes"
        setupViewsanRef()
    }

    func setupViewsanRef() {
        // refresh Controller
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(checkAction))
        myclassView.addGestureRecognizer(gesture)
        
        // database refrences
        userClassesRef = Database.database().reference().child("Users").child(authUid).child("userClasses")
        classesRef = Database.database().reference().child("Classes")
        userPkgRef = Database.database().reference().child("Users").child(authUid).child("userPackages")
        userRef = Database.database().reference().child("Users").child(authUid)
        ref = Database.database().reference()
        
        // tableview setup
        myClassesTableView.dataSource = self
        myClassesTableView.delegate = self
        myClassesTableView.rowHeight = 170
        //myClassesTableView.
        myClassesTableView.refreshControl = refreshControl
        myClassesTableView.emptyDataSetDelegate = self
        myClassesTableView.emptyDataSetSource = self
    }
    
    func readDataAndPopulate() {
        ref.child("Users").child(authUid).child("userClasses").observeSingleEvent(of: .value) { snapshot in
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
        myClassesTableView.beginUpdates()
        userJoinedClassesList.removeAll()
        readDataAndPopulate()
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
//            self.punishment = value?["punishment"] as? Bool ?? false
//            self.punishmentTimeStamp = value?["punishmentTimeStamp"] as? Int ?? 0
            // let  = userPackageDetailsObject?["sessions"]
//            print(" inside 8 less \(String(describing: self.packageId))")
         
        })
    }
    
    func readClassesData(classId: [String]) {
        // MARK: - Get Firebase Data
        print("Got class id \(classId)")
        ref.child("Classes").observeSingleEvent(of: .value, with: {
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
                    _ = "\(String(describing: startTime)) - \(String(describing: endTime))"
                    let timeStamp = classesSchObject?["timestamp"]
                    let usersJoined = classesSchObject?["usersJoined"]
                    
                    let lister = ScheduleClasses(id: id as? String, capacity: capacity as? Int, coach: coach as? String, date: date as? String, description: description as? String, name: name as? String, startTime: startTime as? String, endTime: endTime as? String, timestamp: timeStamp as? Int, userJoined: usersJoined as! [String]?)
                    
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
        myClassesTableView.reloadData()
    }
}

extension MyClassesViewController: UITableViewDelegate, UITableViewDataSource, EmptyDataSetDelegate, EmptyDataSetSource {
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
        
        // Cell Fonts
        cell.classNameLbl.font = UIFont.appBoldFontWith(size: 22)
        cell.classDateLbl.font = UIFont.appRegularFontWith(size: 17)
        cell.classTimeLbl.font = UIFont.appRegularFontWith(size: 17)
        
        // Setup Data
        cell.classNameLbl?.text = addedClasses.name
        cell.classDateLbl?.text = addedClasses.date
        cell.classTimeLbl?.text = "\(addedClasses.startTime) - \(addedClasses.endTime)"
        // hitNotification(classId: addedClasses.id, className: addedClasses.name, timeStamp: addedClasses.timestamp) hit notification if needed

        return cell
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let quote = "No Classes Joined."
        let font = UIFont.appBoldFontWith(size: 20)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.firstLineHeadIndent = 5.0
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        let attributedQuote = NSAttributedString(string: quote, attributes: attributes)
        return attributedQuote
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let quote = "Join a class to view it here"
        let font = UIFont.appRegularFontWith(size: 15)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.firstLineHeadIndent = 5.0
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        let attributedQuote = NSAttributedString(string: quote, attributes: attributes)
        return attributedQuote
    }
      
    // MARK: - DZNEmptyDataSetDelegate Methods

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Leave Class"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let addedClasses: ScheduleClasses
        addedClasses = classFulldetList[indexPath.row]
        if editingStyle == .delete {
            myClassesTableView.beginUpdates()
            self.userPkgRef.child("punishment").setValue(false)
            self.userPkgRef.child("punishmentTimeStamp").setValue(0)
            self.userPkgRef.child("sessions").setValue(self.sessions! + 1)
            myClassesTableView.deleteRows(at: [indexPath], with: .left)
            myClassesTableView.reloadData()
        }
        
    }
}
//var usersInClassList: [String] = addedClasses.usersJoined
//                   for users in usersInClassList {
//                       if users == self.authUid {
//                           usersInClassList.remove(at: usersInClassList.firstIndex(of: self.authUid)!)
//                           if !usersInClassList.isEmpty {
//                               self.classesRef.child(addedClasses.id).child("usersJoined").setValue(usersInClassList)
//                           } else {
//                               self.classesRef.child(addedClasses.id).child("usersJoined").removeValue()
//                           }
//                       }
//                   }
//var userClssjoinedIdList: [String] = self.userJoinedClassesList
//for classId in userClssjoinedIdList {
//                        if classId == addedClasses.id {
//                            userClssjoinedIdList.remove(at: userClssjoinedIdList.firstIndex(of: addedClasses.id)!)
//                            print("id in user list \(userClssjoinedIdList)")
//                            if !userClssjoinedIdList.isEmpty {
//                                self.userClassesRef.setValue(userClssjoinedIdList) { error, _ in
//                                    if error == nil {
//                                        print("Pushedup")
//                                        self.classFulldetList.removeAll()
//                                        self.refresh(sender: self)
//
//                                    }
//                                }
//                            } else {
//                                print("in else path \(indexPath)")
//                                self.userClassesRef.removeValue()
//                                self.classFulldetList.removeAll()
//                                self.refresh(sender: self)
//
//                            }
//                        }
//                    }
