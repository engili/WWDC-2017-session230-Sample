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
        
        self.view.addConstraint(NSLayoutConstraint(item: cardVC.view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: cardVC.view, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: cardVC.view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -64.0))
        
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
