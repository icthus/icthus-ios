//
//  TranslationTableViewCell.swift
//  Icthus
//
//  Created by Matthew Lorentz on 9/16/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

import UIKit

class TranslationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var copyrightButton: CopyrightButton!
    @IBOutlet weak var translationNameLabel: UILabel!
    @objc var translation : Translation? {
        didSet {
            translationNameLabel.text = translation?.displayName
            copyrightButton.translation = translation
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        /* Style the cell */
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let colors = appDel.colorManager
        
        backgroundColor = colors?.bookBackgroundColor
        translationNameLabel.textColor = colors?.bookTextColor
        tintColor = colors?.tintColor
        
        copyrightButton.isHidden = true
    }
    
    @objc func showCopyrightButton() {
        if (translation != nil && translation?.copyrightText != nil) {
            self.copyrightButton.isHidden = false
        }
    }
}
