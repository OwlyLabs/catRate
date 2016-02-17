//
//  iRateManager.h
//  projector
//
//  Created by iSerg on 8/4/15.
//  Copyright (c) 2015 OwlyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iRateManager : NSObject

+(iRateManager*)sharedInstance;

-(void)showIfNeeded:(void(^)(BOOL need))callbackBlock;
-(void)hideRate;

-(void)eventAfterLaunch;
@end
