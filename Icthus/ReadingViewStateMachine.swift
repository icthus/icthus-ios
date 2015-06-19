//
//  ReadingViewStateMachine.swift
//  Icthus
//
//  Created by Matthew Lorentz on 6/19/15.
//  Copyright © 2015 Matthew Lorentz. All rights reserved.
//

import Foundation

enum ReadingViewStateMachine {
    case statusQuo
    case sizeChanged(ReadingViewController, Book, CGSize)
    case bookChanged(ReadingViewController, Book, BookLocation?)
    case translationChanged(ReadingViewController, Translation)
    case locationChanged(ReadingViewController, BookLocation)
    case needsNewMetadata(ReadingViewController, Book, CGSize, BookLocation?)
    case needsLatestLocation(ReadingViewController, Book, BookLocation?, [BibleTextViewMetadata])
    case needsTextViewsCleared(ReadingViewController, Book, BookLocation, [BibleTextViewMetadata])
    case needsContentOffset(ReadingViewController, Book, BookLocation, [BibleTextViewMetadata])
    case needsTextViewsCreated(ReadingViewController, [BibleTextViewMetadata])
    
    func continuation() {
        switch self {
            
        case .statusQuo:
            return
            
        case .sizeChanged(let vc, let book, let newSize):
            vc.scrollView.frame.size = newSize
            ReadingViewStateMachine.needsNewMetadata(vc, book, newSize, nil).continuation()
            
        case .bookChanged(let vc, let book, let location):
            ReadingViewStateMachine.needsNewMetadata(vc, book, vc.view.frame.size, location).continuation()
            
        case .translationChanged(let vc, let translation):
            if let actualBook = vc.currentBook {
                let newBook = translation.getBookWithCode(actualBook.code)
                vc._book = newBook // TODO: Try to remove this
                ReadingViewStateMachine.bookChanged(vc, newBook, nil).continuation()
            }
            
        case .locationChanged(let vc, let location):
            if vc.currentBook?.objectID == location.book.objectID {
                ReadingViewStateMachine.needsContentOffset(vc, location.book, location, vc.textViewMetadata).continuation()
            } else {
                vc._book = location.book
                ReadingViewStateMachine.bookChanged(vc, location.book, location).continuation()
            }
            
        case .needsNewMetadata(let vc, let book, let size, let location):
            var metadata : [BibleTextViewMetadata]
            if vc.needsNewMetadata() {
                metadata = BibleTextViewMetadataGenerator.generateWithRecommendedSize(
                    size,
                    book: book
                )
                vc.generatedMetadataWithSize(size, book: book)
            } else {
                metadata = vc.textViewMetadata
            }
            vc.textViewMetadata = metadata
            ReadingViewStateMachine.needsLatestLocation(vc, book, location, metadata).continuation()
            
        case .needsLatestLocation(let vc, let book, var location, let metadata):
            if location == nil {
                location = book.getLocation()
            }
            ReadingViewStateMachine.needsTextViewsCleared(vc, book, location!, metadata).continuation()
            
        case .needsTextViewsCleared(let vc, let book, let location, let metadata):
            vc.clearTextViews()
            vc.textViews = Array<BibleTextView?>(count: metadata.count, repeatedValue: nil)
            ReadingViewStateMachine.needsContentOffset(vc, book, location, metadata).continuation()
            
        case .needsContentOffset(let vc, let book, let location, let metadata):
            let contentHeight = metadata.reduce(vc.scrollView.frame.origin.y) { $0 + $1.frame.size.height }
            vc.scrollView.contentSize = CGSizeMake(vc.view.frame.size.width, contentHeight)
            
            let contentOffset = ReadingViewController.getOffsetForLocation(
                location,
                contentSize: vc.scrollView.contentSize,
                viewport: vc.scrollView.frame.size,
                metadata: metadata
            )
            
            vc.scrollView.contentOffset = contentOffset
            ReadingViewStateMachine.needsTextViewsCreated(vc, metadata).continuation()
            
        case .needsTextViewsCreated(let vc, let metadata):
            vc.addAndRemoveTextViews()
            ReadingViewStateMachine.statusQuo.continuation()
        }
    }
}