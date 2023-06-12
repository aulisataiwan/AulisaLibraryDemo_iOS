//
//  UIColor_Extension.swift
//  GA
//
//  Created by Li Yun Jung on 2017/8/14.
//  Copyright © 2017年 Li Yun Jung. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    public convenience init(withIntRGB red: Int, green: Int, blue: Int, alpha: CGFloat) {
        
        let redPart: CGFloat = CGFloat(red) / 255
        let greenPart: CGFloat = CGFloat(green) / 255
        let bluePart: CGFloat = CGFloat(blue) / 255
        
        self.init(red: redPart, green: greenPart, blue: bluePart, alpha: alpha)
    }
    
    ///Example : UIColor(0xffffff)
    public convenience init (_ rgbValue:UInt32, alpha:Double=1.0){
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        self.init(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    var reverse : UIColor{
        
        let r = 1.0 - self.redValue
        let g = 1.0 - self.greenValue
        let b = 1.0 - self.blueValue
        return UIColor(red:r, green:g, blue:b, alpha:self.alphaValue)
    }
    
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
    

    static let bpmColor = UIColor(withIntRGB: 170, green: 205, blue: 6, alpha: 1.0)
    static let paColor = UIColor(withIntRGB: 160, green: 217, blue: 246, alpha: 1.0)
}
