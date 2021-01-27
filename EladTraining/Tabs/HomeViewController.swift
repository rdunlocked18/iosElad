//
//  HomeViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//

import UIKit
import MaterialComponents.MaterialCards
import FirebaseDatabase
import FirebaseAuth
import Firebase
import Nuke
import PMAlertController

class HomeViewController : UIViewController {
    
    @IBOutlet weak var homeWelcome: UILabel!
    @IBOutlet weak var homeNewsTableView: UITableView!
    @IBOutlet weak var tabSwitch: UISegmentedControl!
    @IBOutlet weak var homeDp: UIImageView!
    
    @IBOutlet weak var yourActivityView: UIView!
    //table
    var homeNewsList = [NewsModel]()
    var homeNewsRef:DatabaseReference!
    var userRef:DatabaseReference!
    var authUid:String! = Auth.auth().currentUser?.uid
    var dbQuery:DatabaseQuery!

    var name:String!
  
    
    override
    func viewWillAppear(_ animated: Bool) {
        
        
        
        super.viewWillAppear(animated)
        
        // fetch firebase
        userRef = Database.database().reference().child("Users").child(authUid)
        
        userRef.child("userClasses").observe(.value) { (snapshot) in
            if snapshot.childrenCount == 0 {
                if let tabBarItems = self.tabBarController?.tabBar.items {
                     let tabItem = tabBarItems[2]
                     tabItem.badgeValue = "0"
                }
            } else {
                if let tabBarItems = self.tabBarController?.tabBar.items {
                     let tabItem = tabBarItems[2]
                    tabItem.badgeValue = "\(snapshot.childrenCount)"
                }

            }
            
            
            
        }
        
        
        
        homeNewsRef = Database.database().reference().child("HomeInfo").child("News")
        dbQuery = homeNewsRef.queryOrdered(byChild: "timeStamp")
        readNewsData()
        readUserData()
        
    }
//    func getClassesFromIds(){
//        classesRef.observe(.value) { (snapshot) in
//            for ds in self.userJoinedClassesList {
//                if(self.userJoinedClassesList.isEmpty){
//                    print("not joined")
//                }else{
//                    print("value of \(ds)")
//                    self.readClassesData(classId: [ds])
//
//                }
//            }
//
//        }
//
//    }
//
//    func readClassesData(classId:[String]){
//        //MARK:- Get Firebase Data
//        print("Got class id \(classId)")
//        userRef.child("Classes").observe(DataEventType.value,with:{
//            (snapshot) in
//            if snapshot.childrenCount > 0{
//                self.classFulldetList.removeAll()
//                for classesSch in snapshot.children.allObjects as![DataSnapshot]{
//                    let classesSchObject = classesSch.value as? [String:AnyObject]
//
//                    let id = classesSchObject?["id"]
//                    let capacity = classesSchObject?["capacity"]
//                    let coach = classesSchObject?["coach"]
//                    let date = classesSchObject?["date"]
//                    let description = classesSchObject?["description"]
//                    let name = classesSchObject?["name"]
//                    let timings = classesSchObject?["timings"]
//                    let timeStamp = classesSchObject?["timeStamp"]
//                    let usersJoined = classesSchObject?["usersJoined"]
//
//                    let lister = ScheduleClasses(id:id as! String?,capacity: capacity as? Int, coach: (coach as! String), date: (date as? String), description: (description as! String), name: name as? String, timings: timings as? String,timestamp: timeStamp as? Int,userJoined: usersJoined as! [String]?)
//
//                    print(self.classFulldetList)
//
//                    for ids in classId {
//                        if ids == id as! String {
//                            self.classFulldetList.append(lister)
//                            print("my joined classes \(self.classFulldetList.count)")
//
//                        }
//
//                    }
//
//                }
//
//            }
//
//
//
//
//        })
//
//    }
//    
    
    
    
    func readNewsData(){
        //MARK:- Get Firebase Data
        self.homeNewsTableView.showActivityIndicator()
        dbQuery.observe(.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.homeNewsList.removeAll()
                for news in snapshot.children.allObjects as! [DataSnapshot]{
                    let newsObject = news.value as? [String:AnyObject]
                    
                    //with keys
                    let title  = newsObject?["title"]
                    let description = newsObject?["body"]
                    let imageUrl = newsObject?["imageUrl"]
                    let timeStamp = newsObject?["timeStamp"]
                    
                    let newsModLister = NewsModel(body: description as? String, imageUrl: imageUrl as? String, timeStamp: timeStamp as? Int, title: title as? String)
                   
                    print(title ?? "not got")
                    self.homeNewsList.append(newsModLister)
                    
                }
                self.homeNewsTableView.reloadData()
            }
        }
    
    }
    func readUserData(){
        self.userRef.child("userDetails").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let name = value?["fullName"] as? String ?? ""
            let img = value?["imageUrl"] as? String ?? ""
            let height = value?["height"] as? String ?? ""
            let weight = value?["weight"] as? String  ?? ""
        
            if height == nil || weight == nil || height == "" || weight == "" {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "createProfile") as! CreateProfileViewController
                      self.present(newViewController, animated: true, completion: nil)
            }
            
            
            self.homeWelcome.font = UIFont.appBoldFontWith(size: 20)
            let nameSplit = name.components(separatedBy: " ")
            self.homeWelcome.text = "Hello \(nameSplit[0]) !"
            
            
            
            
            if img == "" || img == nil  || img == "null" {

            }else{
                Nuke.loadImage(with: ImageRequest(url: URL(string: img)!, processors: [
                    ImageProcessors.Resize(width : 125),
                    ImageProcessors.Resize(height: 125),
                    ImageProcessors.Circle()
                    
                
                ]), into: self.homeDp)
            }
        }
    }
    
      
    @IBAction func tabChanged(_ sender: Any) {
        if tabSwitch.selectedSegmentIndex == 0 {
            homeNewsTableView.isHidden = false
            yourActivityView.isHidden = true
        } else if tabSwitch.selectedSegmentIndex == 1 {
            homeNewsTableView.isHidden = true
            yourActivityView.isHidden = false
        }
    }
    func showNews (){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yourActivityView.isHidden = true
        self.homeNewsTableView.dataSource = self
        self.homeNewsTableView.delegate = self
        self.homeNewsTableView.rowHeight = 286
        self.homeNewsTableView.showsVerticalScrollIndicator = false
        
        
        //fonts home page
        self.homeWelcome.font = UIFont.appBoldFontWith(size: 17)
        
        

       
      }
    
    
    

}
extension HomeViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeNewsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = homeNewsTableView.dequeueReusableCell(withIdentifier: "hcell",for: indexPath) as! HomeTableViewCell
        let news : NewsModel
        news = homeNewsList[indexPath.row]
        homeNewsTableView.hideActivityIndicator()
        
        cell.titleGet.textColor = .white
        cell.descriptionGet.textColor = .white
        cell.titleGet.font = UIFont.appRegularFontWith(size: 17)
        cell.descriptionGet.font = UIFont.appRegularFontWith(size: 17)
        
        //setup actual data
        cell.descriptionGet.text = news.body
        cell.titleGet.text = news.title
       // cell.fullImage.image = UIImage(named: "circleLogo")
        if !(news.imageUrl == "" || news.imageUrl == "null" || news.imageUrl == " "){
            Nuke.loadImage(with: ImageRequest(url: URL(string: news.imageUrl)!) ,into: cell.fullImage)
        }
        return cell
    }
    
    
}
