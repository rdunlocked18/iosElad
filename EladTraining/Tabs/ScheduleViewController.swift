//
//  ScheduleViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//

import UIKit
import MDatePickerView
import Firebase


class ScheduleViewController: UIViewController {
    //start filter
    lazy var MDate : MDatePickerView = {
           let mdate = MDatePickerView()
           mdate.delegate = self
           mdate.Color = UIColor(red: 0/255, green: 178/255, blue: 113/255, alpha: 1)
           mdate.cornerRadius = 14
           mdate.translatesAutoresizingMaskIntoConstraints = false
           mdate.from = 1920
           mdate.to = 2050
           return mdate
       }()
    let Today : UIButton = {
            let but = UIButton(type:.system)
            but.setTitle("ToDay", for: .normal)
            but.addTarget(self, action: #selector(today), for: .touchUpInside)
            but.translatesAutoresizingMaskIntoConstraints = false
            return but
        }()
        
        let Label : UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = UIFont.boldSystemFont(ofSize: 32)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    
    @objc func filterDate() {
        MDate.selectDate = Date()
        if(MDate.isHidden){
            MDate.isHidden = false
            Today.isHidden = false
            Label.isHidden = false
        }else{
            MDate.isHidden = true
            Today.isHidden = true
            Label.isHidden = true
        }
    }
    @objc func today() {
            MDate.selectDate = Date()
       
    }
    
    //end filters
    //table view
    
    @IBOutlet weak var scheduleTableMain:UITableView!
    
    var classList = [ScheduleClasses]()
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schedule"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter Date", style: .plain, target: self, action: #selector(filterDate))
        
        scheduleTableMain.delegate = self
        scheduleTableMain.dataSource = self

        view.addSubview(MDate)
        MDate.isHidden = true
        NSLayoutConstraint.activate([
            MDate.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            MDate.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            MDate.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            MDate.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
        
        view.addSubview(Today)
        Today.isHidden = true
        Today.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        Today.topAnchor.constraint(equalTo: MDate.bottomAnchor, constant: 20).isActive = true
        
        view.addSubview(Label)
        Label.topAnchor.constraint(equalTo: Today.bottomAnchor, constant: 30).isActive = true
        Label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        
        //table and Firebase
        ref = Database.database().reference().child("Classes");
        ref.observe(DataEventType.value,with:{(snapshot) in
            if snapshot.childrenCount > 0{
                self.classList.removeAll()
                for classesSch in snapshot.children.allObjects as![DataSnapshot]{
                    let classesSchObject = classesSch.value as? [String:AnyObject]
                    let capacity = classesSchObject?["capacity"]
                    let coach = classesSchObject?["coach"]
                    let date = classesSchObject?["date"]
                    let description = classesSchObject?["description"]
                    let name = classesSchObject?["name"]
                    let timings = classesSchObject?["timings"]
                    
                    let lister = ScheduleClasses(capacity: capacity as? Int, coach: (coach as! String), date: (date as? String), description: (description as! String), name: name as? String, timings: timings as? String)
                    self.classList.append(lister)
                }
                self.scheduleTableMain.reloadData()
                
            }
            
        })
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.tabBarController?.tabBar.barTintColor = UIColor(named: "someCyan")
        self.scheduleTableMain.backgroundColor = UIColor(named: "someCyan")
        self.scheduleTableMain.rowHeight = 200
        
    }
}
    
extension ScheduleViewController : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = scheduleTableMain.dequeueReusableCell(withIdentifier: "schCell" , for: indexPath) as! ScheduleTableViewCell
        let classes : ScheduleClasses
        classes = classList[indexPath.row]
        cell.classNameGet.text = classes.name
        return cell
        
    }
    
    
}

extension ScheduleViewController : MDatePickerViewDelegate {
    func mdatePickerView(selectDate: Date) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd - MM - yyyy"
        let date = formatter.string(from: selectDate)
        Label.text = date
    }
}
