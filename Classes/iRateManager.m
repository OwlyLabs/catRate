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
#import "AppDelegate.h"

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
    if (!iRateInstance) {
        iRateInstance = [[iRateView alloc] initWithFrame:((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.bounds];
    }
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]).window addSubview:iRateInstance];
    [iRateInstance setNeedsDisplay];
}


-(void)eventAfterLaunch{
    [[iRateMind sharedInstance] eventAfterLaunch];
}


@end