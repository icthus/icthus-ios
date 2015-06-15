//
//  ReadingViewController.swift
//  Icthus
//
//  Created by Matthew Lorentz on 5/22/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

import Foundation

class ReadingViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: Properties
    private var appDel: AppDelegate
    private var moc: NSManagedObjectContext
    private var frameForMetadata: CGRect?
    private var textViewMetadata: Array<BibleTextViewMetadata> = []
    private var textViewManager: BibleTextViewManager
    private var textViews: Array<BibleTextView?> = []
    private var lastFrameIndex = 0
    private let numberOfFramesToShow = 15
    private var scrollView: UIScrollView
    
    var translation: Translation? {
        didSet {
            if let actualBook = currentBook {
                // TODO: Present error message that current book does not exist in this translation
                currentBook = translation?.getBookWithCode(actualBook.code)
                refreshText()
            }
        }
    }
    
    var location: BookLocation? {
        didSet {
            currentBook = location?.book
            refreshText()
        }
    }
    
    private var _book: Book?
    var currentBook: Book? {
        get {
            if (_book == nil) {
                _book = getDefaultBook()
            }
            
            return _book
        }
        
        set(newBook) {
            _book = newBook
            refreshText()
        }
    }
    
    // MARK: Initializers
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
    
    func setup() {
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        scrollView = UIScrollView(frame: self.view.frame)
        scrollView.delegate = self
        scrollView.scrollsToTop = false
        self.view.addSubview(scrollView)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // If the frame changes, reload text
        if (frameForMetadata != self.view.frame) {
            refreshText()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveLocation()
    }
    
    func refreshText() {
        // If we have a book, generate metadata and hand it to the textViewManager for drawing
        if let actualBook = self.currentBook {
            frameForMetadata = self.view.frame
            textViewMetadata = BibleTextViewMetadataGenerator.generateWithRecommendedSize(frameForMetadata!.size, book: actualBook)
            redraw(textViewMetadata, book: actualBook)
        }
    }
    
    // MARK: Helper Functions
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
    
    func redraw(metadata: Array<BibleTextViewMetadata>, book: Book, location: BookLocation? = nil) {
        textViewMetadata = metadata
        textViews = Array<BibleTextView?>(count: metadata.count, repeatedValue: nil)
        
        // Set the content size of the scroll view
        let contentHeight = textViewMetadata.reduce(self.scrollView.superview!.frame.origin.y) { $0 + $1.frame.size.height }
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentHeight)
        
        if let actualLocation = location {
            self.showLocation(actualLocation)
        } else {
            scrollView.contentOffset = scrollView.frame.origin
        }
        
        self.addAndRemoveTextViews()
    }
    
    private func showLocation(location: BookLocation) {
        // Find the metadatum that contains this location.
        var i = 0
        for i; i < textViewMetadata.count; i++ {
            let metadatum = textViewMetadata[i]
            if NSLocationInRange(location.chapter.integerValue, metadatum.chapterRange).boolValue &&
                NSLocationInRange(location.verse.integerValue, metadatum.verseRange).boolValue {
                break
            }
        }
        
        // Find the correct line to show
        let metadatum = textViewMetadata[i]
        let textView = BibleTextView(metadata: metadatum, book: location.book)
        let offset = textView.getOffsetForLocation(location, textView: textView)
        if let actualOffset = offset {
            self.scrollView.contentOffset = actualOffset
        }
    }
    
    func saveLocation() {
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
    
    private func textViewWithIndexShouldBeInstantiated(textViewIndex: Int) -> Bool {
        let margin = numberOfFramesToShow / 2
        return abs(currentFrameIndex - textViewIndex) <= margin
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if currentFrameIndex != lastFrameIndex {
            addAndRemoveTextViews()
        }
    }
}