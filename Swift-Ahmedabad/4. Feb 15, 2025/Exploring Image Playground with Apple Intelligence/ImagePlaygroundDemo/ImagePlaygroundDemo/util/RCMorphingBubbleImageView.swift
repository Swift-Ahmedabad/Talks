//
//  RCMorphingBubbleImageView.swift
//  ImagePlaygroundDemo
//
//  Created by Rahul Chandnani on 15/02/25.
//


import UIKit

class RCMorphingBubbleImageView: UIImageView {
    
    private var isAllowedRotating = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.contentMode = .scaleAspectFill
    }
    
    internal func startMorphingAnimation(with image:UIImage, isAllowedRotating:Bool){
        self.image = image
        self.isAllowedRotating = isAllowedRotating
        
        startFloatingAnimation()
        startMorphingAnimation()
        if isAllowedRotating{
            startRotationAnimation()
        }
    }
    
    /// Floating effect (subtle movement but keeping the center fixed)
    private func startFloatingAnimation() {
        let floatAnimation = CAKeyframeAnimation(keyPath: "transform.translation")
        floatAnimation.values = [
            NSValue(cgSize: CGSize(width: 0, height: 0)),
            NSValue(cgSize: CGSize(width: 2, height: -3)),
            NSValue(cgSize: CGSize(width: -2, height: 3)),
            NSValue(cgSize: CGSize(width: 3, height: 2)),
            NSValue(cgSize: CGSize(width: -3, height: -2)),
            NSValue(cgSize: CGSize(width: 0, height: 0))
        ]
        floatAnimation.duration = 4.0
        floatAnimation.repeatCount = .infinity
        floatAnimation.autoreverses = true
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        self.layer.add(floatAnimation, forKey: "floating")
    }
    
    /// Morphing effect (subtle stretch & squish)
    private func startMorphingAnimation() {
        UIView.animateKeyframes(withDuration: 5.0, delay: 0, options: [.repeat, .autoreverse]) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                self.transform = CGAffineTransform(scaleX: 1.03, y: 0.97)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.transform = CGAffineTransform(scaleX: 0.97, y: 1.03)
            }
            UIView.addKeyframe(withRelativeStartTime: 1, relativeDuration: 0.5) {
                self.transform = CGAffineTransform(scaleX: 1.02, y: 0.98)
            }
            UIView.addKeyframe(withRelativeStartTime: 1.5, relativeDuration: 0.5) {
                self.transform = CGAffineTransform.identity
            }
        }
    }
    
    /// Slow rotation effect (spinning smoothly)
    private func startRotationAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = CGFloat.pi * 2  // Full rotation
        rotation.duration = 10.0           // Slow rotation over 10 seconds
        rotation.repeatCount = .infinity
        rotation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        self.layer.add(rotation, forKey: "rotation")
    }
}
