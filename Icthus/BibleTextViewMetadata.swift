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
    
    var chapterRange: NSRange {
        get {
            if let location = chapters.firstObject?.firstObject as? Int,
                let length = chapters.lastObject?.lastObject as? Int {
                return NSMakeRange(location, length)
            }
            return NSRange(location: 0, length: 0)
        }
    }
    
    var verseRange: NSRange {
        get {
            if let location = verses.firstObject?.firstObject as? Int,
                let length = verses.lastObject?.lastObject as? Int {
                return NSMakeRange(location, length)
            }
            return NSRange(location: 0, length: 0)
        }
    }
    
    init(frame: CGRect, textRange: NSRange, lineRanges: Array<NSRange>) {
        self.frame = frame
        self.textRange = textRange
        self.lineRanges = lineRanges
        self.chapters = NSMutableArray()
        self.verses = NSMutableArray()
    }
}
