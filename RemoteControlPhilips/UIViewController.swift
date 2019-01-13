//
//  UIViewController.swift
//  RemoteControlPhilips
//
//  Created by Daian Aiziatov on 13/01/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func startLoadingView() {
        
        let loadingView = UIView(frame: UIApplication.shared.keyWindow!.bounds)
        loadingView.tag = 100
        loadingView.addBlurEffect()
        
        let loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.center = UIApplication.shared.keyWindow!.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        loadingView.addSubview(loadingIndicator)
        
        DispatchQueue.main.async {
            self.view.addSubview(loadingView)
        }
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.viewWithTag(100)?.alpha = 0
            }, completion: { _ in
                self.view.viewWithTag(100)?.removeFromSuperview()
            })
        }
    }

}
