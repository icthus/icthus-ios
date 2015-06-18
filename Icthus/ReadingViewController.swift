//
//  ReadingViewController.swift
//  Icthus
//
//  Created by Matthew Lorentz on 5/22/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

import Foundation

class ReadingViewController: UIViewController, UIScrollViewDelegate {
    
    enum ReadingViewState {
        case statusQuo
        case frameChanged(ReadingViewController, Book)
        case bookChanged(ReadingViewController, Book, BookLocation?)
        case translationChanged(ReadingViewController, Translation)
        case locationChanged(ReadingViewController, BookLocation)
        case needsNewMetadata(ReadingViewController, Book, BookLocation?)
        case needsLatestLocation(ReadingViewController, Book, BookLocation?, [BibleTextViewMetadata])
        case needsTextViewsCleared(ReadingViewController, Book, BookLocation, [BibleTextViewMetadata])
        case needsContentOffset(ReadingViewController, Book, BookLocation, [BibleTextViewMetadata])
        case needsTextViewsCreated(ReadingViewController, [BibleTextViewMetadata])
        
        func presentText() {
            switch self {
                
            case .statusQuo:
                return
                
            case .frameChanged(let vc, let book):
                vc.saveLocation()
                let location = vc._location
                ReadingViewState.needsNewMetadata(vc, book, nil).presentText()
                
            case .bookChanged(let vc, let book, let location):
                ReadingViewState.needsNewMetadata(vc, book, location).presentText()
                
            case .translationChanged(let vc, let translation):
                let currentBook = vc.currentBook
                if let actualBook = currentBook {
                    let newBook = translation.getBookWithCode(actualBook.code)
                    vc._book = newBook
                    ReadingViewState.bookChanged(vc, newBook, nil).presentText()
                }
                
            case .locationChanged(let vc, let location):
                if vc.currentBook?.code == location.bookCode {
                    ReadingViewState.needsContentOffset(vc, location.book, location, vc.textViewMetadata).presentText()
                } else {
                    vc._book = location.book
                    ReadingViewState.bookChanged(vc, location.book, location).presentText()
                }
                
            case .needsNewMetadata(let vc, let book, let location):
                let metadata = vc.getMetadataForCurrentFrame()
                vc.textViewMetadata = metadata
                ReadingViewState.needsLatestLocation(vc, book, location, metadata).presentText()
                
            case .needsLatestLocation(let vc, let book, var location, let metadata):
                if location == nil {
                    location = book.getLocation()
                }
                ReadingViewState.needsTextViewsCleared(vc, book, location!, metadata).presentText()
                
            case .needsTextViewsCleared(let vc, let book, let location, let metadata):
                vc.clearTextViews()
                vc.textViews = Array<BibleTextView?>(count: metadata.count, repeatedValue: nil)
                ReadingViewState.needsContentOffset(vc, book, location, metadata).presentText()
                
            case .needsContentOffset(let vc, let book, let location, let metadata):
                let contentHeight = metadata.reduce(vc.scrollView.frame.origin.y) { $0 + $1.frame.size.height }
                vc.scrollView.contentSize = CGSizeMake(vc.view.frame.size.width, contentHeight)
                vc.showLocation(location)
                ReadingViewState.needsTextViewsCreated(vc, metadata).presentText()
                
            case .needsTextViewsCreated(let vc, let metadata):
                vc.addAndRemoveTextViews()
                ReadingViewState.statusQuo.presentText()
            }
        }
    }
    
    //////////////////////////////////////////////////
    // MARK: Public Properties
    //////////////////////////////////////////////////
    
    var currentBook: Book? {
        get {
            if (_book == nil) {
                _book = getDefaultBook()
            }
            
            return _book
        }
        
        set(newBook) {
            _book = newBook
            if let actualBook = newBook {
                ReadingViewState.bookChanged(self, actualBook, nil).presentText()
            }
        }
    }
    
    var location: BookLocation? {
        didSet {
            if let actualLocation = location {
                ReadingViewState.locationChanged(self, actualLocation).presentText()
            }
        }
    }
    
    var translation: Translation? {
        didSet {
            if let actualTranslation = translation {
                ReadingViewState.translationChanged(self, actualTranslation).presentText()
            }
        }
    }
    
    //////////////////////////////////////////////////
    // MARK: Private Properties
    //////////////////////////////////////////////////
    
    private var appDel: AppDelegate
    private var moc: NSManagedObjectContext
    private var frameForMetadata: CGRect?
    private var bookForMetadata: Book?
    private var textViewMetadata: Array<BibleTextViewMetadata> = []
    private var textViewManager: BibleTextViewManager
    private var textViews: Array<BibleTextView?> = []
    private var lastFrameIndex = 0
    private let numberOfFramesToShow = 15
    private var scrollView: UIScrollView
    private var _location: BookLocation?
    private var _book: Book?
 
    
    //////////////////////////////////////////////////
    // MARK: Initializers
    //////////////////////////////////////////////////
    
    required init(coder aDecoder: NSCoder) {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        moc = appDel.managedObjectContext!
        textViewManager = BibleTextViewManager()
        scrollView = UIScrollView()
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        moc = appDel.managedObjectContext!
        textViewManager = BibleTextViewManager()
        scrollView = UIScrollView()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    //////////////////////////////////////////////////
    // MARK: View Lifecycle
    //////////////////////////////////////////////////
    
    override func viewDidLoad() {
        scrollView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.frame.size)
        scrollView.delegate = self
        scrollView.scrollsToTop = false
        self.view.addSubview(scrollView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // If the frame changes, reload text
        if (frameForMetadata != self.view.frame) {
            scrollView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.frame.size)
            if let book = currentBook {
                ReadingViewState.frameChanged(self, book).presentText()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveLocation()
    }
    
    // MARK: ScrollView Delegate Functions
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if currentFrameIndex != lastFrameIndex {
            addAndRemoveTextViews()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        saveLocation()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        saveLocation()
    }
    
    //////////////////////////////////////////////////
    // MARK: Changing Location
    //////////////////////////////////////////////////
    
    private func showLocation(location: BookLocation) {
        // Find the metadatum that contains this location.
        if let metadatum = textViewMetadata.filter({$0.containsLocation(location)}).first {
            let textView = BibleTextView(metadata: metadatum, book: location.book)
            let offset = textView.getOffsetForLocation(location)
            if let actualOffset = offset {
                let maxY = scrollView.contentSize.height - scrollView.frame.height
                self.scrollView.contentOffset = CGPoint(x: textView.frame.origin.x, y: min(actualOffset.y, maxY))
            }
        } else {
            println("Warning: Could not find a BibleTextViewMetadata to display location \(location.book.shortName) \(location.chapter):\(location.verse)")
        }
        
    }
    
    func saveLocation() {
        // Find the textView currently being viewed
        var position: CGFloat = 0
        var i = 0;
        for i = 0; i < textViewMetadata.count; i++ {
            var metadatum = textViewMetadata[i]
            if scrollView.contentOffset.y < position + metadatum.frame.size.height {
                break;
            }
            position += metadatum.frame.size.height
        }
        
        if textViews.count < 1 {
            return
        }
        
        let currentTextView = textViews[i]
        if let textView = currentTextView {
            // Get the text position of the first character of the first line that's in view
            let firstLineLocation = scrollView.contentOffset.y - position
            let relativeCharPosition = textView.closestPositionToPoint(CGPoint(x: scrollView.frame.origin.x, y: firstLineLocation))
            let relativeCharIndex = textView.offsetFromPosition(textView.beginningOfDocument, toPosition: relativeCharPosition)
            let charIndex = textView.metadata.textRange.location + relativeCharIndex
            if let book = currentBook {
                _location = BibleMarkupParser().saveLocationForCharAtIndex(Int32(charIndex), forText: book.text, andBook: book)
                println("Saved location \(currentBook?.shortName) \(location?.chapter):\(location?.verse)")
            }
        } else {
            println("Warning: location could not be saved because the BibleTextView at the current location is not instantiated.")
        }
    }
    
    
    //////////////////////////////////////////////////
    // MARK: Presenting Text
    //////////////////////////////////////////////////
    
    private func getMetadataForCurrentFrame() -> [BibleTextViewMetadata] {
        if let oldFrame = frameForMetadata where CGRectEqualToRect(self.view.frame, oldFrame) && currentBook?.objectID == bookForMetadata?.objectID {
                return textViewMetadata
        }
        
        if let actualBook = currentBook {
            frameForMetadata = view.frame
            bookForMetadata = currentBook
            return BibleTextViewMetadataGenerator.generateWithRecommendedSize(frameForMetadata!.size, book: actualBook)
        } else {
            return [BibleTextViewMetadata]()
        }
    }
    
    
    private func addAndRemoveTextViews() {
        // loop through all text views and instantiate the ones close to the current one and destroy all others
        for i in 0..<textViewMetadata.count {
            var textView: BibleTextView? = textViews[i]
            if textViewWithIndexShouldBeInstantiated(i) {
                if textView == nil, let actualBook = currentBook {
                    textView = BibleTextView(metadata: textViewMetadata[i], book: actualBook)
                    scrollView.addSubview(textView!)
                    textViews[i] = textView
                }
            } else {
                if textView != nil {
                    textView?.removeFromSuperview()
                    textViews[i] = nil
                }
            }
        }
    }
    
    private func clearTextViews() {
        textViews.map() { $0?.removeFromSuperview() }
        textViews = Array<BibleTextView>()
    }
    
    //////////////////////////////////////////////////
    // MARK: Helper Functions
    //////////////////////////////////////////////////
    
    func getDefaultBook() -> Book? {
        let genesisRequest = NSFetchRequest(entityName: "Book")
        let translationCode: String = NSUserDefaults.standardUserDefaults().objectForKey("selectedTranslation") as! String
        genesisRequest.predicate = NSPredicate(format: "code == 'GEN' && translation == '\(translationCode)'")
        
        var err: NSError?
        if let result = moc.executeFetchRequest(genesisRequest, error: &err) as? [Book] {
            if let actualError = err {
                println("Error getting default book in ReadingViewController.\n\(actualError.localizedDescription)")
            }
            
            return result[0]
        } else {
            return nil
        }
    }
    
    private var currentFrameIndex: Int {
        get {
            if textViewMetadata.count > 0 {
                var yPos: CGFloat = 0
                var index = 0
                for datum in textViewMetadata {
                    yPos += datum.frame.size.height
                    if yPos >= self.scrollView.contentOffset.y {
                        break
                    }
                    index++
                }
                return index
            } else {
                return 0
            }
        }
    }
    
    private func textViewWithIndexShouldBeInstantiated(textViewIndex: Int) -> Bool {
        let margin = numberOfFramesToShow / 2
        return abs(currentFrameIndex - textViewIndex) <= margin
    }
    
}