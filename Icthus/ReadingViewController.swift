//
//  ReadingViewController.swift
//  Icthus
//
//  Created by Matthew Lorentz on 5/22/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

import Foundation

class ReadingViewController: UIViewController, UIScrollViewDelegate {
    
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
                ReadingViewStateMachine.bookChanged(self, actualBook, nil).continuation()
            }
        }
    }
    
    var location: BookLocation? {
        didSet {
            if let actualLocation = location {
                ReadingViewStateMachine.locationChanged(self, actualLocation).continuation()
            }
        }
    }
    
    var translation: Translation? {
        didSet {
            if let actualTranslation = translation {
                ReadingViewStateMachine.translationChanged(self, actualTranslation).continuation()
            }
        }
    }
    
    var scrollView: UIScrollView
    var _location: BookLocation?
    var _book: Book?
    var textViewMetadata: Array<BibleTextViewMetadata> = []
    var textViews: Array<BibleTextView?> = []
    
    //////////////////////////////////////////////////
    // MARK: Private Properties
    //////////////////////////////////////////////////
    
    private var appDel: AppDelegate
    private var moc: NSManagedObjectContext
    private var sizeForMetadata: CGSize?
    private var bookForMetadata: Book?
    private var textViewManager: BibleTextViewManager
    private var lastFrameIndex = 0
    private let numberOfFramesToShow = 15
    
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
        scrollView.alwaysBounceHorizontal = true
        self.view.addSubview(scrollView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // If the frame changes, reload text
        guard let book = currentBook else { return }
        ReadingViewStateMachine.sizeChanged(self, book, view.frame.size).continuation()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // If the frame changes, reload text
        guard let book = currentBook else { return }
        ReadingViewStateMachine.sizeChanged(self, book, size).continuation()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveLocation()
    }
    
    
    //////////////////////////////////////////////////
    // MARK: ScrollView Delegate Functions
    //////////////////////////////////////////////////
    
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
    // MARK: Managing Location
    //////////////////////////////////////////////////
    
    static func getOffsetForLocation(location: BookLocation, contentSize: CGSize, viewport: CGSize, metadata: [BibleTextViewMetadata]) -> CGPoint {
        // Find the metadatum that contains this location.
        if let metadatum = metadata.filter({$0.containsLocation(location)}).first {
            let textView = BibleTextView(metadata: metadatum, book: location.book)
            let offset = textView.getOffsetForLocation(location)
            if let actualOffset = offset {
                let maxY = contentSize.height - viewport.height
                return CGPoint(x: textView.frame.origin.x, y: min(actualOffset.y, maxY))
            }
        } else {
            print("Warning: Could not find a BibleTextViewMetadata to display location \(location.book.shortName) \(location.chapter):\(location.verse)")
        }
        return CGPoint(x: 0, y: 0)
    }
    
    func saveLocation() {
        guard let book = currentBook else {return}
        let location = ReadingViewController.saveLocationWithOffset(scrollView.contentOffset, metadata: textViewMetadata, textViews: textViews, book: book)
        _location = location
    }
    
    static func saveLocationWithOffset(contentOffset: CGPoint, metadata: [BibleTextViewMetadata], textViews: [BibleTextView?], book: Book) -> BookLocation? {
        // Find the textView currently being viewed
        var position: CGFloat = 0
        var i = 0;
        for i = 0; i < metadata.count; i++ {
            let metadatum = metadata[i]
            if contentOffset.y < position + metadatum.frame.size.height {
                break;
            }
            position += metadatum.frame.size.height
        }
        
        if textViews.count < 1 {
            return nil
        }
        
        let currentTextView = textViews[i]
        if let textView = currentTextView {
            // Get the text position of the first character of the first line that's in view
            let firstLineLocation = contentOffset.y - position
            let optionalRelativeCharPosition = textView.closestPositionToPoint(CGPoint(x: textView.frame.origin.x, y: firstLineLocation))
            guard let relativeCharPosition = optionalRelativeCharPosition else { return nil }
            let relativeCharIndex = textView.offsetFromPosition(textView.beginningOfDocument, toPosition: relativeCharPosition)
            let charIndex = textView.metadata.textRange.location + relativeCharIndex
            
            let location = BibleMarkupParser().saveLocationForCharAtIndex(Int32(charIndex), forText: book.text, andBook: book)
            print("Saved location \(book.shortName) \(location?.chapter):\(location?.verse)")
            return location
        } else {
            print("Warning: location could not be saved because the BibleTextView at the current location is not instantiated.")
        }
        
        return nil
    }
    
    
    //////////////////////////////////////////////////
    // MARK: Presenting Text
    //////////////////////////////////////////////////
    
    func needsNewMetadata() -> Bool {
        if let oldSize = sizeForMetadata where
            CGSizeEqualToSize(self.view.frame.size, oldSize) &&
                currentBook?.objectID == bookForMetadata?.objectID {
                    return false
        } else {
            return true
        }
        
    }
    
    func generatedMetadataWithSize(size: CGSize, book: Book) {
        sizeForMetadata = size
        bookForMetadata = book
    }
    
    func addAndRemoveTextViews() {
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
    
    func clearTextViews() {
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
        
        do {
            if let result = try moc.executeFetchRequest(genesisRequest) as? [Book] {
                return result[0]
            }
        } catch {
            print("Error, could not get default book from Core Data.")
        }
        
        return nil
    }
    
    private func textViewWithIndexShouldBeInstantiated(textViewIndex: Int) -> Bool {
        let margin = numberOfFramesToShow / 2
        return abs(currentFrameIndex - textViewIndex) <= margin
    }
}