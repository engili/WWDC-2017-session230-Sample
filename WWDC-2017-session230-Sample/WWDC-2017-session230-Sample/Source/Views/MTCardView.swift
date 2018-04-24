//
//  MTCardView.swift
//  WWDC-2017-session230-Sample
//
//  Created by LiMengtian on 2018/4/23.
//  Copyright © 2018 LiMengtian. All rights reserved.
//

import UIKit

enum State {
    case Expanded
    case Collapsed
}

class MTCardView: UIView {
    
    struct Constants {
        static let kViewHeight: CGFloat = UIScreen.main.bounds.size.height * 0.8
        static let kTitleHeight: CGFloat = 64.0
        
        fileprivate static let kCollapsedY = UIScreen.main.bounds.size.height - 64.0
        fileprivate static let kExpandedY = UIScreen.main.bounds.size.height - kViewHeight
        fileprivate static let kViewWith = UIScreen.main.bounds.size.width
        
        fileprivate static let kCollapsedFrame = CGRect(x: 0, y: kCollapsedY, width: kViewWith, height: kViewHeight)
        fileprivate static let kExpandedFrame = CGRect(x: 0, y: kExpandedY, width: kViewWith, height: kViewHeight)
    }
    
    fileprivate var topTitleView: UIView!
    fileprivate var titleLabel: UILabel!
    
    fileprivate var runningAnimators = [UIViewPropertyAnimator]()
    
    fileprivate var currentState: State
    
    fileprivate var frameAnimatorObsverToken: NSKeyValueObservation?
    
    //MARK: - Life Cycle
    
    init(state: State) {
        var frame:CGRect
        switch state {
        case .Collapsed:
            frame = Constants.kCollapsedFrame
        case .Expanded:
            frame = Constants.kExpandedFrame
        }
        currentState = state
        super.init(frame: frame)
        
        self.setupSubviews()
        self.setupConstraints()
        self.addGestureRecognizer()
    }
    
    convenience override init(frame: CGRect) {
        self.init(state: .Collapsed)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("")
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
        topTitleView.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTapGesture(_:)) )
        topTitleView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        topTitleView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc fileprivate func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        switch currentState {
        case .Collapsed:
            self.animateOrReverseRunningTransition(state: .Expanded, duration: 1.0)
            currentState = .Expanded
        case .Expanded:
            self.animateOrReverseRunningTransition(state: .Collapsed, duration: 1.0)
            currentState = .Collapsed
        }
    }
    
    @objc fileprivate func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
    }
    
    func animateTransitionIfNeeded(state:State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) {
                switch state {
                case .Expanded :
                    self.frame = Constants.kExpandedFrame
                    break
                case .Collapsed:
                    self.frame = Constants.kCollapsedFrame
                    break
                }
            }
            
            frameAnimator.startAnimation()
            frameAnimator.pausesOnCompletion = true
            runningAnimators.append(frameAnimator)

            frameAnimatorObsverToken = frameAnimator.observe(\.isRunning) { [unowned self] (animator, change) in
                if !animator.isRunning {
                    switch self.currentState {
                    case .Collapsed:
                        self.frame = Constants.kCollapsedFrame
                    case .Expanded:
                        self.frame = Constants.kExpandedFrame
                    }
                }
            }
    
        }
    }
    
    func animateOrReverseRunningTransition(state: State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            self.animateTransitionIfNeeded(state: state, duration: duration)
        } else {
            for animator in runningAnimators {
                animator.isReversed = !animator.isReversed
                animator.startAnimation()
            }
        }
    }
}
