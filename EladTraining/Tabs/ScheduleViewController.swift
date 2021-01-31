//
//  ScheduleViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//
import DatePicker
import Firebase
import MaterialComponents.MaterialActionSheet
import Toast_Swift
import UIKit
class ScheduleViewController: UIViewController {
    @IBOutlet var filterButton: UIButton!
    // start filter
    @IBOutlet var filterDatePicker: UIDatePicker!
    public var className: String!
    var authIDUser = Auth.auth().currentUser?.uid
    var sessionsGet: Int!
    // end filters
    // table view
    var date = Date()
    @IBOutlet var noDataTitle: UILabel?
    @IBOutlet var noDataMessage: UILabel?
    @IBOutlet var scheduleTableMain: UITableView!
    @IBOutlet var noDataImage: UIImageView!
    
    var ref: DatabaseReference!
    var classesRef: DatabaseReference!
    @IBOutlet var noDataView: UIView!
    
    var userClassesNameList: [String] = []
    
    var fullTodayDate: String?
    
    // filter
    var classList = [ScheduleClasses]()
    var filteredClasses = [ScheduleClasses]()
    var isFiltering = false
    
    let refreshControl = UIRefreshControl()
    
    @objc
    func refresh(sender: AnyObject) {
        // Updating your data here...

        scheduleTableMain.reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd/MM/yyyy"
        let forDate = dateFormatterGet.string(from: filterDatePicker.date)
        
        view.makeToast("\(forDate)")
        
        // readClassDateData(dateData: forDate)
        print(classList.filter { $0.date == forDate })
        isFiltering = true
        filteredClasses = classList.filter { $0.date == forDate }
        print(filteredClasses)
        scheduleTableMain.reloadData()
        if filteredClasses.isEmpty {
            scheduleTableMain.hideActivityIndicator()
            // self.scheduleTableMain.removeFromSuperview()
            noDataView.isHidden = false
        }
        else {
            scheduleTableMain.showActivityIndicator()
            // self.scheduleTableMain.removeFromSuperview()
            noDataView.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schedule"
        
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        classesRef = Database.database().reference().child("Classes")
        
        // font for no data
        noDataTitle?.font = UIFont.appBoldFontWith(size: 17)
        noDataMessage?.font = UIFont.appLightFontWith(size: 15)
        
        let daye = date.day()
        let monthe = date.month()
        let yeare = date.year()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd/mm/yy"
        
        fullTodayDate = dateFormatterGet.string(from: filterDatePicker.date)
        print("\(daye)/\(monthe)/\(yeare)")
        
        readClassesDetails()
        
        scheduleTableMain.delegate = self
        scheduleTableMain.dataSource = self
        scheduleTableMain.refreshControl = refreshControl
        
        // table and Firebase
        ref = Database.database().reference()
        
        ref.child("Users").child(authIDUser ?? "").child("userClasses").observe(.value) {
            snapshot in
            for child in snapshot.children {
                let ns = child as! DataSnapshot
                let dict = ns.value as! String
                self.userClassesNameList.append(dict)
            }
            print("classname list count \(self.userClassesNameList.count)")
        }
        
        ref.child("Users").child(authIDUser!).child("userPackages").observeSingleEvent(of: .value, with: {
            snapshot in
            let value = snapshot.value as? NSDictionary
            self.sessionsGet = value?["sessions"] as? Int
            let active = value?["active"] as? Bool ?? true
            let punishment = value?["punishment"] as? Bool ?? false
            
            if !active {
                self.scheduleTableMain.isHidden = true
                self.filterDatePicker.isHidden = true
                self.noDataView.isHidden = false
                self.noDataImage.image = UIImage(named: "money")
                self.noDataTitle?.text = "Your Package is Not Active !"
                self.noDataMessage?.text = "Please ask Admins to Make Package Active or Recharge Package"
            }
            else if punishment {
                self.scheduleTableMain.isHidden = true
                self.filterDatePicker.isHidden = true
                self.noDataView.isHidden = false
                self.noDataImage.image = UIImage(named: "cross")
                self.noDataTitle?.text = "You are on Punishment !"
                self.noDataMessage?.text = "You will not be able to Access Classes \n untill Trainer Retains Punishment ( 48 Hours )"
                self.noDataTitle?.font = UIFont.appBoldFontWith(size: 19)
                self.noDataMessage?.font = UIFont.appRegularFontWith(size: 14)
                self.noDataMessage?.textColor = .red
                self.noDataTitle?.textColor = .red
            }
            // self.view.makeToast("\(self.sessionsGet)")
        })
    }
    
    func readClassesDetails() {
        classesRef.observe(DataEventType.value, with: {
            snapshot in
            if snapshot.childrenCount > 0 {
                for classesSch in snapshot.children.allObjects as! [DataSnapshot] {
                    let classesSchObject = classesSch.value as? [String: AnyObject]

                    // MARK: - Get Firebase Data

                    let id = classesSchObject?["id"]
                    let capacity = classesSchObject?["capacity"]
                    let coach = classesSchObject?["coach"]
                    let date = classesSchObject?["date"]
                    let description = classesSchObject?["description"]
                    let name = classesSchObject?["name"]
                    let timings = classesSchObject?["timings"]
                    let timeStamp = classesSchObject?["timestamp"]
                    let usersJoined = classesSchObject?["usersJoined"]
                    
                    let lister = ScheduleClasses(id: id as! String?, capacity: capacity as? Int, coach: coach as! String, date: date as? String, description: description as! String, name: name as? String, timings: timings as? String, timestamp: timeStamp as? Int, userJoined: usersJoined as! [String]?)
                    
//                    if lister.date == dateData {
//                        self.classList.removeAll()
                    self.classList.append(lister)
//                        self.noDataView.isHidden = true
//                        self.scheduleTableMain.hideActivityIndicator()
//                        self.scheduleTableMain.isHidden = false
//                        self.scheduleTableMain.beginUpdates()
//                        self.scheduleTableMain.reloadData()
                        
//                    }
//                    else {
//                        self.scheduleTableMain.hideActivityIndicator()
//                        //self.scheduleTableMain.removeFromSuperview()
//                        self.noDataView.isHidden = false
//
//                    }
                }
                print(self.classList)
                self.isFiltering = true
                self.todayFilterAction()
                self.scheduleTableMain.reloadData()
            }
        })
    }
    
    func todayFilterAction() {
        let daye = date.day()
        let monthe = date.month()
        let yeare = date.year()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "DD/MM/YYYY"
        isFiltering = true
        filteredClasses = classList.filter { $0.date == fullTodayDate }
        print(filteredClasses)
        scheduleTableMain.reloadData()
        if filteredClasses.isEmpty {
            scheduleTableMain.hideActivityIndicator()
            // self.scheduleTableMain.removeFromSuperview()
            noDataView.isHidden = false
        }
        else {
            scheduleTableMain.showActivityIndicator()
            // self.scheduleTableMain.removeFromSuperview()
            noDataView.isHidden = true
        }
    }
    
    // Scroll to current date
    @objc
    func todaySet() {
        let minDate = DatePickerHelper.shared.dateFrom(day: 1, month: 12, year: 2020)!
        let maxDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 2030)!
        let today = Date()
        // Create picker object
        let datePicker = DatePicker()
        // Setup
        
        datePicker.setup(beginWith: today, min: minDate, max: maxDate) {
            selected, date in
            if selected, let selectedDate = date {
                let ofd: String = "\(selectedDate.day())/\(selectedDate.month())/\(selectedDate.year())"
                print(ofd)
                // self.filterTableWithDate(ofDate: ofd)
            }
            else {
                print("Cancelled")
            }
        }
        // Display
        datePicker.show(in: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scheduleTableMain.backgroundColor = .white
        scheduleTableMain.showActivityIndicator()
        // self.scheduleTableMain.backgroundColor = UIColor.white
        scheduleTableMain.rowHeight = 290
    }
   
    @objc
    func jooinBtn(_ sender: AnyObject) {
        let position: CGPoint = sender.convert(.zero, to: scheduleTableMain)
        let indexPath = scheduleTableMain.indexPathForRow(at: position)
        
        // let cell: ScheduleTableViewCell = scheduleTableMain.cellForRow(at: indexPath!)! as!
        // ScheduleTableViewCell
        
        let classes: ScheduleClasses
        
        if isFiltering {
            classes = filteredClasses[indexPath?.row ?? 0]
        }
        else {
            classes = classList[indexPath?.row ?? 0]
        }
        
        let actionSheet = MDCActionSheetController(title: "Join \(classes.name) ?",
                                                   message: "1 Session from your package will be consumed")
        let desc = MDCActionSheetAction(title: classes.description,
                                        image: .none)
        let actionOne = MDCActionSheetAction(title: "Join Class",
                                             image: .checkmark,
                                             handler: {
                                                 _ in

                                                 // MARK: - start join classs handler
                                                
                                                 var keyForNext: Int!
                                                 if classes.usersJoined.isEmpty {
                                                     keyForNext = 0
                                                 }
                                                 else {
                                                     keyForNext = classes.usersJoined.count
                                                 }
                                                 print(keyForNext!)
                                                 self.ref.child("Classes").child(classes.id).child("usersJoined").child("\(keyForNext!)").setValue(self.authIDUser) {
                                                     error, _ in
                                                     if error == nil {
                                                         print("success")

                                                         // MARK: - sent 1

                                                         // MARK: - Reload Views

                                                         self.scheduleTableMain.beginUpdates()
                                                         self.scheduleTableMain.reloadData()

                                                         // MARK: - Reading data 2

                                                         var keytoUserClass: Int!
                                                         var listIdList: [String]?
                                                         self.ref.child("Users").child(self.authIDUser ?? "").child("userClasses").observe(.value) {
                                                             snapshot in
                                                             for child in snapshot.children {
                                                                 let ns = child as! DataSnapshot
                                                                 let dict = ns.key
                                                                 listIdList?.append(dict)
                                                             }
                                                         }
                                                         if listIdList == nil {
                                                             keytoUserClass = 0
                                                         }
                                                         else {
                                                             keytoUserClass = listIdList?.count
                                                         }

                                                         // MARK: - Sending data 2 Actual

                                                         self.ref.child("Users").child(self.authIDUser ?? "").child("userClasses").child("\(keytoUserClass!)")
                                                             .setValue(classes.id) {
                                                                 error, _ in
                                                                 if error == nil {
                                                                     // MARK: - Reading data 3
                                                                    
                                                                     self.ref.child("Users").child(self.authIDUser!).child("userPackages").child("sessions").setValue(self.sessionsGet - 1) {
                                                                         error, _ in
                                                                         if error == nil {
                                                                             print("3rd Complete")
                                                                             self.scheduleTableMain.reloadData()
                                                                         }
                                                                         else {
                                                                             print("3rd Failed")
                                                                         }
                                                                     }
                                                                 }
                                                                 else {
                                                                     print("Error cannot send data 2")
                                                                 }
                                                             }
                                                     }
                                                     else {
                                                         // MARK: - d1 Error

                                                         print("Error cannot send even d1")
                                                     }
                                                 }
                                             })
        let actionTwo = MDCActionSheetAction(title: "Cancel",
                                             image: .remove, handler: {
                                                 _ in
                                                 print(classes.coach)
                                             })
        let actionOpt = MDCActionSheetAction(title: "You have already Joined the Class",
                                             image: .strokedCheckmark, handler: {
                                                 _ in
                                                 // print(classes.coach)
                                             })

        actionSheet.titleTextColor = .white
        actionSheet.titleFont = UIFont.appBoldFontWith(size: 17)
        actionSheet.actionTintColor = UIColor(named: "someCyan")
        actionSheet.actionTextColor = UIColor.white
        actionSheet.messageTextColor = UIColor(named: "someCyan")
        actionSheet.messageFont = UIFont.appMediumFontWith(size: 15)
        actionSheet.backgroundColor = UIColor.black
        // add join or othe button logic
        
        let timestamp = Int(NSDate().timeIntervalSince1970)
        // let timeStamp = Date.currentTimeMillis()
        print("current \(timestamp)")
        if classes.timestamp < timestamp {
            actionSheet.title = "\(classes.name) is Over"
            actionSheet.message = "Cannot Join classes Older than Current Date/Time"
            // actionSheet.addAction(actionOpt)
        }
         
        else if classes.usersJoined.contains(authIDUser!) {
            actionSheet.title = "\(classes.name) is Added To Your Classes"
            actionSheet.message = "To Cancel the Class Go to My Classes and Swipe Perticular Class You want to Cancel !"
            actionSheet.addAction(actionOpt)
        }
        else {
            actionSheet.addAction(actionOne)
            actionSheet.addAction(actionTwo)
        }
        present(actionSheet, animated: true, completion: nil)
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            print(filteredClasses)
            return filteredClasses.count
        }
        else {
            return classList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = scheduleTableMain.dequeueReusableCell(withIdentifier: "schCell", for: indexPath) as! ScheduleTableViewCell
        let classes: ScheduleClasses
        if isFiltering {
            classes = filteredClasses[indexPath.row]
        }
        else {
            classes = classList[indexPath.row]
        }
        // self.classList.filter{ $0.date == fullTodayDate }
        scheduleTableMain.hideActivityIndicator()

        // MARK: - Setup Fonts

        cell.classNameGet.textColor = .white
        cell.classNameGet.font = UIFont.appBoldFontWith(size: 22)
        cell.classTimeGet.font = UIFont.appRegularFontWith(size: 17)
        cell.coachNameGet.font = UIFont.appRegularFontWith(size: 17)
        cell.totalMembersGet.font = UIFont.appRegularFontWith(size: 17)
        cell.classCapacityGet.font = UIFont.appRegularFontWith(size: 17)

        // MARK: - Setup TV TEXTS

        cell.classNameGet.text = classes.name
        cell.classTimeGet.text = classes.timings
        cell.classCapacityGet.text = "\(classes.capacity - classes.usersJoined.count) spots remaining"
        cell.totalMembersGet.text = "\(classes.usersJoined.count) Joined"
        cell.coachNameGet.text = classes.coach
        cell.joinClassBtn.addTarget(self, action: #selector(ScheduleViewController.jooinBtn(_:)), for: .touchUpInside)
        
        return cell
    }
}
