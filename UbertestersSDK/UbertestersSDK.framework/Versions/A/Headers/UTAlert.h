//
//  CustomViewUberTesters.h
//  test
//
//  Created by it EasternPeak on 9/21/12.
//  Copyright (c) 2012 EasternPeak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UTAlert;

@protocol UTAlertDelegate <NSObject>
@optional
-(void)cancelButtonPressed;
-(void)successButtonPressed;
@end


@interface UTAlert : UIView  
{
    CGRect utAlertFrame;

    __unsafe_unretained id <UTAlertDelegate> utAlertDelegate;
}

#define kAlertAnimationDuration 0.3

@property (nonatomic, unsafe_unretained) id <UTAlertDelegate> utAlertDelegate;

-(id)initWithTitle:(NSString *) title message:(NSString *)message cancelButton:(NSString*)cancelButton otherButton:(NSString *)otherButton;

-(void) show: (UIView *)alert;

@end
