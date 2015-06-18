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
    
    func containsLocation(location: BookLocation) -> Bool {
        return getLineNumberForLocation(location) != nil
    }
    
    func getLineNumberForLocation(location: BookLocation) -> Int? {
        for var i = 0; i < self.chapters.count; i++ {
            if let chaptersForLine = self.chapters[i] as? NSMutableArray,
                let versesForLine = self.verses[i] as? NSMutableArray {
                    for var j = 0; j < versesForLine.count; j++ {
                        if let chapterNumber = (chaptersForLine[j] as? String)?.toInt(),
                            let verseNumber = (versesForLine[j] as? String)?.toInt() {
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
