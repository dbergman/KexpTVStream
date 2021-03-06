//
//  UIViewController+ActivityIndicator.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 5/2/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit

extension UIViewController {
    private enum Style {
        static let activityIndicatorSize = CGFloat(50)
    }
    
    func showLoadingIndicator() {
        let loadingOverlayView = UIView()
        loadingOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        loadingOverlayView.tag = 666
        view.addPinnedSubview(loadingOverlayView)
        
        let activityIndicator = CustomActivityIndicator()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlayView.addSubview(activityIndicator)
 
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loadingOverlayView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingOverlayView.centerYAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: Style.activityIndicatorSize),
            activityIndicator.widthAnchor.constraint(equalToConstant: Style.activityIndicatorSize)
        ])

        activityIndicator.showActivityLoading()
     }

    func removeLoadingIndicator() {
        view.subviews.forEach {
            if $0.tag == 666 {
                $0.removeFromSuperview()
            }
        }
    }
}

