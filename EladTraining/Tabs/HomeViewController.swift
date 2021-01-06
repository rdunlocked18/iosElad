//
//  HomeViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//

import UIKit
import MaterialComponents.MaterialCards
import DateScrollPicker

class HomeViewController: UIViewController {
       
    @IBOutlet weak var dateScrollPicker: DateScrollPicker!
      

      
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

      override func viewDidLoad() {
        super.viewDidLoad()
        var format = DateScrollPickerFormat()

        /// Number of days
        format.days = 7

        /// Top label date format
        format.topDateFormat = "EEE"

        /// Top label font
        format.topFont = UIFont.systemFont(ofSize: 10, weight: .regular)

        /// Top label text color
        format.topTextColor = UIColor.black

        /// Top label selected text color
        format.topTextSelectedColor = UIColor.white

        /// Medium label date format
        format.mediumDateFormat = "dd"

        /// Medium label font
        format.mediumFont = UIFont.systemFont(ofSize: 30, weight: .bold)

        /// Medium label text color
        format.mediumTextColor = UIColor.black

        /// Medium label selected text color
        format.mediumTextSelectedColor = UIColor.white

        /// Bottom label date format
        format.bottomDateFormat = "MMM"

        /// Bottom label font
        format.bottomFont = UIFont.systemFont(ofSize: 10, weight: .regular)

        /// Bottom label text color
        format.bottomTextColor = UIColor.black

        /// Bottom label selected text color
        format.bottomTextSelectedColor = UIColor.white

        /// Day radius
       // format.dayRadius : CGFloat = 5

        /// Day background color
        format.dayBackgroundColor = UIColor(named: "someCyan") ?? .lightGray

        /// Day background selected color
        format.dayBackgroundSelectedColor = UIColor.darkGray

        /// Selection animation
        format.animatedSelection = true

        /// Separator enabled
        format.separatorEnabled = true

        /// Separator top label date format
        format.separatorTopDateFormat = "MMM"

        /// Separator top label font
        format.separatorTopFont = UIFont.systemFont(ofSize: 20, weight: .bold)

        /// Separator top label text color
        format.separatorTopTextColor = UIColor.black

        /// Separator bottom label date format
        format.separatorBottomDateFormat = "yyyy"

        /// Separator bottom label font
        format.separatorBottomFont = UIFont.systemFont(ofSize: 20, weight: .regular)

        /// Separator bottom label text color
        format.separatorBottomTextColor = UIColor.black

        /// Separator background color
        format.separatorBackgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

        /// Fade enabled
        format.fadeEnabled = true

        
      }
    
    

}
