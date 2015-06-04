//
//  BibleTextViewMetadataGenerator.swift
//  Icthus
//
//  Created by Matthew Lorentz on 6/3/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

class BibleTextViewMetadataGenerator: NSObject {
    
    static func generateWithFrame(frame: CGRect, book: Book) -> (Array<BibleTextViewMetadata>) {
        let attributedText = ReadingStyleManager.attributedStringFromString(book.text)
        //let sizingView = UITextView(frame: self.view.frame)
        
//        sizingView.attributedText = attributedText
        var textRange = NSMakeRange(0, attributedText.length)
        
        var metadatum = BibleTextViewMetadata(frame: frame, textRange: textRange, chapters: [], verses: [])
        return [metadatum]
    }
    

}
