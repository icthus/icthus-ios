//
//  SlideFromLeftViewController.swift
//  Icthus
//
//  Created by Matthew Lorentz on 6/21/17.
//  Copyright © 2017 Matthew Lorentz. All rights reserved.
//

import Foundation

class SlideFromLeftViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBAction func unwindToReadingViewController() {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToReadingViewController" {
            let destination = segue.destination
            destination.transitioningDelegate = self
        }
    }
}
