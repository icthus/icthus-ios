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
        var text = ReadingStyleManager.attributedStringFromString(displayString as String)
        self.attributedText = text
        self.editable = false
        self.bounces = false
        self.scrollEnabled = false
        self.layer.borderWidth = 1
        self.textContainerInset = UIEdgeInsetsZero;
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
