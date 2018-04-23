//
//  MTCardView.swift
//  WWDC-2017-session230-Sample
//
//  Created by LiMengtian on 2018/4/23.
//  Copyright © 2018 LiMengtian. All rights reserved.
//

import UIKit

class MTCardView: UIView {
    
    struct Constants {
        static let kTitleHeight: CGFloat = 64.0
    }
    
    fileprivate var topTitleView: UIView!
    fileprivate var titleLabel: UILabel!
    
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
        self.setupConstraints()
        self.addGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupSubviews()
        self.setupConstraints()
        self.addGestureRecognizer()
    }
    
    //MARK: - UI
    
    fileprivate func setupSubviews() {
        self.setupTopTitleView()
        self.setupTitleLabel()
    }

    fileprivate func setupConstraints() {
        //topTitleView
        self.addConstraint(NSLayoutConstraint(item: topTitleView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: topTitleView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: topTitleView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: topTitleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: Constants.kTitleHeight))
        
        //titleLabel
        topTitleView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: topTitleView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        topTitleView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: topTitleView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    fileprivate func setupTopTitleView() {
        topTitleView = UIView(frame: .zero)
        topTitleView.backgroundColor = .white
        topTitleView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(topTitleView)
    }
    
    fileprivate func setupTitleLabel() {
        titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = UIColor.black
        titleLabel.text = "Comments"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topTitleView.addSubview(titleLabel)
    }
    
    // Gesture
    fileprivate func addGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTapGesture(_:)) )
        topTitleView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        topTitleView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc fileprivate func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        
    }
    
    @objc fileprivate func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
    }
    
    
}
