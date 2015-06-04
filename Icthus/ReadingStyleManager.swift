//
//  ReadingStyleManager.swift
//  Icthus
//
//  Created by Matthew Lorentz on 6/3/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

class ReadingStyleManager: NSObject {
    
    static func attributedStringFromString(string: String?) -> NSAttributedString {
        if let actualString = string {
            return NSAttributedString(string: actualString)
        } else {
            return NSAttributedString(string: "")
        }
    }
}
