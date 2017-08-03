//
//  RoundedPaddingLabel.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/3/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import UIKit

class RoundedPaddingLabel: PaddingLabel {
    private var corners: UIRectCorner = []
    private var cornersRadius: CGFloat = 0
    
    func setRoundedCorners(corners: UIRectCorner, radius: CGFloat) {
        self.corners = corners
        self.cornersRadius = radius
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.corners != [] {
            setRoundedCorners(corners: self.corners, radius: self.cornersRadius)
        }
    }
}
