//
//  ScheduleTableViewCell.swift
//  EladTraining
//
//  Created by Rohit Daftari on 16/12/20.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var classTimeGet: UILabel!
    @IBOutlet weak var classNameGet: UILabel!
    @IBOutlet weak var coachNameGet: UILabel!
    @IBOutlet weak var classCapacityGet: UILabel!
    @IBOutlet weak var totalMembersGet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
