//
//  UIView_Extension.swift
//  GA
//
//  Created by Li Yun Jung on 2017/8/11.
//  Copyright © 2017年 Li Yun Jung. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    
    func getLabelsInView() -> [UILabel] {
        
        var results = [UILabel]()
        for subview in self.subviews as [UIView] {
            if let labelView = subview as? UILabel {
                results += [labelView]
            } else {
                results += subview.getLabelsInView()
            }
        }
        return results
    }
    
    func getButtonsInView() -> [UIButton] {
        
        var results = [UIButton]()
        for subview in self.subviews as [UIView] {
            if let buttonView = subview as? UIButton {
                results += [buttonView]
            } else {
                results += subview.getButtonsInView()
            }
        }
        return results
    }
    
    func getImageViewsInView() -> [UIImageView] {
        
        var results = [UIImageView]()
        for subview in self.subviews as [UIView] {
            if let imageView = subview as? UIImageView {
                results += [imageView]
            } else {
                results += subview.getImageViewsInView()
            }
        }
        return results
    }
    
    func getAllParentView() -> [UIView]{
        
        var result : [UIView]  = []
        if let superView = self.superview {
            result.append(superView)
            result += superView.getAllParentView()
        }
        return result
    }
    
}

extension UIView {
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0,y: 0, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width,y: 0, width:width, height:self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0, y:self.frame.size.height - width, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0, y:0, width:width, height:self.frame.size.height)
        self.layer.addSublayer(border)
    }
}
