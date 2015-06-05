//
//  BibleVerseViewMetadata.swift
//  Icthus
//
//  Created by Matthew Lorentz on 5/22/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

import Foundation

class BibleTextViewMetadata: NSObject {
    var frame: CGRect
    var textRange: NSRange
    var chapters: NSMutableArray
    var verses: NSMutableArray
    var lineRanges: Array<NSRange>
    
    init(frame: CGRect, textRange: NSRange, lineRanges: Array<NSRange>) {
        self.frame = frame
        self.textRange = textRange
        self.lineRanges = lineRanges
        self.chapters = NSMutableArray()
        self.verses = NSMutableArray()
    }
}
