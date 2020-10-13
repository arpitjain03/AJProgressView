//
//  ViewController.swift
//  AJProgressView
//
//  Created by Arpit Jain on 22/09/17.
//  Copyright © 2017 Arpit Jain. All rights reserved.
//

import UIKit

// General object to fetch Sceeen width
let SCREENWIDTH                            =   UIScreen.main.bounds.size.width

// General object to fetch Sceeen height
let SCREENHEIGHT                           =   UIScreen.main.bounds.size.height

class AJProgressView: UIView {
    
    //MARK: - Private Properties
    //MARK: -
  
    private var objProgressView = UIView()
    private var shapeLayer = CAShapeLayer()
    private var widthProgressView: CGFloat {
        
        var width = CGFloat()
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = SCREENWIDTH * 0.1
        } else {
            if SCREENWIDTH <= 568.0 {
                width = SCREENWIDTH * 0.2
            }else {
                width = SCREENWIDTH * 0.25
            }
        }
        return width
    }
    
    //MARK: - Private Properties
    //MARK: -

    // Pass your image here which will be used for progressView
    public var imgLogo: UIImage = UIImage(named:"twitterlogo")!
   
    // Pass your color here which will be used as layer color
    public var firstColor: UIColor? = #colorLiteral(red: 0.001609396073, green: 0.6759747267, blue: 0.9307156205, alpha: 1)
   
    // Add second and third colour if you want layer to have multiple colors. It will show animated colors on progressView layer
    public var secondColor: UIColor?
    public var thirdColor: UIColor?
    
    // Use this to set the speed of progressView
    public var duration: CGFloat = 5.0
    
    // Use this to set the line width of layer
    public var lineWidth: CGFloat = 4.0
    
    // Change background color of progressView
    public var bgColor = UIColor.clear
   
    // Returns bool for animating status of progressView
    public var isAnimating : Bool?

    //MARK: - AJProgressViewSetup Private Functions
    //MARK: -

    private func setupAJProgressView() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.window?.subviews.contains(objProgressView) ?? false {
            appDelegate.window?.bringSubviewToFront(objProgressView)
            print("already there")
        }else{
            appDelegate.window?.addSubview(objProgressView)
            appDelegate.window?.bringSubviewToFront(objProgressView)
        }
        objProgressView.backgroundColor = bgColor
        objProgressView.frame = UIScreen.main.bounds
        objProgressView.layer.zPosition = 1

        self.backgroundColor = bgColor
        self.frame = UIScreen.main.bounds

        let innerView = UIView()
        innerView.frame = CGRect(x: (SCREENWIDTH - widthProgressView)/2, y: (SCREENHEIGHT - widthProgressView)/2, width: widthProgressView, height: widthProgressView)
        innerView.backgroundColor = UIColor.clear
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = firstColor?.cgColor
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 1
        shapeLayer.lineWidth = lineWidth
        
        let center = CGPoint(x: innerView.bounds.size.width / 2.0, y: innerView.bounds.size.height / 2.0)
        let radius = min(innerView.bounds.size.width, innerView.bounds.size.height)/2.0 - self.shapeLayer.lineWidth / 2.0
        let bezierPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.frame = innerView.bounds
        innerView.layer.addSublayer(shapeLayer)
        self.addSubview(innerView)
       
        let imgViewLogo = UIImageView()
        imgViewLogo.image = imgLogo
        imgViewLogo.contentMode = .scaleAspectFit
        imgViewLogo.backgroundColor = UIColor.clear
        imgViewLogo.clipsToBounds = true
        imgViewLogo.frame = CGRect(x: 0, y: 0, width: widthProgressView * 0.4, height: widthProgressView * 0.4)
        self.addSubview(imgViewLogo)
        
        imgViewLogo.center = innerView.center
        objProgressView.addSubview(self)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        objProgressView.translatesAutoresizingMaskIntoConstraints = false
        
        let xConstraint = NSLayoutConstraint(item: objProgressView, attribute: .centerX, relatedBy: .equal, toItem: appDelegate.window!, attribute: .centerX, multiplier: 1, constant: 0)
        
        let yConstraint = NSLayoutConstraint(item: objProgressView, attribute: .centerY, relatedBy: .equal, toItem: appDelegate.window!, attribute: .centerY, multiplier: 1, constant: 0)
        
        appDelegate.window?.addConstraint(xConstraint)
        appDelegate.window?.addConstraint(yConstraint)

        self.centerXAnchor.constraint(equalTo: objProgressView.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: objProgressView.centerYAnchor).isActive = true
        self.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
        self.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
    }
    
    private func animateStrokeEnd() -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.beginTime = 0
        animation.duration = CFTimeInterval(duration / 2.0)
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        return animation
    }
    
    private func animateStrokeStart() -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.beginTime = CFTimeInterval(duration / 2.0)
        animation.duration = CFTimeInterval(duration / 2.0)
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        return animation
    }
    
    private func animateRotation() -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = Float.infinity
        
        return animation
    }
    
    private func animateColors() -> CAKeyframeAnimation {
        
        let colors = configureColors()
        let animation = CAKeyframeAnimation(keyPath: "strokeColor")
        animation.duration = CFTimeInterval(duration)
        animation.keyTimes = configureKeyTimes(colors: colors)
        animation.values = colors
        animation.repeatCount = Float.infinity
        return animation
    }
    
    private func animateGroup() {
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [animateStrokeEnd(), animateStrokeStart(), animateRotation(), animateColors()]
        animationGroup.duration = CFTimeInterval(duration)
        animationGroup.fillMode = CAMediaTimingFillMode.both
        animationGroup.isRemovedOnCompletion = false
        animationGroup.repeatCount = Float.infinity
        shapeLayer.add(animationGroup, forKey: "loading")
    }
    
    private func startAnimating() {
        isAnimating = true
        animateGroup()
    }
    
    private func stopAnimating() {
        isAnimating = false
        shapeLayer.removeAllAnimations()
    }
    
    private func configureColors() -> [CGColor] {
        var colors = [CGColor]()
        if let thirdCgColor = firstColor?.cgColor {
            colors.append((thirdCgColor))
        }
        if let secondCgColor = secondColor?.cgColor {
            colors.append((secondCgColor))
        }
        if let thirdCgColor = thirdColor?.cgColor {
            colors.append((thirdCgColor))
        }        
        return colors
    }
    
    private func configureKeyTimes(colors: [CGColor]) -> [NSNumber] {
        switch colors.count {
        case 1:
            return [0]
        case 2:
            return [0, 1]
        default:
            return [0, 0.5, 1]
        }
    }

    //MARK: - Public Functions
    //MARK: -

    public func show() {
        
        self.setupAJProgressView()
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.alpha = 1.0
            self.startAnimating()
            
        }, completion: {(finished: Bool) -> Void in })
    }
    
    public func hide() {
        
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.alpha = 0.0
        }, completion: {(finished: Bool) -> Void in
            self.stopAnimating()
            self.removeFromSuperview()
        })
    }
}
