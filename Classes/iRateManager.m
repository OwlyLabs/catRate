//
//  iRateManager.m
//  projector
//
//  Created by iSerg on 8/4/15.
//  Copyright (c) 2015 OwlyLabs. All rights reserved.
//

#import "iRateManager.h"
#import "iRateView.h"
#import "iRateMind.h"
//#import "NewGlobalBannerController.h"

@implementation iRateManager
static iRateManager *instance = nil;
iRateView *iRateInstance;


+(iRateManager*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [iRateManager new];
    });
    return instance;
}

-(void)showRate{
    //[[NewGlobalBannerController sharedInstance]stopShow];
    [self checkIRate];
}

-(void)hideRate{
    if (iRateInstance) {
        [iRateInstance removeFromSuperview];
    }
}

-(void)showIfNeeded{
    if ([[iRateMind sharedInstance] checkRate]) {
        [self showRate];
    }
}

-(void)checkIRate{
    UIWindow *frontWindow = [[[UIApplication sharedApplication] delegate] window];
    [frontWindow setBackgroundColor:[UIColor clearColor]];
    
    if (!iRateInstance) {
        iRateInstance = [[iRateView alloc] initWithFrame:frontWindow.bounds];
    }
    
    [frontWindow addSubview:iRateInstance];
    
    [iRateInstance setNeedsDisplay];
}

-(void)eventAfterLaunch{
    [[iRateMind sharedInstance] eventAfterLaunch];
}

@end
