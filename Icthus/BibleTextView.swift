//
//  BibleTextView.swift
//  Icthus
//
//  Created by Matthew Lorentz on 5/22/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

class BibleTextView: UITextView {
    let metadata: BibleTextViewMetadata?
    
    //////////////////////////////////////////////////
    // MARK: Initializers
    //////////////////////////////////////////////////
    
    init(metadata: BibleTextViewMetadata, book: Book) {
        self.metadata = metadata
        super.init(frame: metadata.frame, textContainer:nil)
        
        var displayString: NSString = BibleMarkupParser().displayStringFromMarkup(book.text)
        displayString = displayString.substringWithRange(metadata.textRange)
        BibleTextView.configureTextView(self, text: displayString as String)
        if let verseView = createVerseView() {
            addSubview(verseView)
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        metadata = nil
        super.init(frame: frame, textContainer: textContainer)
        BibleTextView.configureTextView(self, text: "")
    }
    
    required init(coder aDecoder: NSCoder) {
        metadata = nil
        super.init(coder: aDecoder)
        BibleTextView.configureTextView(self, text: "")
    }
    
    //////////////////////////////////////////////////
    // MARK: Configuring and Sizing
    //////////////////////////////////////////////////
    
    static func createTextViewWithText(text: String, frame: CGRect) -> BibleTextView {
        let textView = BibleTextView(frame: frame, textContainer:nil)
        BibleTextView.configureTextView(textView, text: text)
        return textView
    }
    
    static func configureTextView(textView: UITextView, text: String) {
        let attributedText = ReadingStyleManager.attributedStringFromString(text)
        textView.editable = false
        textView.bounces = false
        textView.scrollEnabled = false
        textView.clipsToBounds = false
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.attributedText = attributedText
        textView.textContainerInset = ReadingStyleManager.readingViewInset()
    }
    
    static func truncateAndResizeTextView(textView: UITextView) -> (CGRect, NSRange) {
        if let visibleTextRange = visibleRangeOfTextInTextView(textView) {
            let visibleNSRange = NSMakeRange(0, visibleTextRange.length)
            let textThatFits = (textView.attributedText.string as NSString).substringWithRange(visibleNSRange)
            textView.attributedText = ReadingStyleManager.attributedStringFromString(textThatFits)
            let originalFrame = textView.frame
            textView.sizeToFit()
            textView.frame = CGRect(origin: originalFrame.origin, size: CGSize(width: originalFrame.size.width, height: textView.frame.size.height))
            return (textView.frame, visibleNSRange)
        } else {
            return (textView.frame, NSMakeRange(0, 0))
        }
    }

    //////////////////////////////////////////////////
    // MARK: Layout Information
    //////////////////////////////////////////////////
    
    
    func getOffsetForLocation(location: BookLocation) -> CGPoint? {
        guard let metadata = metadata else { return nil }
        
        if let lineNumber = metadata.getLineNumberForLocation(location) {
            return metadata.lineOrigins[lineNumber]
        }
        
        return nil
    }
    
    func getLineRanges() -> [NSRange] {
        var lineRanges = Array<NSRange>()
        var indexOfFirstGlyphOnLine = 0
        while indexOfFirstGlyphOnLine < attributedText.length {
            var lineRange = NSRange()
            layoutManager.lineFragmentRectForGlyphAtIndex(indexOfFirstGlyphOnLine, effectiveRange: &lineRange)
            lineRanges.append(lineRange)
            indexOfFirstGlyphOnLine += lineRange.length
        }
        return lineRanges
    }
    
    func getLineOrigins() -> [CGPoint] {
        var origins = [CGPoint]()
        var indexOfFirstGlyphOnLine = 0
        while indexOfFirstGlyphOnLine < attributedText.length {
            var lineRange = NSRange()
            let boundingRect = layoutManager.lineFragmentRectForGlyphAtIndex(indexOfFirstGlyphOnLine, effectiveRange: &lineRange)
            origins.append(boundingRect.origin)
            indexOfFirstGlyphOnLine += lineRange.length
        }
        return origins
    }
    
    //////////////////////////////////////////////////
    // MARK: Helper Functions
    //////////////////////////////////////////////////
    
    private func createVerseView() -> BibleVerseView? {
        guard let metadata = metadata else { return nil }
        
        let lineHeight: CGFloat = frame.height / CGFloat(metadata.lineOrigins.count)
        let origins = metadata.lineOrigins.map { NSValue(CGPoint: $0) }
        return BibleVerseView(contentFrame: frame, verses: metadata.verses as [AnyObject], chapters: metadata.chapters as [AnyObject], lineOrigins: origins, andLineHeight: lineHeight)
    }
    

    static func visibleRangeOfTextInTextView(textView: UITextView) -> NSRange? {
        // I was having trouble with the visibleStartRange being nil, so I changed this code to assume that the first character in the textView will be visible in the top-left of the view.
        let bounds = textView.bounds
        let origin = CGPoint(x: 10, y: 10) // default UITextView margins
//        let visibleStartRange = textView.characterRangeAtPoint(origin)
        let visibleEndRange = textView.characterRangeAtPoint(CGPointMake(CGRectGetMaxX(textView.frame), CGRectGetMaxY(textView.frame)))
        
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