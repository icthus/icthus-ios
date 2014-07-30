//
//  IcthusColorMode.h
//  Icthus
//
//  Created by Matthew Lorentz on 7/30/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>
#define colorModeChangedNotification @"colorModeChangedNotification"

@protocol IcthusColorMode <NSObject>

- (void)subscribeToColorChangedNotification;
- (void)unsubscribeFromColorChangedNotification;
- (void)handleColorModeChanged;

@end
