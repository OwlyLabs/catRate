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


@interface iRateManager ()
@property (nonatomic,retain) NSDictionary *supportMailParams;
@end


@implementation iRateManager
static iRateManager *instance = nil;
static NSBundle *iRateBundle = nil;
iRateView *iRateInstance;


+(iRateManager*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [iRateManager new];
    });
    return instance;
}

-(void)setDebugMode:(BOOL)debug{
    [[iRateMind sharedInstance] setDebugMode:debug];
}

#pragma mark - setup settings
-(void)setIntervalFirstLaunch:(int)intervalDays{
    [[iRateMind sharedInstance] setIntervalFirstLaunch:intervalDays];
}
-(void)setIntervalAfterCancel:(int)intervalDays{
    [[iRateMind sharedInstance] setIntervalAfterCancel:intervalDays];
}
-(void)setCountLaunchesToShow:(int)intervalDays{
    [[iRateMind sharedInstance] setCountLaunchesToShow:intervalDays];
}
-(int)getIntervalFirstLaunch{
    return [[iRateMind sharedInstance] getIntervalFirstLaunch];
}
-(int)getIntervalAfterCancel{
    return [[iRateMind sharedInstance] getIntervalAfterCancel];
}
-(int)getIntervalCountLaunches{
    return [[iRateMind sharedInstance] getIntervalCountLaunches];
}






-(void)hideRate{
    if (iRateInstance) {
        [iRateInstance removeFromSuperview];
    }
}

-(void)setSupportParams:(NSDictionary*)params{
    _supportMailParams = params;
}

-(NSDictionary*)getSupportMailParams{
    return _supportMailParams;
}

-(void)showIfNeeded:(void(^)(BOOL need))callbackBlock{
    if ([[iRateMind sharedInstance] checkRate]) {
        if (callbackBlock) {
            callbackBlock(YES);
        }
        [self checkIRate];
    }else{
        if (callbackBlock) {
            callbackBlock(NO);
        }
    }
}

-(void)showHard{
    [self checkIRate];
}

-(void)checkIRate{
    UIWindow *frontWindow = [[[UIApplication sharedApplication] delegate] window];
    [frontWindow setBackgroundColor:[UIColor clearColor]];
    
    if (!iRateInstance) {
        iRateInstance = [[iRateView alloc] initWithFrame:frontWindow.bounds];
    }
    iRateInstance.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [frontWindow addSubview:iRateInstance];
    
    [iRateInstance setNeedsDisplay];
}

-(void)eventAfterLaunch{
    [[iRateMind sharedInstance] eventAfterLaunch];
}



-(void)setLanguage:(NSString *)l
{
    NSString *path = [[NSBundle mainBundle] pathForResource:l ofType:@"lproj" inDirectory:@"iRateCat.bundle"];
    iRateBundle = [NSBundle bundleWithPath:(!path)?[NSBundle mainBundle]:path];
}

-(NSString *)getLoclizedStringWithKey:(NSString *)key alter:(NSString *)alternate{
    if (!iRateBundle) {
        static NSBundle *bundle = nil;
        if (bundle == nil)
        {
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"iRateCat" ofType:@"bundle"];
            bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
        }
        alternate = [bundle localizedStringForKey:key value:alternate table:nil];
        return [[NSBundle mainBundle] localizedStringForKey:key value:alternate table:nil];
    }
    
    /*static NSBundle *bundle = nil;
     if (bundle == nil)
     {
     NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"iRateCat" ofType:@"bundle"];
     bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
     }
     defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
     return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];*/
    
    
    return [iRateBundle localizedStringForKey:key value:alternate table:nil];
}

@end
