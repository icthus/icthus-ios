//
//  BibleVerseViewMetadata.swift
//  Icthus
//
//  Created by Matthew Lorentz on 5/22/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

import Foundation

class BibleTextViewMetadata {
    var frame: CGRect
    var textRange: NSRange
    var chapters: Array<Array<Int>>
    var verses: Array<Array<Int>>
    
    init(frame: CGRect, textRange: NSRange, chapters: Array<Array<Int>>, verses: Array<Array<Int>>) {
        self.frame = frame
        self.textRange = textRange
        self.chapters = chapters
        self.verses = verses
    }
}
