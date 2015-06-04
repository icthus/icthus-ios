//
//  ReadingScrollView.swift
//  Icthus
//
//  Created by Matthew Lorentz on 5/22/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

import Foundation

class ReadingScrollView: UIScrollView {
    private var textViewMetadata: Array<BibleTextViewMetadata> = []
    
    override func awakeFromNib() {
    
    }
    
    func redraw(metadata: Array<BibleTextViewMetadata>, book: Book) {
        textViewMetadata = metadata
        let metadatum = metadata[0]
        
        var text = ReadingStyleManager.attributedStringFromString(BibleMarkupParser().displayStringFromMarkup(book.text))
        let textView = UITextView(frame: metadatum.frame)
        textView.attributedText = text
        textView.editable = false
        self.addSubview(textView)
    }
}