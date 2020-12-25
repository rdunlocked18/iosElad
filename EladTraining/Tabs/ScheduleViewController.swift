//
//  ScheduleViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//
import UIKit
import Firebase
import BLTNBoard
import MaterialComponents.MaterialActionSheet
import DateScrollPicker
import DatePicker
import Toast_Swift
class ScheduleViewController: UIViewController  {
    @IBOutlet weak var filterButton: UIButton!
    //start filter
    public var className:String!
    var bulletinManager: BLTNItemManager?
    var authIDUser = Auth.auth().currentUser?.uid
    var sessionsGet:Int!
    //end filters
    //table view
    @IBOutlet weak var scheduleTableMain:UITableView!
    var classList = [ScheduleClasses]()
    var ref:DatabaseReference!
    var userClassesNameList : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schedule"
        let play = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(todaySet))
        navigationItem.rightBarButtonItems = [ play]
        filterButton.addTarget(self, action: #selector(todaySet), for: .touchUpInside)
        scheduleTableMain.delegate = self
        scheduleTableMain.dataSource = self
        //table and Firebase
        ref = Database.database().reference();
        ref.child("Classes").observe(DataEventType.value,with:{
            (snapshot) in
            if snapshot.childrenCount > 0{
                self.classList.removeAll()
                for classesSch in snapshot.children.allObjects as![DataSnapshot]{
                    let classesSchObject = classesSch.value as? [String:AnyObject]
                    //MARK:- Get Firebase Data
                    let id = classesSchObject?["id"]
                    let capacity = classesSchObject?["capacity"]
                    let coach = classesSchObject?["coach"]
                    let date = classesSchObject?["date"]
                    let description = classesSchObject?["description"]
                    let name = classesSchObject?["name"]
                    let timings = classesSchObject?["timings"]
                    let usersJoined = classesSchObject?["usersJoined"]
                    let lister = ScheduleClasses(id:id as! String?,capacity: capacity as? Int, coach: (coach as! String), date: (date as? String), description: (description as! String), name: name as? String, timings: timings as? String,userJoined: usersJoined as! [String]?)
                    self.classList.append(lister)
                }
                self.scheduleTableMain.reloadData()
            }
        })
        self.ref.child("Users").child(self.authIDUser ?? "").child("userClasses").observe(.value) {
            snapshot in
            for child in snapshot.children {
                let ns = child as! DataSnapshot
                let dict = ns.value as! String
                self.userClassesNameList.append(dict)
            }
            print("classname list count \(self.userClassesNameList.count)")
        }
        
        self.ref.child("Users").child(self.authIDUser!).child("userPackages").observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.sessionsGet = value?["sessions"] as? Int
            self.view.makeToast("\(self.sessionsGet!)")
        })
    }

    // Scroll to current date
    @objc
    func todaySet(){
        let minDate = DatePickerHelper.shared.dateFrom(day: 1, month: 12, year: 2020)!
        let maxDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 2030)!
        let today = Date()
        // Create picker object
        let datePicker = DatePicker()
        // Setup
        
        datePicker.setup(beginWith: today, min: minDate, max: maxDate) {
            (selected, date) in
            if selected, let selectedDate = date {
                var ofd:String = "\(selectedDate.day())/\(selectedDate.month())/\(selectedDate.year())"
                print(ofd)
                //self.filterTableWithDate(ofDate: ofd)
            }
            else {
                print("Cancelled")
            }
        }
        // Display
        datePicker.show(in: self )
    }

    func filterTableWithDate(ofDate:String){
        self.classList.removeAll()
        self.classList.filter {
            $0.date == ofDate
        }
        self.scheduleTableMain.beginUpdates()
        self.scheduleTableMain.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.scheduleTableMain.backgroundColor = UIColor(named: "someCyan")
        self.scheduleTableMain.showActivityIndicator()
        //self.scheduleTableMain.backgroundColor = UIColor.white
        self.scheduleTableMain.rowHeight = 230
    }
    override func viewWillAppear(_ animated: Bool) {
        //MARK:- check date with classes and return tableview only if class is present on that day
        
    }

}
extension ScheduleViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = scheduleTableMain.dequeueReusableCell(withIdentifier: "schCell" , for: indexPath) as! ScheduleTableViewCell
        let classes : ScheduleClasses
        classes = classList[indexPath.row]
        let actionSheet = MDCActionSheetController(title: "Join \(classes.name) ?",
                                                   message: "1 Session from your package will be consumed")
        let desc = MDCActionSheetAction(title:classes.description,
                                        image: .none)
        let actionOne = MDCActionSheetAction(title: "Join Class",
                                             image: .checkmark,
                                             handler: {
                                                 (_) in
                                                 //MARK:- start join classs handler
                                                 var keyForNext:Int!
                                                 if(classes.usersJoined.isEmpty){
                                                     keyForNext = 0
                                                 }
                                                 else {
                                                     keyForNext = (classes.usersJoined.count)
                                                 }
                                                 print(keyForNext!)
                                                 self.ref.child("Classes").child(classes.id).child("usersJoined").child("\(keyForNext!)" ).setValue(self.authIDUser) {
                                                     (error, ref) in
                                                     if(error == nil){
                                                         print("success")
                                                         //MARK:- sent 1
                                                         //MARK:- Reload Views
                                                         self.scheduleTableMain.beginUpdates()
                                                         self.scheduleTableMain.reloadData()
                                                         //MARK:- Reading data 2
                                                         var keytoUserClass:Int!
                                                         var listIdList:[String]?
                                                         self.ref.child("Users").child(self.authIDUser ?? "").child("userClasses").observe(.value) {
                                                             snapshot in
                                                             for child in snapshot.children {
                                                                 let ns = child as! DataSnapshot
                                                                let dict = ns.key
                                                                 listIdList?.append(dict)
                                                             }
                                                         }
                                                         if(listIdList == nil){
                                                             keytoUserClass  = 0
                                                         }
                                                         else {
                                                             keytoUserClass = listIdList?.count
                                                         }
                                                         //MARK:- Sending data 2 Actual
                                                         self.ref.child("Users").child(self.authIDUser ?? "").child("userClasses").child("\(keytoUserClass!)")
                                                         .setValue(classes.id){
                                                             (error,ref) in
                                                             if error == nil{
                                                                 //MARK:- Reading data 3
                                                                 
                                                                self.ref.child("Users").child(self.authIDUser!).child("userPackages").child("sessions").setValue(self.sessionsGet-1) {
                                                                     (error, ref) in
                                                                     if(error == nil){
                                                                         print("3rd Complete")
                                                                     }
                                                                     else{
                                                                         print("3rd Failed")
                                                                     }
                                                                 }
                                                             }
                                                             else{
                                                                 print("Error cannot send data 2")
                                                             }
                                                         }
                                                     }
                                                     else{
                                                         //MARK:- d1 Error
                                                         print("Error cannot send even d1")
                                                     }
                                                 }
                                             })
        let actionTwo = MDCActionSheetAction(title: "Cancel",
                                             image: .remove,handler: {
                                                 (_) in
                                                 print(classes.coach)
                                             })
        let actionOpt = MDCActionSheetAction(title: "You have already Joined the Class",
                                             image: .strokedCheckmark ,handler: {
                                                 (_) in
                                                 //print(classes.coach)
                                             })
        actionSheet.titleFont = UIFont.appBoldFontWith(size: 17)
        actionSheet.titleTextColor = UIColor.white
        actionSheet.actionTextColor = UIColor.white
        actionSheet.actionTintColor = UIColor(named: "someCyan")
        actionSheet.messageTextColor = UIColor(named: "someCyan")
        actionSheet.messageFont = UIFont.appMediumFontWith(size: 15)
        actionSheet.backgroundColor = UIColor(named: "darkBlue") ?? .white
        //add join or othe button logic
        if(classes.usersJoined.contains(authIDUser!)){
            actionSheet.title = "\(classes.name) is Added To Your Classes"
            actionSheet.message = "To Cancel the Class Go to My Classes and Swipe Perticular Class You want to Cancel !"
            actionSheet.addAction(actionOpt)
        }
        else{
            actionSheet.addAction(actionOne)
            actionSheet.addAction(actionTwo)
        }
        present(actionSheet, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = scheduleTableMain.dequeueReusableCell(withIdentifier: "schCell" , for: indexPath) as! ScheduleTableViewCell
        let classes : ScheduleClasses
        classes = classList[indexPath.row]
        scheduleTableMain.hideActivityIndicator()
        //MARK:- Setup Fonts
        cell.classNameGet.textColor = .white
        cell.classNameGet.font = UIFont.appBoldFontWith(size: 22)
        cell.classTimeGet.font = UIFont.appRegularFontWith(size: 17)
        cell.coachNameGet.font = UIFont.appRegularFontWith(size: 17)
        cell.totalMembersGet.font = UIFont.appRegularFontWith(size: 17)
        cell.classCapacityGet.font = UIFont.appRegularFontWith(size: 17)
        //MARK:- Setup TV TEXTS
        cell.classNameGet.text = classes.name
        cell.classTimeGet.text = classes.timings
        cell.classCapacityGet.text = "\(classes.capacity - classes.usersJoined.count) spots remaining"
        cell.totalMembersGet.text = "\(classes.usersJoined.count) Joined"
        cell.coachNameGet.text = classes.coach
        return cell
    }

}
