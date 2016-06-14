//
//  iRateManager.h
//  projector
//
//  Created by iSerg on 8/4/15.
//  Copyright (c) 2015 OwlyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol iRateManagerDelegate <NSObject>
-(void)userDeny;
-(void)userWriteSupport;
-(void)userRated:(int)stars;
@end

@interface iRateManager : NSObject


+(iRateManager*)sharedInstance;

@property (assign) __unsafe_unretained id <iRateManagerDelegate> delegate;
-(void)showIfNeeded:(void(^)(BOOL need))callbackBlock;
-(void)showHard;
-(void)hideRate;
-(void)eventAfterLaunch;
-(void)setDebugMode:(BOOL)debug;
-(void)setSupportParams:(NSDictionary*)params;
-(NSDictionary*)getSupportMailParams;
@end
