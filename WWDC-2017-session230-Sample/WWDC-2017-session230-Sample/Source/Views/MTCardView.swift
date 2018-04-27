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
    fileprivate var outLabel: UILabel!
    fileprivate var inLabel: UILabel!
    fileprivate var blurEffectView: UIVisualEffectView!
    
    fileprivate var runningAnimators = [UIViewPropertyAnimator]()
    fileprivate var currentState: State
    fileprivate var aimState: State?
    fileprivate var frameAnimatorObsverToken: NSKeyValueObservation?
    
    fileprivate var inLabelScale: CGAffineTransform {
        get {
            let inLabelWidth = inLabel.bounds.width
            let outLabelWidth = outLabel.bounds.width
            
            let scale = inLabelWidth / outLabelWidth
            return CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    fileprivate var outLabelScale: CGAffineTransform {
        get {
            let inLabelWidth = inLabel.bounds.width
            let outLabelWidth = outLabel.bounds.width
            
            let scale = outLabelWidth / inLabelWidth
            return CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    fileprivate var inLabelTranslation: CGAffineTransform {
        get {
            let translation: CGFloat = -10
            return CGAffineTransform(translationX: 0.0, y: translation)
        }
    }
    
    fileprivate var outLabelTranslation: CGAffineTransform {
        get {
            let translation: CGFloat = 10
            return CGAffineTransform(translationX: 0.0, y: translation)
        }
    }
    
    
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
        topTitleView.addConstraint(NSLayoutConstraint(item: outLabel, attribute: .centerX, relatedBy: .equal, toItem: topTitleView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        topTitleView.addConstraint(NSLayoutConstraint(item: outLabel, attribute: .centerY, relatedBy: .equal, toItem: topTitleView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        topTitleView.addConstraint(NSLayoutConstraint(item: inLabel, attribute: .centerX, relatedBy: .equal, toItem: topTitleView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        topTitleView.addConstraint(NSLayoutConstraint(item: inLabel, attribute: .centerY, relatedBy: .equal, toItem: topTitleView, attribute: .centerY, multiplier: 1.0, constant: -10.0))
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
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.addSubview(containerView)
    }
    
    fileprivate func setupTopTitleView() {
        topTitleView = UIView(frame: .zero)
        topTitleView.backgroundColor = .white
        topTitleView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(topTitleView)
    }
    
    fileprivate func setupTitleLabel() {
        outLabel = UILabel(frame: .zero)
        outLabel.textColor = UIColor.blue
        outLabel.text = "Comments"
        outLabel.translatesAutoresizingMaskIntoConstraints = false
        outLabel.font = UIFont.systemFont(ofSize: 17.0)
        
        inLabel = UILabel(frame: .zero)
        inLabel.textColor = UIColor.black
        inLabel.text = "Comments"
        inLabel.translatesAutoresizingMaskIntoConstraints = false
        inLabel.font = UIFont.systemFont(ofSize: 25.0)
        
        switch currentState {
        case .Collapsed:
            outLabel.alpha = 1.0
            inLabel.alpha = 0.0
        case .Expanded:
            outLabel.alpha = 0.0
            inLabel.alpha = 1.0
        }
        
        topTitleView.addSubview(outLabel)
        topTitleView.addSubview(inLabel)
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
                    for inAnimator in self.runningAnimators {
                        inAnimator.stopAnimation(true)
                    }
                    self.runningAnimators.removeAll()
                    self.frameAnimatorObsverToken = nil
                    self.aimState = nil
                }
            }
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) { [unowned self] in
                switch state {
                case .Collapsed:
                    self.blurEffectView.effect = nil
                case .Expanded:
                    self.blurEffectView.effect = UIBlurEffect(style: .dark)
                }
            }
            blurAnimator.pausesOnCompletion = true
            runningAnimators.append(blurAnimator)
            
            let cornerAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) { [unowned self] in
                switch state {
                case .Collapsed:
                    self.containerView.layer.cornerRadius = 0.0
                case .Expanded:
                    self.containerView.layer.cornerRadius = 12.0
                }
            }
            cornerAnimator.pausesOnCompletion = true
            runningAnimators.append(cornerAnimator)
            
            let transformAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) { [unowned self] in
                switch state {
                case .Collapsed:
                    self.inLabel.transform = self.outLabelScale.concatenating(self.outLabelTranslation)
                    self.outLabel.transform = CGAffineTransform.identity
                case .Expanded:
                    self.inLabel.transform = CGAffineTransform.identity
                    self.outLabel.transform = self.inLabelScale.concatenating(self.inLabelTranslation)
                }
            }
            transformAnimator.pausesOnCompletion = true
            runningAnimators.append(transformAnimator)
            
            switch state {
            case .Collapsed:
                let inLabelAlpahAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) { [unowned self] in
                    self.inLabel.alpha = 0.0
                }
                inLabelAlpahAnimator.scrubsLinearly = false
                inLabelAlpahAnimator.pausesOnCompletion = true
                runningAnimators.append(inLabelAlpahAnimator)
                
                let outLabelAlphaAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) { [unowned self] in
                    self.outLabel.alpha = 1.0
                }
                outLabelAlphaAnimator.scrubsLinearly = false
                outLabelAlphaAnimator.pausesOnCompletion = true
                runningAnimators.append(outLabelAlphaAnimator)
            
            case .Expanded:
                let inLabelAlpahAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) { [unowned self] in
                    self.inLabel.alpha = 1.0
                }
                inLabelAlpahAnimator.scrubsLinearly = false
                inLabelAlpahAnimator.pausesOnCompletion = true
                runningAnimators.append(inLabelAlpahAnimator)
                
                let outLabelAlphaAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) { [unowned self] in
                    self.outLabel.alpha = 0.0
                }
                outLabelAlphaAnimator.scrubsLinearly = false
                outLabelAlphaAnimator.pausesOnCompletion = true
                runningAnimators.append(outLabelAlphaAnimator)
            }
        
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
