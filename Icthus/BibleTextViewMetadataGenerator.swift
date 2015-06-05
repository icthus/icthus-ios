//
//  BibleTextViewMetadataGenerator.swift
//  Icthus
//
//  Created by Matthew Lorentz on 6/3/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

class BibleTextViewMetadataGenerator: NSObject {
    
    static func generateWithFrame(frame: CGRect, book: Book) -> (Array<BibleTextViewMetadata>) {
        let parser = BibleMarkupParser()
        let text = parser.displayStringFromMarkup(book.text)
        let remainingText = NSMutableAttributedString(attributedString:ReadingStyleManager.attributedStringFromString(text))
        var globalLocation = 0
        var sizingView = UITextView(frame: frame)
        var metadata : Array<BibleTextViewMetadata> = []
        var sizingFrame = frame
        
        while remainingText.length > 0 {
            // Figure out how much text fits in this frame
            sizingView.attributedText = remainingText
            let optionalVisibleTextRange = visibleRangeOfTextInTextView(sizingView)
            
            if let visibleTextRange = optionalVisibleTextRange {
                // recreate the sizing view with just the text that will fit
                sizingView = UITextView(frame: sizingFrame)
                sizingView.attributedText = remainingText
                
                // Loop through each line and compute the range
                var lineRanges = Array<NSRange>()
                var indexOfFirstGlyph = 0
                while indexOfFirstGlyph < visibleTextRange.location + visibleTextRange.length {
                    var lineRange = NSRange()
                    sizingView.layoutManager.lineFragmentRectForGlyphAtIndex(indexOfFirstGlyph, effectiveRange: &lineRange)
                    lineRanges.append(lineRange)
                    indexOfFirstGlyph += lineRange.length
                }
                
                // create the metada object and prepare the remainingText and sizingFrame for the next iteration.
                metadata.append(
                    BibleTextViewMetadata(
                        frame: sizingFrame,
                        textRange: NSMakeRange(globalLocation, visibleTextRange.length),
                        lineRanges: lineRanges
                    )
                )
                
                remainingText.mutableString.replaceCharactersInRange(NSMakeRange(0, visibleTextRange.length), withString: "")
                globalLocation += visibleTextRange.length
                sizingFrame = CGRectOffset(sizingFrame, 0.0, sizingFrame.height)
            } else {
                println("Warning: could not get visibleTextRange for sizingView while generating BibleTextViewMetadata.")
                break;
            }
        }
        
        parser.addChapterAndVerseNumbersToFrameData(metadata, fromMarkup: book.text)
        return metadata
    }
    

    private static func visibleRangeOfTextInTextView(textView: UITextView) -> NSRange? {
        // I was having trouble with the visibleStartRange being nil, so I changed this code to assume that the first character in the textView will be visible in the top-left of the view.
        let bounds = textView.bounds
        let origin = CGPoint(x: 10, y: 10) // default UITextView margins
//        let visibleStartRange = textView.characterRangeAtPoint(origin)
        let visibleEndRange = textView.characterRangeAtPoint(CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds)))
        
//        if let visibleStart = visibleStartRange?.start, let visibleEnd = visibleEndRange?.end {
        if let visibleEnd = visibleEndRange?.end {
//            let absoluteStart = textView.offsetFromPosition(textView.beginningOfDocument, toPosition: visibleStart)
            let absoluteEnd = textView.offsetFromPosition(textView.beginningOfDocument, toPosition: visibleEnd)
//            return NSMakeRange(absoluteStart, absoluteEnd)
            return NSMakeRange(0, absoluteEnd)
        } else {
            return nil
        }
    }
    
}
