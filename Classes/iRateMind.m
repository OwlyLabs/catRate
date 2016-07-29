//
//  iRateMind.m
//  dukan
//
//  Created by iSerg on 5/8/15.
//  Copyright (c) 2015 Arthur Hemmer. All rights reserved.
//

#import "iRateMind.h"

@interface iRateMind ()
@property BOOL debug;
@end


@implementation iRateMind

static NSString *last_open_date_key = @"rate_last_open_date_key";
static NSString *userCallbackKey = @"rate_userCallbackKey";
static NSString *countAfterLaunchesKey = @"countAfterLaunchesKey";

static NSString *last_rated_version_key = @"last_rated_version_key";



static NSString *intervalFirstLaunchKey = @"iCatRateIntervalFirstLaunchKey";
static NSString *intervalAfterCancelKey = @"iCatRateIntervalAfterCancelKey";
static NSString *countLaunchesToShowKey = @"iCatRateCountLaunchesToShowKey";

/*int show_interval_after_support = 60*60*24*2; // интервал после нажания на отмену
 в этом приле не надо
 */


static iRateMind *instance = nil;

+(iRateMind*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [iRateMind new];
        [instance setParams];
    });
    return instance;
}

-(void)setParams{
    self.debug = NO;
}

-(void)setDebugMode:(BOOL)isDebug{
    self.debug = isDebug;
}

#pragma mark - show intervals

-(void)setIntervalFirstLaunch:(int)intervalDays{ /// интервал до 1го показа после устанвки
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",intervalDays] forKey:intervalFirstLaunchKey];
}

-(void)setIntervalAfterCancel:(int)intervalDays{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",intervalDays] forKey:intervalAfterCancelKey];
}

-(void)setCountLaunchesToShow:(int)intervalDays{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",intervalDays] forKey:countLaunchesToShowKey];
}

#pragma mark -

-(int)getIntervalFirstLaunch{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:intervalFirstLaunchKey]) {
        int days = [[[NSUserDefaults standardUserDefaults] objectForKey:intervalFirstLaunchKey] intValue];
        if (days>0 && days < 1000) {
            return 60*60*24*days;
        }
    }
    return 60*60*24*3;
}

-(int)getIntervalAfterCancel{ // интервал после нажания на отмену (если 4, то - на 5й день)
    if ([[NSUserDefaults standardUserDefaults] objectForKey:intervalAfterCancelKey]) {
        int days = [[[NSUserDefaults standardUserDefaults] objectForKey:intervalAfterCancelKey] intValue];
        if (days>0 && days < 1000) {
            return 60*60*24*days;
        }
    }
    return 60*60*24*4;
}

-(int)getIntervalCountLaunches{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:countLaunchesToShowKey]) {
        int days = [[[NSUserDefaults standardUserDefaults] objectForKey:countLaunchesToShowKey] intValue];
        if (days>0 && days < 1000) {
            return days;
        }
    }
    return 100;
}

#pragma mark -


-(BOOL)checkRate{
    if (self.debug) {
        return YES;
    }
    
    NSString *cur_version = [NSString stringWithFormat:@"%@_%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:last_rated_version_key]) {
        [[NSUserDefaults standardUserDefaults] setObject:cur_version forKey:last_rated_version_key];
    }
    
    long last_date = 0;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:last_open_date_key]) {
        NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:last_open_date_key];
        last_date = [lastDate timeIntervalSince1970];
    }
    
    
    BOOL is_changed_version = ![cur_version isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:last_rated_version_key]];
    if (is_changed_version) {
        [[NSUserDefaults standardUserDefaults] setObject:cur_version forKey:last_rated_version_key];
        last_date = 0;
    }
    
    if (last_date == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:last_open_date_key];
        [[NSUserDefaults standardUserDefaults] setObject:@"FirstLaunch" forKey:userCallbackKey];
        [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)0 forKey:countAfterLaunchesKey];
        return NO;
    }
    
    long current_time = [[NSDate date] timeIntervalSince1970];
    
    
    
    int complated_launch = (int)[[NSUserDefaults standardUserDefaults] integerForKey:countAfterLaunchesKey];
    
    
    long diff = current_time - last_date;
    
    if (diff<0) {
        // error
        return NO;
    }
    
    
    
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:userCallbackKey] isEqualToString:@"Deny"]) {
        if (diff > [self getIntervalAfterCancel] || complated_launch >= [self getIntervalCountLaunches]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:last_open_date_key];
            
            [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)0 forKey:countAfterLaunchesKey];
            
            return YES;
        }
    }else{
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:userCallbackKey] isEqualToString:@"Rated"]) {
            if (is_changed_version) {
                if (diff > [self getIntervalFirstLaunch] || complated_launch >= [self getIntervalCountLaunches]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:last_open_date_key];
                    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)0 forKey:countAfterLaunchesKey];
                    return YES;
                }
            }
        }else{
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:userCallbackKey] isEqualToString:@"Support"]) {
                if (is_changed_version) {
                    if (diff > [self getIntervalFirstLaunch] || complated_launch >= [self getIntervalCountLaunches]) {
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:last_open_date_key];
                        [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)0 forKey:countAfterLaunchesKey];
                        return YES;
                    }
                }
            }else{
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:userCallbackKey] isEqualToString:@"FirstLaunch"]) {
                    if (diff > [self getIntervalFirstLaunch] || complated_launch >= [self getIntervalCountLaunches]) {
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:last_open_date_key];
                        
                        [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)0 forKey:countAfterLaunchesKey];
                        
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}


-(void)userDeny{
    [[NSUserDefaults standardUserDefaults] setObject:@"Deny" forKey:userCallbackKey];
}

-(void)userWriteSupport{
    [[NSUserDefaults standardUserDefaults] setObject:@"Support" forKey:userCallbackKey];
}

-(void)userRated{
    [[NSUserDefaults standardUserDefaults] setObject:@"Rated" forKey:userCallbackKey];
}

-(void)eventAfterLaunch{
    int complated_launch = 0;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:countAfterLaunchesKey]) {
        [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)0 forKey:countAfterLaunchesKey];
    }
    complated_launch = (int)[[NSUserDefaults standardUserDefaults] integerForKey:countAfterLaunchesKey];
    complated_launch ++;
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)complated_launch forKey:countAfterLaunchesKey];
    
    long last_date = 0;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:last_open_date_key]) {
        NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:last_open_date_key];
        last_date = [lastDate timeIntervalSince1970];
    }
    if (last_date == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:last_open_date_key];
        [[NSUserDefaults standardUserDefaults] setObject:@"FirstLaunch" forKey:userCallbackKey];
    }
}

@end
