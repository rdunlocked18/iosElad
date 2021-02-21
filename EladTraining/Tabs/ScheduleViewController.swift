//
//  ScheduleViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//
import DatePicker
import EmptyDataSet_Swift
import Firebase
import FSCalendar
import MaterialComponents.MaterialActionSheet
import Toast_Swift
import UIKit
class ScheduleViewController: UIViewController {
    // Database Refrences
    var ref: DatabaseReference!
    var classesRef: DatabaseReference!
    
    // Firebase Auth Vars
    var authIDUser = Auth.auth().currentUser?.uid
    
    // Table Views
    @IBOutlet var scheduleTableMain: UITableView!
    
    // Other Variables
    public var className: String!
    var sessionsGet: Int!
    var date = Date()
    var fullTodayDate: String?
    var isFiltering = false
    
    // Filter Requirements
    @IBOutlet var filterDatePicker: UIDatePicker!
    
    // Lists
    var userClassesNameList: [String] = []
    var classList = [ScheduleClasses]()
    var filteredClasses = [ScheduleClasses]()

    // Refresh Control
    let refreshControl = UIRefreshControl()
    @objc
    func refresh(sender: AnyObject) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: Date())
        todayFilterAction(todaysDate: dateString)
        scheduleTableMain.reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        // readClassesDetails()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd/MM/yyyy"
        let forDate = dateFormatterGet.string(from: filterDatePicker.date)
        view.makeToast("\(forDate)")
        print("For Date \(classList.filter { $0.date == forDate })")
        isFiltering = true
        filteredClasses = classList.filter { $0.date == forDate }
        scheduleTableMain.reloadData()
        if filteredClasses.isEmpty {
            scheduleTableMain.hideActivityIndicator()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schedule"
        setupViewsandControls()
    }

    override func viewWillDisappear(_ animated: Bool) {
        classList.removeAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        readUserData()
        readClassesDetails()
       
        // refreshControl.endRefreshing()
    }
    
    func setupViewsandControls() {
        // Setup Tableviews
        scheduleTableMain.delegate = self
        scheduleTableMain.dataSource = self
        scheduleTableMain.refreshControl = refreshControl
        scheduleTableMain.emptyDataSetSource = self
        scheduleTableMain.emptyDataSetDelegate = self
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        // Setup Refrences
        classesRef = Database.database().reference().child("Classes")
        ref = Database.database().reference()
        
        // Datepicker Setup
        filterDatePicker.minimumDate = NSDate() as Date
      
        // navigation view button
        let button1 = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refresh))
        navigationItem.rightBarButtonItem = button1
    }

    func readUserData() {
        // MARK: - Get User Data
        ref.child("Users").child(authIDUser ?? "").child("userClasses").observe(.value) {
            snapshot in
            for child in snapshot.children {
                let ns = child as! DataSnapshot
                let dict = ns.value as! String
                self.userClassesNameList.append(dict)
            }
        }
        
        ref.child("Users").child(authIDUser!).child("userPackages").observeSingleEvent(of: .value, with: {
            snapshot in
            let value = snapshot.value as? NSDictionary
            self.sessionsGet = value?["sessions"] as? Int
            let active = value?["active"] as? Bool ?? true
            
            if !active {
                self.scheduleTableMain.isHidden = true
                self.filterDatePicker.isHidden = true
            }
        })
    }
    
    func readClassesDetails() {
        // MARK: - Get Classes Data
        classesRef.observe(DataEventType.value, with: {
            snapshot in
            if snapshot.childrenCount > 0 {
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
                    self.classList.append(lister)
                    self.isFiltering = true
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    let dateString = dateFormatter.string(from: Date())
                    self.todayFilterAction(todaysDate: dateString)
                }
                self.scheduleTableMain.reloadData()
            }
        })
    }
    
    func todayFilterAction(todaysDate: String) {
        filteredClasses = classList.filter { $0.date == todaysDate }
        scheduleTableMain.reloadData()
        if filteredClasses.isEmpty {
            scheduleTableMain.hideActivityIndicator()
        }
        else {
            scheduleTableMain.showActivityIndicator()
        }
    }
    
    // Scroll to current date
//    @objc
//    func todaySet() {
//        let minDate = DatePickerHelper.shared.dateFrom(day: date.day(), month: date.month(), year: date.year())!
//        let maxDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 2030)!
//        let today = Date()
//        // Create picker object
//        let datePicker = DatePicker()
//        // Setup
//
//        datePicker.setup(beginWith: today, min: minDate, max: maxDate) {
//            selected, date in
//            if selected, let selectedDate = date {
//                let ofd: String = "\(selectedDate.day())/\(selectedDate.month())/\(selectedDate.year())"
//
//                // self.filterTableWithDate(ofDate: ofd)
//            }
//            else {
//                print("Cancelled")
//            }
//        }
//        // Display
//        datePicker.show(in: self)
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        scheduleTableMain.backgroundColor = .white
        // scheduleTableMain.showActivityIndicator()
        scheduleTableMain.rowHeight = 290
    }
   
    @objc
    func jooinBtn(_ sender: AnyObject) {
        let position: CGPoint = sender.convert(.zero, to: scheduleTableMain)
        let indexPath = scheduleTableMain.indexPathForRow(at: position)
        
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
                                                 print(classes.usersJoined)
                                                 if classes.usersJoined.isEmpty {
                                                     keyForNext = 0
                                                 }
                                                 else {
                                                     keyForNext = classes.usersJoined.count
                                                 }
                                                 print("Key for Next \(keyForNext!)")
                                                 self.ref.child("Classes").child(classes.id).child("usersJoined").child("\(keyForNext!)").setValue(self.authIDUser) {
                                                     error, _ in
                                                     if error == nil {
                                                         // MARK: - sent 1

                                                         // MARK: - Reload Views

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
                                                
                                             })
        let actionOpt = MDCActionSheetAction(title: "You have already Joined the Class",
                                             image: .strokedCheckmark, handler: {
                                                 _ in
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
       
        if classes.usersJoined.contains(authIDUser!) {
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

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource, EmptyDataSetDelegate, EmptyDataSetSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
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
        scheduleTableMain.hideActivityIndicator()

        // MARK: - Setup Fonts

        cell.classNameGet.textColor = .white
        cell.classNameGet.font = UIFont.appBoldFontWith(size: 20)
        cell.classTimeGet.font = UIFont.appRegularFontWith(size: 17)
        cell.coachNameGet.font = UIFont.appRegularFontWith(size: 17)
        cell.totalMembersGet.font = UIFont.appRegularFontWith(size: 17)
        cell.classCapacityGet.font = UIFont.appRegularFontWith(size: 17)

        // MARK: - Setup TV TEXTS

        cell.classNameGet.text = classes.name
        cell.classTimeGet.text = "\(String(describing: classes.startTime)) - \(String(describing: classes.endTime))"
        cell.classCapacityGet.text = "\(classes.capacity - classes.usersJoined.count) spots remaining"
        cell.totalMembersGet.text = "\(classes.usersJoined.count) Joined"
        cell.coachNameGet.text = classes.coach
        cell.joinClassBtn.addTarget(self, action: #selector(ScheduleViewController.jooinBtn(_:)), for: .touchUpInside)
        
        return cell
    }

    // MARK: - ImageResize for No Data

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        }
        else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }

    // MARK: - DZNEmptyDataSetSource

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        let image = resizeImage(image: UIImage(named: "relaxman")!, targetSize: CGSize(width: 200.0, height: 200.0))
        return image
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let quote = "No Classes Found, Rest Day?"
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
        let quote = "Use Date Picker to select todays date and refresh the Class List"
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
}
