//
//  RefreshView.swift
//  AFEA-EndProject
//
//  Created by Azzaro Mujic on 27/09/2017.
//  Copyright © 2017 Azzaro Mujic. All rights reserved.
//

import UIKit
import QuartzCore

// MARK: Refresh View Delegate Protocol
protocol RefreshViewDelegate: class {
    func refreshViewDidRefresh(refreshView: RefreshView)
}

// MARK: Refresh View

class RefreshView: UIView, UIScrollViewDelegate {
    
    weak var delegate: RefreshViewDelegate?
    var scrollView: UIScrollView?
    var refreshing: Bool = false
    var progress: CGFloat = 0.0
    
    var isRefreshing = false
    
    var endAnimationInProgress: Bool = false
    
    let circleView: UIView
    
    init(frame: CGRect, scrollView: UIScrollView) {
        self.circleView = UIView(frame: CGRect(x: frame.width/2 - 10, y: frame.height/2 - 9, width: 21, height: 21))
        self.circleView.backgroundColor = UIColor.darkSkyBlue
        self.circleView.layer.cornerRadius = 10
        self.circleView.layer.masksToBounds = true
        
        super.init(frame: frame)
        
        self.addSubview(self.circleView)
        self.backgroundColor = UIColor.silver
        self.scrollView = scrollView
        self.clipsToBounds = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Scroll View Delegate methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offsetY = CGFloat( max(-(scrollView.contentOffset.y + scrollView.contentInset.top), 0.0))
        offsetY = min(offsetY, self.frame.height)

        self.progress = min(max(offsetY / frame.size.height, 0.0), 1.0)
        
        if !isRefreshing {
            redrawFromProgress(self.progress)
            self.transform = CGAffineTransform(translationX: 0, y: offsetY)
            self.circleView.transform = CGAffineTransform(scaleX: self.progress, y: self.progress)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !isRefreshing && self.progress >= 1.0 {
            delegate?.refreshViewDidRefresh(refreshView: self)
            beginRefreshing()
        }
    }
    
    // MARK: animate the Refresh View
    
    func beginRefreshing() {
        isRefreshing = true
        
        UIView.animate(withDuration: 0.3, animations: {
            var newInsets = self.scrollView!.contentInset
            newInsets.top += self.frame.size.height
            self.scrollView!.contentInset = newInsets
            self.transform = CGAffineTransform(translationX: 0, y: newInsets.top)
        })
        
        //do animation
        animateMainCircle()
    }
    

    func animateMainCircle() {
        UIView.animate(withDuration: 1.2, animations: {
            self.circleView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (_) in

        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1, execute: {
            if self.isRefreshing {
                self.animateLoading()
                UIView.animate(withDuration: 0.9, delay: 0, animations: {
                    self.circleView.transform = .identity
                }) { (_) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        if self.isRefreshing {
                            self.animateMainCircle()
                        }
                    })
                }
            }
        })
        
    }
    
    func animateLoading() {

        let newCircleView = UIView()
        newCircleView.frame.size.width = 21 * self.circleView.transform.a / 1.1
        newCircleView.frame.size.height = 21 * self.circleView.transform.d / 1.1
        newCircleView.layer.cornerRadius = newCircleView.frame.width/2
        newCircleView.layer.masksToBounds = true
        newCircleView.backgroundColor = UIColor.clear
        newCircleView.layer.borderColor = UIColor.darkSkyBlue.cgColor
        newCircleView.layer.borderWidth = 1.5
        
        self.addSubview(newCircleView)
        self.sendSubview(toBack: newCircleView)
        newCircleView.center = self.circleView.center
        
        UIView.animate(withDuration: 0.8, delay: 0, animations: {
            newCircleView.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
            newCircleView.alpha = 0
        }) { (_) in
            newCircleView.removeFromSuperview()
        }
        
    }
    
    func endRefreshing() {
        
       
        endAnimationInProgress = true
        
        UIView.animate(withDuration: 1.2, animations: {
            self.circleView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (_) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.circleView.transform = CGAffineTransform(scaleX: 30, y: 30)
                }) { (finished) -> Void in
                    self.endAnimationInProgress = false
                    self.isRefreshing = false
                }
                
                UIView.animate(withDuration: 0.3, delay: 0.05, options: .curveEaseInOut ,animations: {
                    var newInsets = self.scrollView!.contentInset
                    newInsets.top -= self.frame.size.height
                    self.scrollView!.contentInset = .zero
                    self.transform = CGAffineTransform(translationX: 0, y: newInsets.top)
                }, completion: {_ in
                    //finished
                })
            })
        }
        
        
    }
    
    func redrawFromProgress(_ progress: CGFloat) {
        if (!endAnimationInProgress) {
            
        }
    }
    
}
