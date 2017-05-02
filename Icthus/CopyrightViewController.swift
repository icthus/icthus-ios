//
//  CopyrightViewController.swift
//  Icthus
//
//  Created by Matthew Lorentz on 9/16/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

import UIKit

class CopyrightViewController: UIViewController {

    var textView: UITextView?

    var translation: Translation? {
        didSet {
            textView?.text = translation?.copyrightText
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Copyright"
        textView = UITextView(frame: self.view.frame)
        textView!.text = translation?.copyrightText
        self.view.addSubview(textView!)
    }
}
