//
//  MTCardVC.swift
//  WWDC-2017-session230-Sample
//
//  Created by LiMengtian on 2018/4/23.
//  Copyright © 2018 LiMengtian. All rights reserved.
//

import UIKit

class MTCardVC: UIViewController {
    
    fileprivate var cardView: MTCardView!
   
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.clear
                
        cardView = MTCardView(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cardView)
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[cardView]-(0)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[cardView]-(0)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView]))
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UI
  
    
   
}
