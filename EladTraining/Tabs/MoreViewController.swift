//
//  MoreViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//

import UIKit

class MoreViewController: UIViewController {

    @IBOutlet weak var profileTabel:UITableView!
    let viewNames:[String] = [
        "Edit Profile",
        "Your Classes",
        "Settings" ,
        "Support"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        profileTabel.delegate = self
        profileTabel.dataSource = self
        
    }

}

extension MoreViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row == 0){
            print(String(describing:"row at Edit Profile Clicked"))
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }else if(indexPath.row == 1){
            print(String(describing:"row at Your Classes Clicked"))
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }else if(indexPath.row == 2){
            print(String(describing:"row at Settings Clicked"))
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }else if(indexPath.row == 2){
            print(String(describing:"row at Support Clicked"))
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }

        
    }
}
extension MoreViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewNames.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath)
        cell.textLabel?.text = viewNames[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.font = UIFont(name: "Poppins-Medium", size: 18)
        cell.imageView?.frame = CGRect(x:0,y:0,width: 24,height:24);
        cell.textLabel?.textColor = UIColor.white
        
        if(indexPath.row == 0)
        {
            
            cell.imageView?.image = UIImage(systemName: "pencil.circle")
            
        }else if(indexPath.row == 1){
         
            cell.imageView?.image = UIImage(systemName: "person.fill.viewfinder")
        }else if(indexPath.row == 2){
            cell.imageView?.image = UIImage(systemName: "gear")
        }else if(indexPath.row == 3){
            cell.imageView?.image = UIImage(systemName: "phone.connection")
        }
        else{
            cell.imageView?.image = UIImage(systemName: "gear")
        }
        
        
        
        return cell
    }
    
    
    
}
