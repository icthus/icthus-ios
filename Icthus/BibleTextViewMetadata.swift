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
    var lineOrigins: Array<CGPoint>
    
    init(frame: CGRect, textRange: NSRange, lineRanges: Array<NSRange>, lineOrigins: Array<CGPoint>) {
        self.frame = frame
        self.textRange = textRange
        self.chapters = NSMutableArray()
        self.verses = NSMutableArray()
        self.lineRanges = lineRanges
        self.lineOrigins = lineOrigins
    }
    
    func containsLocation(location: BookLocation) -> Bool {
        return getLineNumberForLocation(location) != nil
    }
    
    func getLineNumberForLocation(location: BookLocation) -> Int? {
        for var i = 0; i < self.chapters.count; i++ {
            if let chaptersForLine = self.chapters[i] as? NSMutableArray,
                let versesForLine = self.verses[i] as? NSMutableArray {
                    for var j = 0; j < versesForLine.count; j++ {
                        if let chapterNumber = Int((chaptersForLine[j] as? String)!),
                            let verseNumber = Int(((versesForLine[j] as? String))!) {
                                if chapterNumber == location.chapter && verseNumber == location.verse {
                                    return i
                                }
                        }
                    }
            }
        }
        return nil
    }
}
