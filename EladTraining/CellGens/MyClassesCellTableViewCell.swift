//
//  MyClassesCellTableViewCell.swift
//  EladTraining
//
//  Created by Rohit Daftari on 20/12/20.
//

import UIKit

class MyClassesCellTableViewCell: UITableViewCell {
    @IBOutlet weak var classNameLbl:UILabel!
    @IBOutlet weak var btnViewClass:UIButton!
    
    @IBOutlet weak var classDescription: UILabel!
    
    @IBOutlet weak var classTimeLbl: UILabel!
    @IBOutlet weak var classDateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
