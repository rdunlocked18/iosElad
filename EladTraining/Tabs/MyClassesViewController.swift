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
    @IBOutlet weak var myClassesTableView: UITableView!
    var classList = [MyclassesModel]()
    var ref:DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Classes"
        self.navigationController?.navigationBar.backgroundColor = .white
        myClassesTableView.dataSource = self
        myClassesTableView.delegate = self
        
        
        
        ref = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("userClasses")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            print(value)
                
            
            
          }) { (error) in
            print(error.localizedDescription)
        }
                self.myClassesTableView.reloadData()
        
    }
        


    
    
override func viewDidAppear(_ animated: Bool) {
        
  

}
}
        
extension MyClassesViewController : UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myClassesTableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath) as! MyClassesCellTableViewCell
        let classes : MyclassesModel
        
        classes = classList[indexPath.row]
        
    
        
        
        
        
        return cell
        
    }
    
    
}





