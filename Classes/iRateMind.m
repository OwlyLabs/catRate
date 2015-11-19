//
//  iRateMind.m
//  dukan
//
//  Created by iSerg on 5/8/15.
//  Copyright (c) 2015 Arthur Hemmer. All rights reserved.
//

#import "iRateMind.h"

@implementation iRateMind



static NSString *last_open_date_key = @"rate_last_open_date_key";
static NSString *userCallbackKey = @"rate_userCallbackKey";
static NSString *countAfterLaunchesKey = @"countAfterLaunchesKey";

static NSString *last_rated_version_key = @"last_rated_version_key";


int show_interval_first_launch = 60*60*24*3; /// интервал до 1го показа после устанвки

int show_interval_after_cancel = 60*60*24*4; // интервал после нажания на отмену (4- на 5й день)

/*int show_interval_after_support = 60*60*24*2; // интервал после нажания на отмену
 в этом приле не надо
*/


int limited_count_launches = 100;

bool debug = YES;

static iRateMind *instance = nil;

+(iRateMind*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [iRateMind new];
    });
    return instance;
}




-(BOOL)checkRate{
    if (debug) {
        return YES;
    }
    
    NSString *cur_version = [NSString stringWithFormat:@"%@_%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    //NSLog(@"%@",[UserDefaults objectForKey:last_rated_version_key]);
    //NSLog(@"%@",cur_version);
    
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:last_rated_version_key]) {
        [defaults setObject:cur_version forKey:last_rated_version_key];
    }
    
    long last_date = 0;
    if ([defaults objectForKey:last_open_date_key]) {
        NSDate *lastDate = [defaults objectForKey:last_open_date_key];
        last_date = [lastDate timeIntervalSince1970];
    }
    
    
    BOOL is_changed_version = ![cur_version isEqualToString:[defaults objectForKey:last_rated_version_key]];
    if (is_changed_version) {
        [defaults setObject:cur_version forKey:last_rated_version_key];
        last_date = 0;
    }
    
    if (last_date == 0) {
        [defaults setObject:[NSDate date] forKey:last_open_date_key];
        [defaults setObject:@"FirstLaunch" forKey:userCallbackKey];
        [defaults setInteger:(NSInteger)0 forKey:countAfterLaunchesKey];
        return NO;
    }
    
    long current_time = [[NSDate date] timeIntervalSince1970];
    
    
    
    int complated_launch = (int)[defaults integerForKey:countAfterLaunchesKey];
    
    
    long diff = current_time - last_date;
    
    if (diff<0) {
        // error
        return NO;
    }
    if ([[defaults objectForKey:userCallbackKey] isEqualToString:@"Deny"]) {
        if (diff > show_interval_after_cancel || complated_launch >= limited_count_launches) {
            [defaults setObject:[NSDate date] forKey:last_open_date_key];
            
            [defaults setInteger:(NSInteger)0 forKey:countAfterLaunchesKey];
            
            return YES;
        }
    }else{
        if ([[defaults objectForKey:userCallbackKey] isEqualToString:@"Rated"]) {
            if (is_changed_version) {
                if (diff > show_interval_first_launch || complated_launch >= limited_count_launches) {
                    [defaults setObject:[NSDate date] forKey:last_open_date_key];
                    [defaults setInteger:(NSInteger)0 forKey:countAfterLaunchesKey];
                    return YES;
                }
            }
        }else{
            if ([[defaults objectForKey:userCallbackKey] isEqualToString:@"Support"]) {
                if (is_changed_version) {
                    if (diff > show_interval_first_launch || complated_launch >= limited_count_launches) {
                        [defaults setObject:[NSDate date] forKey:last_open_date_key];
                       [defaults setInteger:(NSInteger)0 forKey:countAfterLaunchesKey];
                        return YES;
                    }
                }
            }else{
                if ([[defaults objectForKey:userCallbackKey] isEqualToString:@"FirstLaunch"]) {
                    if (diff > show_interval_first_launch || complated_launch >= limited_count_launches) {
                        [defaults setObject:[NSDate date] forKey:last_open_date_key];
                        
                        [defaults setInteger:(NSInteger)0 forKey:countAfterLaunchesKey];
                        
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
}

@end
