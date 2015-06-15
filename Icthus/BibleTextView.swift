//
//  BibleTextView.swift
//  Icthus
//
//  Created by Matthew Lorentz on 5/22/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

class BibleTextView: UITextView {
    let metadata: BibleTextViewMetadata
    
    init(metadata: BibleTextViewMetadata, book: Book) {
        self.metadata = metadata
        super.init(frame: metadata.frame, textContainer:nil)
        
        var displayString: NSString = BibleMarkupParser().displayStringFromMarkup(book.text)
        displayString = displayString.substringWithRange(metadata.textRange)
        BibleTextView.configureTextView(self, text: displayString as String)
    }
    
    static func configureTextView(textView: UITextView, text: String) {
        let attributedText = ReadingStyleManager.attributedStringFromString(text)
        textView.attributedText = attributedText
        textView.editable = false
        textView.bounces = false
        textView.scrollEnabled = false
        textView.textContainerInset = UIEdgeInsetsZero;
    }
    
    static func truncateAndResizeTextView(textView: UITextView) -> (CGRect, NSRange) {
        if let visibleTextRange = visibleRangeOfTextInTextView(textView) {
            let visibleNSRange = NSMakeRange(0, visibleTextRange.length)
            let textThatFits = (textView.attributedText.string as NSString).substringWithRange(visibleNSRange)
            textView.attributedText = ReadingStyleManager.attributedStringFromString(textThatFits)
            textView.sizeToFit()
            return (textView.frame, visibleNSRange)
        } else {
            return (textView.frame, NSMakeRange(0, 0))
        }
    }
    
    static func createTextViewWithText(text: String, frame: CGRect) -> UITextView {
        let textView = UITextView(frame: frame, textContainer:nil)
        BibleTextView.configureTextView(textView, text: text)
        return textView
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func visibleRangeOfTextInTextView(textView: UITextView) -> NSRange? {
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
    
    func getOffsetForLocation(location: BookLocation, textView: BibleTextView) -> CGPoint? {
        var i = 0
        for i; i < metadata.lineRanges.count; i++ {
            let lineRange = metadata.lineRanges[i]
            let chapters = metadata.chapters[i] as! NSMutableArray
            let verses = metadata.verses[i]as! NSMutableArray
            
            if chapters.containsObject(location.chapter) &&
                verses.containsObject(location.verse) {
                let beginningOfDocument = textView.beginningOfDocument
                let startOfRange = textView.positionFromPosition(beginningOfDocument, offset: lineRange.location)
                let endOfRange = textView.positionFromPosition(startOfRange!, offset: lineRange.length)
                let textRange = textView.textRangeFromPosition(startOfRange, toPosition: endOfRange)
                let boundingRect = textView.firstRectForRange(textRange)
                let viewOrigin = textView.frame.origin
                    return CGPoint(x: viewOrigin.x + boundingRect.origin.x, y: viewOrigin.y + boundingRect.origin.y)
            }
        }
        
        return nil
    }
}
