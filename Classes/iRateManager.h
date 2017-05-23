//
//  iRateManager.h
//  projector
//
//  Created by iSerg on 8/4/15.
//  Copyright (c) 2015 OwlyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, rate_type_window){
    rate_full_screen,
    rate_popup
};

@protocol iRateManagerDelegate <NSObject>
-(void)userDeny;
-(void)userWriteSupport;
-(void)userRated:(int)stars;
-(void)customActionSupport;
@end

@interface iRateManager : NSObject


+(iRateManager*)sharedInstance;

@property (assign) __unsafe_unretained id <iRateManagerDelegate> delegate;
-(void)showIfNeeded:(void(^)(BOOL need))callbackBlock;

-(void)showIRateFullScreen;

-(void)hideRate;
-(void)eventAfterLaunch;
-(void)setDebugMode:(BOOL)debug;
-(void)setWindowStyle:(rate_type_window)style;
-(rate_type_window)getWindowStyle;

-(void)setSupportParams:(NSDictionary*)params;
-(NSDictionary*)getSupportMailParams;



-(void)setIntervalFirstLaunch:(int)intervalDays;
-(void)setIntervalAfterCancel:(int)intervalDays;
-(void)setCountLaunchesToShow:(int)intervalDays;
-(int)getIntervalFirstLaunch;
-(int)getIntervalAfterCancel;
-(int)getIntervalCountLaunches;

-(void)setLanguage:(NSString *)l;
-(NSString *)getLoclizedStringWithKey:(NSString *)key alter:(NSString *)alternat;

-(void)resetRateData;

-(void)showRatePopupWithParent:(UIView*)parent
                     underView:(UIView*)underView
                     topOffset:(float)topOffset withCallbackClose:(void(^)(BOOL close))onClose
          onComplatedAnimation:(void(^)(BOOL complatedAnimation))onCompletionAnimation;


@end
