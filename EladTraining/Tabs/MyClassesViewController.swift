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

class MyClassesViewController: UIViewController {
    var uidd:String = Auth.auth().currentUser?.uid ?? ""
    @IBOutlet weak var myClassesTableView: UITableView!
    var classNamesList:[String] = []
    var ref:DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Classes"
      //  self.navigationController?.navigationBar.backgroundColor = .white
        myClassesTableView.dataSource = self
        myClassesTableView.delegate = self
        //myClassesTableView.prefetchDataSource = self
        
        ref = Database.database().reference().child("Users").child(uidd).child("userClasses")
       
            ref.observe(.value) { snapshot in
                for child in snapshot.children {
                    let ns = child as! DataSnapshot
                    let dict = ns.value as! String
                    self.classNamesList.append(dict)
                print(self.classNamesList)
              }
                self.myClassesTableView.reloadData()
            }
        
        
        
        
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
    
    
}





