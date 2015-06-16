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
    
//    var chapterRange: NSRange {
//        get {
//            var firstChapter: Int? = nil
//            var lastChapter: Int? = nil
//            for list in chapters {
//                if let chapterList = list as? NSMutableArray {
//                    for chapter in chapterList {
//                        if let intChapter = (chapter as? String)?.toInt() {
//                            if firstChapter == nil {
//                                firstChapter = intChapter
//                                lastChapter = intChapter
//                            }
//                            if intChapter > lastChapter {
//                                lastChapter = intChapter
//                            }
//                        }
//                    }
//                }
//            }
//            
//            if let actualFirstChapter = firstChapter, let actualLastChapter = lastChapter {
//                return NSMakeRange(actualFirstChapter, actualLastChapter - actualFirstChapter)
//            } else {
//                return NSRange(location: 0, length: 0)
//            }
//        }
//    }
//    
//    var verseRange: NSRange {
//        get {
//            if let firstVerse = (verses.firstObject?.firstObject as? String)?.toInt(),
//                let lastVerse = (verses.lastObject?.lastObject as? String)?.toInt() {
//                    return NSMakeRange(firstVerse, lastVerse - firstVerse)
//            }
//            return NSRange(location: 0, length: 0)
//        }
//    }
    
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
