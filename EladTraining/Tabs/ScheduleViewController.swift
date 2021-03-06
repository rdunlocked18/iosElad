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
    var userRef: DatabaseReference!

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
        classList.removeAll()
        readUserData()
        readClassesDetails()
        scheduleTableMain.reloadData()
        refreshControl.endRefreshing()
        filterDatePicker.setDate(Date(), animated: true)
    }

    // Date Change With Touch input
    @IBAction func dateChanged(_ sender: Any) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd/MM/yyyy"
        let forDate = dateFormatterGet.string(from: filterDatePicker.date)
        view.makeToast("Showing Classes On : \(forDate)")
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupViewsandControls() {
        // Setup Tableviews
        scheduleTableMain.backgroundColor = .white
        scheduleTableMain.rowHeight = 290
        scheduleTableMain.delegate = self
        scheduleTableMain.dataSource = self
        scheduleTableMain.refreshControl = refreshControl
        scheduleTableMain.emptyDataSetSource = self
        scheduleTableMain.emptyDataSetDelegate = self
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)

        // Setup Refrences
        classesRef = Database.database().reference().child("Classes")
        ref = Database.database().reference()
        userRef = Database.database().reference().child("Users").child(authIDUser!)

        // Datepicker Setup
        filterDatePicker.minimumDate = NSDate() as Date

        // navigation view button
        let button1 = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(refresh))
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
                self.loadNotActiveView()
                
            }
        })
    }
    
    func loadNotActiveView(){
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
        label.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2)
        label.textAlignment = .center
        label.text = "Your Package is inactive"
        label.textColor = .red
        label.font = UIFont.appBoldFontWith(size: 17)
        self.view.addSubview(label)
        let subtitle = UILabel(frame: CGRect(x: 0, y: 0, width: 500, height: 21))
        subtitle.center =  CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 1.8)
        subtitle.textAlignment = .center
        subtitle.text = "Please purchase a package or contact support!"
        subtitle.font = UIFont.appRegularFontWith(size: 15)
        self.view.addSubview(subtitle)
       //CGPoint(x: 200, y: 350)
    }
    

    func readClassesDetails() {
        // MARK: - Get Classes Data

        classList.removeAll()
        classesRef.queryOrdered(byChild: "timeStamp").observeSingleEvent(of: .value, with: {
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

    func sendJoinButton(classId: String) {
        classesRef.child(classId).child("usersJoined").observeSingleEvent(of: .value) {
            snapshot in
            if snapshot.hasChildren() {
                print(snapshot.childrenCount)
                let keyIdasCount = snapshot.childrenCount
                self.setDataInClass(keyId: Int(keyIdasCount), classId: classId)
            }
            else {
                self.setDataInClass(keyId: 0, classId: classId)
            }
        }
    }

    func setDataInClass(keyId: Int, classId: String) {
        classesRef.child(classId).child("usersJoined").child("\(keyId)").setValue(authIDUser) { error, _ in
            if error == nil {
                self.userRef.child("userClasses").observeSingleEvent(of: .value) { snapshot in
                    if snapshot.hasChildren() {
                        let keyIdasCount = snapshot.childrenCount
                        self.setDataInUserboundClass(keyId: Int(keyIdasCount), classId: classId)
                    }
                    else {
                        self.setDataInUserboundClass(keyId: 0, classId: classId)
                    }
                }
            }
            else {
                // rollback
            }
        }
    }

    func setDataInUserboundClass(keyId: Int, classId: String) {
        userRef.child("userClasses").child("\(keyId)").setValue(classId) { error, _ in
            if error == nil {
                // success fully joined class

                self.refresh(sender: self)

                self.view.makeToast("Successfully Joined Class")
            }
            else {
                // rollback
                self.view.makeToast("Error Joining Class")
            }
        }
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
        _ = MDCActionSheetAction(title: classes.description,
                                 image: .none)
        let actionOne = MDCActionSheetAction(title: "Join Class",
                                             image: .checkmark,
                                             handler: {
                                                 _ in
                                                 self.userRef.child("userPackages").observeSingleEvent(of: .value, with: {
                                                     snapshot in
                                                     let value = snapshot.value as? NSDictionary
                                                     let session = value?["sessions"] as! Int
                                                     let active = value?["active"] as? Bool ?? true
                                                     if session > 0 {
                                                         self.userRef.child("userPackages").child("sessions").setValue(session - 1)
                                                         self.sendJoinButton(classId: classes.id)
                                                     }
                                                     else if !active {
                                                         self.view.makeToast("Your Package is Not Active !")
                                                     }
                                                     else {
                                                         self.view.makeToast("No Sessions Left")
                                                     }

                                                 })

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
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 50, 0)
//        cell.layer.transform = rotationTransform
//        cell.alpha = 0
//        UIView.animate(withDuration: 1) {
//            cell.alpha = 1.0
//        }
//    }

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
        if(classes.usersJoined.contains(authIDUser!)){
            cell.joinClassBtn.isEnabled = false
            cell.joinClassBtn.setTitle("Joined", for: .disabled)
            cell.joinClassBtn.setImage(UIImage(systemName: "checkmark.seal"), for: .disabled)
        }else {
            cell.joinClassBtn.isEnabled = true
            cell.joinClassBtn.setTitle("Join Class", for: .focused)
            cell.joinClassBtn.setImage(UIImage(systemName: "person.crop.circle.badge.plus"), for: .focused)
            cell.joinClassBtn.addTarget(self, action: #selector(ScheduleViewController.jooinBtn(_:)), for: .touchUpInside)
        }
        
//        let current = Int(NSDate().timeIntervalSince1970)
//        if classes.timestamp < current {
//            cell.joinClassBtn.isEnabled = false
//            cell.joinClassBtn.setTitle("Class Time Over", for: .disabled)
//            cell.joinClassBtn.setImage(UIImage(systemName: "xmark.octagon.fill"), for: .disabled)
//        }

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
