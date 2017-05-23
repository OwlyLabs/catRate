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
#import "iRateAppPopup.h"
//#import "NewGlobalBannerController.h"


@interface iRateManager (){
    rate_type_window cur_style_window;
    iRateAppPopup *ratePopup;
    iRateView *iRateInstance;
}
@property (nonatomic,retain) NSDictionary *supportMailParams;
@end


@implementation iRateManager
static iRateManager *instance = nil;
static NSBundle *iRateBundle = nil;



+(iRateManager*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [iRateManager new];
    });
    return instance;
}

-(void)setupSettings{
    cur_style_window = rate_full_screen;
}


-(void)setDebugMode:(BOOL)debug{
    [[iRateMind sharedInstance] setDebugMode:debug];
}


-(void)setWindowStyle:(rate_type_window)style{
    cur_style_window = style;
}

-(rate_type_window)getWindowStyle{
    return cur_style_window;
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
        [UIView animateWithDuration:0.1 animations:^{
            iRateInstance.alpha = 0;
        } completion:^(BOOL finished) {
            [iRateInstance removeFromSuperview];
        }];
    }
}

-(void)setSupportParams:(NSDictionary*)params{
    _supportMailParams = params;
}

-(NSDictionary*)getSupportMailParams{
    return _supportMailParams;
}



-(void)resetRateData{
    [[iRateMind sharedInstance] resetRateData];
}

-(void)showIfNeeded:(void(^)(BOOL need))callbackBlock{
    if ([[iRateMind sharedInstance] checkRate]) {
        if (callbackBlock) {
            callbackBlock(YES);
        }
    }else{
        if (callbackBlock) {
            callbackBlock(NO);
        }
    }
}


-(void)showIRateFullScreen{
    UIWindow *frontWindow = [[[UIApplication sharedApplication] delegate] window];
    [frontWindow setBackgroundColor:[UIColor clearColor]];
    
    if (!iRateInstance) {
        iRateInstance = [[iRateView alloc] initWithFrame:frontWindow.bounds];
    }
    iRateInstance.hidden = YES;
    iRateInstance.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [frontWindow addSubview:iRateInstance];
    [iRateInstance showView];
    //[iRateInstance setNeedsDisplay];
}



#pragma mark - show popup rate


-(void)showRatePopupWithParent:(UIView*)parent
                     underView:(UIView*)underView
                     topOffset:(float)topOffset withCallbackClose:(void(^)(BOOL close))onClose
onComplatedAnimation:(void(^)(BOOL complatedAnimation))onCompletionAnimation{
    if (!ratePopup) {
        ratePopup = [[iRateAppPopup alloc] initRatePopupWithParentView:parent];
    }else{
        [ratePopup updateView];
    }
    
    [ratePopup showPopup:YES withAnimation:YES underView:underView withTopOffset:topOffset withCallback:^(BOOL close) {
        if (onClose) {
            onClose(YES);
        }
    } onComplateAnimation:^(BOOL complatedAnimation) {
        if (onCompletionAnimation) {
            onCompletionAnimation(complatedAnimation);
        }
    }];
}



-(void)eventAfterLaunch{
    [[iRateMind sharedInstance] eventAfterLaunch];
}



-(void)setLanguage:(NSString *)l
{
    NSString *path = [[NSBundle mainBundle] pathForResource:l ofType:@"lproj" inDirectory:@"iRateCat.bundle"];
    if (path) {
        iRateBundle = [NSBundle bundleWithPath:path];
    }else{
        // try get en
        path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj" inDirectory:@"iRateCat.bundle"];
        if (path) {
            iRateBundle = [NSBundle bundleWithPath:path];
        }else{
            iRateBundle = [NSBundle mainBundle];
        }
    }
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
