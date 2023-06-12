//
//  UIViewController_Extension.swift
//  GA
//
//  Created by Li Yun Jung on 2017/8/2.
//  Copyright © 2017年 Li Yun Jung. All rights reserved.
//

import Foundation
import UIKit

//This is extension for  hiding keyboard when touch outside textfield  
extension UIViewController{
    func hideKeyboard(){
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        
        view.endEditing(true)
    }
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
