//
//  HomeViewController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//

import UIKit
import MaterialComponents.MaterialCards

class HomeViewController: UIViewController {
        let card: CustomCard = CustomCard()

      

      
    

      override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = containerScheme.colorScheme.backgroundColor
      }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpCard()
      }
    func setUpCard() {
        let bundle = Bundle(for: HomeViewController.self)
        //card.imageView.image = UIImage(named: "circleLogo", in: bundle, compatibleWith: nil)
        card.cardButton1.setTitle("Action 1", for: .normal)
        //card.classTiming.text! = "jhelp"
       // card.cardButton2.setTitle("Action 2", for: .normal)
        //card.cardButton1.applyTextTheme(withScheme: containerScheme)
        //card.cardButton2.applyTextTheme(withScheme: containerScheme)
        card.cornerRadius = 8
        //card.applyTheme(withScheme: containerScheme)
        card.setNeedsLayout()
        card.layoutIfNeeded()
        card.frame = CGRect(x: card.frame.minX,
                            y: card.frame.minY,
                            width: card.intrinsicContentSize.width,
                            height: card.intrinsicContentSize.height)
        if card.superview == nil { view.addSubview(card) }
        card.center = view.center
      }
    


}
extension HomeViewController {

  @objc class func catalogMetadata() -> [String: Any] {
    return [
      "breadcrumbs": ["Cards", "Card README example"],
      "description": "Cards contain content and actions about a single subject.",
      "primaryDemo": true,
      "presentable": true,
    ]
  }
}
