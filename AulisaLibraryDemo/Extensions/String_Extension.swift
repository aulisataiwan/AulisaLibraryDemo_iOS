//
//  String_Extension.swift
//  GA
//
//  Created by Li Yun Jung on 2017/8/9.
//  Copyright © 2017年 Li Yun Jung. All rights reserved.
//

import Foundation



extension String {
    
    func startsWith(string: String) -> Bool {
        
        guard let range = range(of : string, options:[.anchored, .caseInsensitive]) else {
            return false
        }
        return range.lowerBound == startIndex
    }
    
    var hex2Bytes: [CUnsignedChar] {
        
        let hexa = Array(self)
        var result : [CUnsignedChar] = []
        
        for i in stride(from: 0, to: hexa.count, by: 2){
            if i == hexa.count - 1{
                break
            }
            if let char = CUnsignedChar(String(hexa[i..<(i+2)]), radix: 16){
                result.append(char)
            }
        }
        return result
    }
    
    
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }    
    
}
