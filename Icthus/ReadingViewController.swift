//
//  ReadingViewController.swift
//  Icthus
//
//  Created by Matthew Lorentz on 5/22/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

import Foundation

class ReadingViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet private var readingScrollView: ReadingScrollView!
    private var appDel: AppDelegate
    private var moc: NSManagedObjectContext
    private var frameForMetadata: CGRect?
    private var textViewMetadata: Array<BibleTextViewMetadata> = []
    
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
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        moc = appDel.managedObjectContext!
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: View Lifecycle
    override func viewDidLayoutSubviews() {
        // If the frame changes, reload text
        if (frameForMetadata != self.view.frame) {
            refreshText()
        }
    }
    
    func refreshText() {
        // If we have a book, generate metadata and hand it to the readingScrollView for drawing
        if let actualBook = self.currentBook {
            frameForMetadata = self.view.frame
            textViewMetadata = BibleTextViewMetadataGenerator.generateWithFrame(view.frame, book: actualBook)
            readingScrollView.redraw(textViewMetadata, book: actualBook)
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
}