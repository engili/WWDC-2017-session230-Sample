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
        
        fileprivate static let duration: TimeInterval = 0.75
    }
    
    fileprivate var containerView: UIView!
    fileprivate var topTitleView: UIView!
    fileprivate var titleLabel: UILabel!
    fileprivate var blurEffectView: UIVisualEffectView!
    
    fileprivate var runningAnimators = [UIViewPropertyAnimator]()
    fileprivate var currentState: State
    fileprivate var aimState: State?
    fileprivate var frameAnimatorObsverToken: NSKeyValueObservation?
    
    //MARK: - Life Cycle
    deinit {
        print("MTCardView deinit")
    }
    
    init(state: State) {
        currentState = state
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.clear
    
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
        self.setupBlurView()
        self.setupContainerView()
        self.setupTopTitleView()
        self.setupTitleLabel()
        
    }

    fileprivate func setupConstraints() {
        //blurView
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[blurEffectView]-(0)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["blurEffectView":blurEffectView.contentView]))
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[blurEffectView]-(0)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["blurEffectView":blurEffectView.contentView]))
        
        self.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        
        //topTitleView
        self.addConstraint(NSLayoutConstraint(item: topTitleView, attribute: .leading, relatedBy: .equal, toItem: self.containerView, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: topTitleView, attribute: .trailing, relatedBy: .equal, toItem: self.containerView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: topTitleView, attribute: .top, relatedBy: .equal, toItem: self.containerView, attribute: .top, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: topTitleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: Constants.kTitleHeight))
        
        //titleLabel
        topTitleView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: topTitleView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        topTitleView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: topTitleView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    fileprivate func setupBlurView() {
        blurEffectView = UIVisualEffectView(frame: .zero)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(blurEffectView)
        
        switch currentState {
        case .Collapsed:
            blurEffectView.effect = nil
        case .Expanded:
            blurEffectView.effect = UIBlurEffect(style: .dark)
        }
    }
    
    fileprivate func setupContainerView() {
        var frame:CGRect
        switch currentState {
        case .Collapsed:
            frame = Constants.kCollapsedFrame
        case .Expanded:
            frame = Constants.kExpandedFrame
        }
        containerView = UIView(frame: frame)
        containerView.backgroundColor = .white
        containerView.clipsToBounds = true
        self.addSubview(containerView)
    }
    
    fileprivate func setupTopTitleView() {
        topTitleView = UIView(frame: .zero)
        topTitleView.backgroundColor = .white
        topTitleView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(topTitleView)
    }
    
    fileprivate func setupTitleLabel() {
        titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = UIColor.black
        titleLabel.text = "Comments"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topTitleView.addSubview(titleLabel)
    }
    
    //MARK: - Gesture
    fileprivate func addGestureRecognizer() {
        topTitleView.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTapGesture(_:)) )
        topTitleView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        topTitleView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc fileprivate func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        aimState = currentState == .Collapsed ? .Expanded : .Collapsed
        self.animateOrReverseRunningTransition(state: aimState!, duration: Constants.duration)
    }
    
    @objc fileprivate func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    
        switch gesture.state {
        case .began:
            aimState = currentState == .Collapsed ? .Expanded : .Collapsed
            self.startInteractiveTransition(state: aimState!, duration: Constants.duration)
        case .changed:
            let transtion = gesture.translation(in: self)
            let deltY = Constants.kExpandedY - Constants.kCollapsedY
            self.updateInteractiveTransition(fractionComplete: fabs(transtion.y / deltY))
        case .ended:
            self.continueInteractiveTransition(cancel: false)
            break
        default:
            break
        }

    }
    
    //MARK: - Animation
    fileprivate func animateTransitionIfNeeded(state:State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) {
                switch state {
                case .Expanded :
                    self.containerView.frame = Constants.kExpandedFrame
                case .Collapsed:
                    self.containerView.frame = Constants.kCollapsedFrame
                }
            }
            
            frameAnimator.pausesOnCompletion = true
            runningAnimators.append(frameAnimator)

            frameAnimatorObsverToken = frameAnimator.observe(\.isRunning) { [unowned self] (animator, change) in
                if !animator.isRunning {
                    if let aimState = self.aimState {
                        self.currentState = aimState
                        switch aimState {
                        case .Collapsed:
                            self.containerView.frame = Constants.kCollapsedFrame
                        case .Expanded:
                            self.containerView.frame = Constants.kExpandedFrame
                        }
                    }
                    self.runningAnimators.removeAll()
                    self.frameAnimatorObsverToken = nil
                    self.aimState = nil
                }
            }
            
            let blurAnimator = UIViewPropertyAnimator(duration: Constants.duration, dampingRatio: 1.0) { [unowned self] in
                switch state {
                case .Collapsed:
                    self.blurEffectView.effect = nil
                case .Expanded:
                    self.blurEffectView.effect = UIBlurEffect(style: .dark)
                }
            }
            
            blurAnimator.pausesOnCompletion = true
            runningAnimators.append(blurAnimator)
            
            let cornerAnimator = UIViewPropertyAnimator(duration: Constants.duration, dampingRatio: 1.0) {
                switch state {
                case .Collapsed:
                    self.containerView.layer.cornerRadius = 0.0
                case .Expanded:
                    self.containerView.layer.cornerRadius = 12.0
                }
            }
            cornerAnimator.pausesOnCompletion = true
            runningAnimators.append(cornerAnimator)
            
    
        }
    }
    
    fileprivate func animateOrReverseRunningTransition(state: State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            self.animateTransitionIfNeeded(state: state, duration: duration)
            for animator in runningAnimators {
                animator.startAnimation()
            }
        } else {
            for animator in runningAnimators {
                animator.isReversed = !animator.isReversed
                animator.startAnimation()
            }
        }
    }
    
    fileprivate func startInteractiveTransition(state: State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            self.animateTransitionIfNeeded(state: state, duration: duration)
            for animator in runningAnimators {
                animator.pauseAnimation()
            }
        } else {
            for animator in runningAnimators {
                animator.isReversed = !animator.isReversed
                animator.pauseAnimation()
            }
        }
    }
    
    fileprivate func updateInteractiveTransition(fractionComplete: CGFloat) {
        for animator in runningAnimators {
            animator.fractionComplete = fractionComplete
        }
    }
    
    fileprivate func continueInteractiveTransition(cancel: Bool) {
        
        if cancel {
            
        } else {
            for animtor in runningAnimators {
                animtor.continueAnimation(withTimingParameters: nil, durationFactor: 1.0)
            }
        }
        
    }
    
}
