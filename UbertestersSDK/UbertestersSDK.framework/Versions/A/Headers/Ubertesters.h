//
//  Ubertesters.h
//  Ubertesters
//
//  Created by Ubertesters on 9/7/13.
//  Copyright (c) 2014 Ubertesters. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UTAlert.h"

@class CustomViewUberTesters;
@class UserProfileViewController;
@class LockScreenViewControllerUberTesters;

//enums
typedef enum {
    /**Default options (Slider and UTOptionsLockingModeDisableUbertestersIfBuildNotExist).*/
    UTOptionsDefault = 0,
    
    /**Option for using Slider mode.*/
    UTOptionsSlider = 1 << 0,
    
    /**Option for using Shake mode.*/
    UTOptionsShake = 1 << 1,
    
    /**Option for Manual mode.*/
    UTOptionsManual = 1 << 2,
    
    /**Option for Locking mode (default).*/
    UTOptionsLockingModeDisableUbertestersIfBuildNotExist = 1 << 3,  //is default option, that will not lock your application if auth function receive 74 error - application not found.

    /**Option for Locking mode.*/
    UTOptionsLockingModeAppIfBuildNotExist = 1 << 4                  //locks app if build not exists.
} UbertestersOptions;

typedef enum  {
    LockingModeDisableUbertestersIfBuildNotExist = 0,
    LockingModeLockAppIfBuildNotExist = 1,
} LockingMode;

typedef enum {
    /**
     *  Use slider mode.
     */
    UTSlider = 0,
    /**
     *  Use shake mode.
     */
    UTShake = 1,
    /**
     *  Use manual mode.
     */
    UTManual = 2
} ActivationMode;

typedef enum
{
    UTLogLevelError,
    UTLogLevelWarning,
    UTLogLevelInfo
} UTLogLevel;

@interface Ubertesters : NSObject <UITextViewDelegate, UTAlertDelegate>
{
    BOOL dismissed;
    BOOL sendReport;
    UITextView *textView_feedback;
    UIView *feedbackView;
    UIButton *btn_send;
    NSString *_crashFilePath;
    BOOL isFirstTime;
    NSTimer *timerLogs;
}
@property (nonatomic, readonly) LockScreenViewControllerUberTesters *lockScreen;
@property (nonatomic, readonly) UserProfileViewController *userProfileScreen;
@property (nonatomic, retain) NSString* apiKey;
@property (nonatomic, retain) CustomViewUberTesters *mainView;

@property (nonatomic, assign) BOOL isOpenGL;
@property (nonatomic, assign) BOOL isInit;
@property (nonatomic, assign) BOOL isHide;
@property (nonatomic, assign) BOOL autoUpdate;

/**
 *  if customer sends this property in dictionary properties as YES -> after app receive error code APPLICATION NO FOUND -> we will not close the app
 
 Default is LockingModeDisableUbertestersIfBuildNotExist
 */
@property (nonatomic, assign)LockingMode lockingMode;

/**
 *  Main method for accessing Ubertesters singleton.
 *
 *  @return Ubertestrs singleton.
 */
+ (Ubertesters*) shared;

/**
 Initialize Ubertesters framework with default properties:
 LockingMode = LockingModeDisableUbertestersIfBuildNotExist,
 ActivationMode = UTSlider
 */
- (void)initialize;

/**
 This method is deprecated!
 @see initializeWithOptions:
 */
- (void)initialize:(LockingMode)mode __attribute__((deprecated(" use 'initializeWithOptions:' instead.")));

/**
 Initialize Ubertesters framework with user`s options:
 @param UTSlider initialize Ubertesters with menu picker buttons.
 @param UTShake initialize Ubertesters with shake gesture.
 @param UTManual initialize Ubertesters with manual mode.
 */
- (void)initializeWithOptions:(UbertestersOptions)options;

//API
/**
 *  Makes Screenshot of any view (openGL or UIKit).
 */
- (void)makeScreenshot;
/**
 *  Shows menu slider.
 */
- (void)showMenuSlider;
/**
 *  Hides menu slider.
 */
- (void)hideMenuSlider;
/**
 *  Shows Ubertesters menu.
 */
- (void)showMenu;
/**
 *  Hides Ubertesters menu.
 */
- (void)hideMenu;
/**
 This method is deprecated!
 @see UTLog:withLevel:
 */
- (void)UTLog:(NSString *)format level:(NSString *)level __attribute__((deprecated(" use 'UTLog:withLevel:' instead.")));
/**
 *  Logs custom message into session.
 *
 *  @param format of type NSString
 *  @param level of type UTLogLevel
 */
- (void)UTLog:(NSString *)format withLevel:(UTLogLevel)level;

// public functions for lib's classes
- (BOOL)isOnline;
- (NSString *)getPhoneState;
- (void)makeAppExit;
- (void)showLockScreen;
- (void)postLogs:(NSString*)logs token:(NSString *)token;
- (void)postCrash:(NSString*)log token:(NSString *)token state:(NSString *)state rid: (NSString *)rid uid: (NSString *)uid;
- (void)makeUTLibWindowKeyAndVisible;
- (UIWindow *)getUTLibWindow;
- (void)playSystemSound:(int)soundID;
- (void)enableTimer:(BOOL)res;
- (void)showUserProfileScreen;

@end

/**Handle Exception*/
void HandleUbertestersException(NSException *exception);
/**Calls when signal occures in the system*/
void SignalUbertestersHandler(int signal);
/**Install Urban HandleEception to the app and uber menu*/
void installUberErrorHandler(void);

