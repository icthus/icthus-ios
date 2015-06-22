//
//  BibleTextViewMetadataGenerator.swift
//  Icthus
//
//  Created by Matthew Lorentz on 6/3/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

class BibleTextViewMetadataGenerator: NSObject {
    
    static func generateWithRecommendedSize(size: CGSize, book: Book) -> (Array<BibleTextViewMetadata>) {
        let parser = BibleMarkupParser()
        var remainingText = parser.displayStringFromMarkup(book.text) as NSString
        var globalLocation = 0
        var sizingFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        var fittingFrame: CGRect
        var sizingView: BibleTextView
        var metadata: Array<BibleTextViewMetadata> = []
        var visibleTextRange: NSRange
        
        while remainingText.length > 0 {
            // Create a view and figure out how much text it will hold
            sizingView = BibleTextView.createTextViewWithText(remainingText as String, frame: sizingFrame)
            (fittingFrame, visibleTextRange) = BibleTextView.truncateAndResizeTextView(sizingView)
            
            // Figure out the range of characters for each line
            let lineRanges = sizingView.getLineRanges()
            let lineOrigins = sizingView.getLineOrigins()
            
            metadata.append(
                BibleTextViewMetadata(
                    frame: CGRect(origin: sizingFrame.origin, size: fittingFrame.size),
                    textRange: NSMakeRange(globalLocation, visibleTextRange.length),
                    lineRanges: lineRanges,
                    lineOrigins: lineOrigins
                )
            )
            
            remainingText = remainingText.stringByReplacingCharactersInRange(NSMakeRange(0, visibleTextRange.length), withString: "")
            globalLocation += visibleTextRange.length
            sizingFrame = CGRectOffset(sizingFrame, 0.0, fittingFrame.height)
        }
        
        parser.addChapterAndVerseNumbersToFrameData(metadata, fromMarkup: book.text)
        return metadata
    }
    

    
}
