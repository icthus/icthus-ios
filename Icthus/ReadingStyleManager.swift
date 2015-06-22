//
//  ReadingStyleManager.swift
//  Icthus
//
//  Created by Matthew Lorentz on 6/3/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

class ReadingStyleManager: NSObject {
    
    static let readingFontName = "AkzidenzGroteskCE-Roman"
    static let verseFontName = "AkzidenzGroteskCE-Roman"
    
    static let horizontalCompactBookTextSize: CGFloat = 22.0
    static let horizontalCompactVerseTextSize: CGFloat = 20.0
    static let horizontalCompactLineSpacing: CGFloat = 1.25
    static let horizontalCompactReadingMargins: CGFloat = 7
    
    static let horizontalRegularBookTextSize: CGFloat = 24.0
    static let horizontalRegularVerseTextSize: CGFloat = 22.0
    static let horizontalRegularLineSpacing: CGFloat = 1.25
    static let horizontalRegularReadingMargins: CGFloat = 15
    
    static func attributedStringFromString(string: String?) -> NSAttributedString {
        let attributes = ReadingStyleManager.getAttributedStringAttributes()
        if let actualString = string {
            return NSAttributedString(string: actualString, attributes: attributes)
        } else {
            return NSAttributedString(string: "", attributes: attributes)
        }
    }
    
    static private func getAttributedStringAttributes() -> [String: AnyObject] {
        var attributesDict = [String: AnyObject]()
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let colorManager = appDel.colorManager
        let paragraphStyle = NSMutableParagraphStyle()
       
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            paragraphStyle.lineHeightMultiple = ReadingStyleManager.horizontalRegularLineSpacing
            attributesDict[NSFontAttributeName] = UIFont(name: ReadingStyleManager.readingFontName, size: ReadingStyleManager.horizontalRegularBookTextSize)
            attributesDict[NSForegroundColorAttributeName] = colorManager.bookTextColor
            attributesDict[NSParagraphStyleAttributeName] = paragraphStyle
        } else {
            paragraphStyle.lineHeightMultiple = ReadingStyleManager.horizontalCompactLineSpacing
            attributesDict[NSFontAttributeName] = UIFont(name: ReadingStyleManager.readingFontName, size: ReadingStyleManager.horizontalCompactBookTextSize)
            attributesDict[NSForegroundColorAttributeName] = colorManager.bookTextColor
            attributesDict[NSParagraphStyleAttributeName] = paragraphStyle
        }
        
        return attributesDict
    }
    
    static func readingViewInset() -> UIEdgeInsets {
        var spacing: CGFloat
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            spacing = ReadingStyleManager.horizontalRegularReadingMargins
        } else {
            spacing = ReadingStyleManager.horizontalCompactReadingMargins
        }
        return UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
    }
}
