//
//  IcthusWhatsNewViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 8/13/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "IcthusWhatsNewViewController.h"

@interface IcthusWhatsNewViewController ()

@end

@implementation IcthusWhatsNewViewController

- (void)viewDidLoad {
    // Set up the pages
    self.pages = @[
                     [self.storyboard instantiateViewControllerWithIdentifier:@"WhatsNewPage1"],
                 ];
    
    [super viewDidLoad];
}

@end
