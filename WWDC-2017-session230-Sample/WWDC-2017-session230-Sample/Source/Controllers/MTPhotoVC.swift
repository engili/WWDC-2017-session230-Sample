//
//  MTPhotoVC.swift
//  WWDC-2017-session230-Sample
//
//  Created by LiMengtian on 2018/4/23.
//  Copyright © 2018 LiMengtian. All rights reserved.
//

import UIKit

class MTPhotoVC: UIViewController {
    
    var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.image = UIImage(named: "background")
        self.view.addSubview(backgroundImageView)
        
        let cardVC = MTCardVC()
        self.addChildViewController(cardVC)
        self.view.addSubview(cardVC.view)
        cardVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[cardView]-(0)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardVC.view]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[cardView]-(0)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardVC.view]))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
