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
        let verseView = createVerseView()
        addSubview(verseView)
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
    
    func getOffsetForLocation(location: BookLocation) -> CGPoint? {
        let lineNumber = metadata.getLineNumberForLocation(location)
        if let actualLineNumber = lineNumber {
            let lineRange = metadata.lineRanges[actualLineNumber]
            let optionalStartOfRange = positionFromPosition(beginningOfDocument, offset: lineRange.location)
            guard let startOfRange = optionalStartOfRange else { return nil }
            let optionalEndOfRange = positionFromPosition(startOfRange, offset: lineRange.length)
            guard let endOfRange = optionalEndOfRange else { return nil }
            
            let optionalTextRange = textRangeFromPosition(startOfRange, toPosition: endOfRange)
            guard let textRange = optionalTextRange else { return nil }
            let boundingRect = firstRectForRange(textRange)
            let viewOrigin = frame.origin
            return CGPoint(x: viewOrigin.x + boundingRect.origin.x, y: viewOrigin.y + boundingRect.origin.y)
        }
        
        return nil
    }
    
    private func createVerseView() -> BibleVerseView {
        let lineHeight: CGFloat = frame.height / CGFloat(metadata.lineOrigins.count)
        let origins = metadata.lineOrigins.map { NSValue(CGPoint: $0) }
        return BibleVerseView(contentFrame: frame, verses: metadata.verses as [AnyObject], chapters: metadata.chapters as [AnyObject], lineOrigins: origins, andLineHeight: lineHeight)
    }
    
}

extension UITextView {
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
}