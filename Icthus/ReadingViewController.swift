//
//  ReadingViewController.swift
//  Icthus
//
//  Created by Matthew Lorentz on 5/22/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

import Foundation

class ReadingViewController: UIViewController {
    var appDel: AppDelegate
    var moc: NSManagedObjectContext
    @IBOutlet var readingScrollView: ReadingScrollView!
    var frameForMetadata: CGRect?
    var textViewMetadata: Array<BibleTextViewMetadata> = []
    var translation: Translation?
    var location: BookLocation?
    
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
            reloadText()
        }
    }
    
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
    
    override func viewDidLayoutSubviews() {
        if (frameForMetadata != self.view.frame) {
            reloadText()
        }
    }
    
    func createTextViewMetadataWithFrame(frame: CGRect, book: Book) -> (Array<BibleTextViewMetadata>) {
        return []
    }
    
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
    
    func reloadText() {
        if let actualBook = self.currentBook {
            readingScrollView.textViewMetadata = createTextViewMetadataWithFrame(view.frame, book: actualBook)
            
            frameForMetadata = self.view.frame
            readingScrollView.redraw()
        }
    }
}