//
//  iRateMind.m
//  dukan
//
//  Created by iSerg on 5/8/15.
//  Copyright (c) 2015 Arthur Hemmer. All rights reserved.
//

#import "iRateMind.h"
#import "iRateManager.h"
#import "UIColor+HEX.h"
#import <sys/utsname.h>

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

static NSString *id_application_key = @"trackIdKey";
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


-(void)resetRateData{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:last_open_date_key];
    [[NSUserDefaults standardUserDefaults] setObject:@"FirstLaunch" forKey:userCallbackKey];
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)0 forKey:countAfterLaunchesKey];
}


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

-(void)userDenyAction{
    [[iRateMind sharedInstance] userDeny];
    if ([[iRateManager sharedInstance].delegate respondsToSelector:@selector(userDeny)]) {
        [[iRateManager sharedInstance].delegate userDeny];
    }
}

-(void)userWriteSupport{
    [[NSUserDefaults standardUserDefaults] setObject:@"Support" forKey:userCallbackKey];
}


-(void)userWriteSupportAction{
    [[iRateMind sharedInstance] userWriteSupport];
    if ([[iRateManager sharedInstance].delegate respondsToSelector:@selector(userWriteSupport)]) {
        [[iRateManager sharedInstance].delegate userWriteSupport];
    }
    
    if ([[iRateManager sharedInstance].delegate respondsToSelector:@selector(customActionSupport)]) {
        [[iRateManager sharedInstance].delegate customActionSupport];
    }else{
        UIViewController *vc = [self parentViewController];
        if (vc) {
            [self supportMail];
        }
    }
}


-(void)userRated{
    [[NSUserDefaults standardUserDefaults] setObject:@"Rated" forKey:userCallbackKey];
}

-(void)userRateAction:(int)stars{
    [[iRateMind sharedInstance] userRated];
    if ([[iRateManager sharedInstance].delegate respondsToSelector:@selector(userRated:)]) {
        [[iRateManager sharedInstance].delegate userRated:stars];
    }
    
    [self checkApplicationID:^(bool complate) {
        if (complate) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:id_application_key]) {
                
                NSString *URLString;
                NSString *iRateiOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%@?action=write-review&mt=8";
                NSString *iRateiOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
                
                float iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
                if ((iOSVersion >= 7.0f && iOSVersion < 8.0f) || iOSVersion >= 11.0)
                {
                    URLString = iRateiOS7AppStoreURLFormat;
                }
                else
                {
                    URLString = iRateiOSAppStoreURLFormat;
                }
                
                NSURL *ratingsURL = [NSURL URLWithString:[NSString stringWithFormat:URLString, [[NSUserDefaults standardUserDefaults] objectForKey:id_application_key]]];
                
                if ([[UIApplication sharedApplication] canOpenURL:ratingsURL])
                {
                    [[UIApplication sharedApplication] openURL:ratingsURL];
                }
                
                
                
            }
        }
    }];
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

#pragma mark - localize


- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    return [[iRateManager sharedInstance] getLoclizedStringWithKey:key alter:defaultString];
}

#pragma mark -


#pragma mark - MFMailComposeViewController

- (UIViewController *)parentViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (void)supportMail{
    if ([MFMailComposeViewController canSendMail]) {
        NSDictionary *cur_params = [[iRateManager sharedInstance] getSupportMailParams];
        
        
        
        
        NSMutableArray *recipients = [NSMutableArray new];
        if ([cur_params objectForKey:@"recipients"]) {
            if ([[cur_params objectForKey:@"recipients"] isKindOfClass:[NSArray class]]) {
                for (NSString *recipient in [cur_params objectForKey:@"recipients"]) {
                    if (![recipient isEqual:[NSNull null]]) {
                        if (recipient) {
                            [recipients addObject:recipient];
                        }
                    }
                }
            }else{
                if ([[cur_params objectForKey:@"recipients"] isKindOfClass:[NSString class]]) {
                    [recipients addObject:[cur_params objectForKey:@"recipients"]];
                }
            }
        }
        
        
        MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = (id)self;
        [mailController setToRecipients:recipients];
        [mailController setSubject:[NSString stringWithFormat:@"%@ (iOS)",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] ]];
        
        UIColor *tintColor = [UIColor colorWithHex:@"#017afd" alpha:1.0];
        if ([cur_params objectForKey:@"tintColor"]) {
            if (![[cur_params objectForKey:@"tintColor"] isEqual:[NSNull null]]) {
                if ([cur_params objectForKey:@"tintColor"]) {
                    if ([UIColor colorWithHex:[cur_params objectForKey:@"tintColor"] alpha:1.0]) {
                        tintColor = [UIColor colorWithHex:[cur_params objectForKey:@"tintColor"] alpha:1.0];
                    }
                }
            }
            
        }
        
        [mailController.navigationBar setTintColor:tintColor];
        
        NSMutableString *seriaDevice = [[NSMutableString alloc] initWithCapacity:10];
        
        NSString *deviceType;
        struct utsname systemInfo;
        uname(&systemInfo);
        deviceType = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
        
        [seriaDevice appendString:deviceType];
        
        [seriaDevice replaceOccurrencesOfString:@"," withString:@"."
                                        options:NSCaseInsensitiveSearch range:NSMakeRange(0, seriaDevice.length)];
        [seriaDevice replaceOccurrencesOfString:@"iPhone" withString:@"iPhone "
                                        options:NSCaseInsensitiveSearch range:NSMakeRange(0, seriaDevice.length)];
        [seriaDevice replaceOccurrencesOfString:@"iPod" withString:@"iPod "
                                        options:NSCaseInsensitiveSearch range:NSMakeRange(0, seriaDevice.length)];
        [seriaDevice replaceOccurrencesOfString:@"iPad" withString:@"iPad "
                                        options:NSCaseInsensitiveSearch range:NSMakeRange(0, seriaDevice.length)];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        
        NSString *name_company = @"";
        if ([cur_params objectForKey:@"nameCompany"]) {
            if (![[cur_params objectForKey:@"nameCompany"] isEqual:[NSNull null]]) {
                if ([cur_params objectForKey:@"nameCompany"]) {
                    name_company = [cur_params objectForKey:@"nameCompany"];
                }
            }
            
        }
        
        [mailController setMessageBody:[NSString stringWithFormat:[[iRateMind sharedInstance] localizedStringForKey:@"iRateView_supportEmail_text" withDefault:@"Здравствуйте, \n\n\nСпасибо!\n\nУстройство:\n %@ \n iOS %@ \nВерсия %@"],seriaDevice,[[UIDevice currentDevice] systemVersion],version] isHTML:NO];
        
        [[self parentViewController] presentViewController:mailController animated:YES completion:nil];
        
    }else {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[iRateMind sharedInstance] localizedStringForKey:@"iRateView_error_email_settings" withDefault:@"Для отправки сообщения необходимо авторизировать почтовый ящик"] delegate:self cancelButtonTitle:[[iRateMind sharedInstance] localizedStringForKey:@"iRateView_support_close" withDefault:@"Закрыть"] otherButtonTitles:nil] show];
    }
}


- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -

#pragma mark - iTunes hepler

-(void)checkApplicationID:(void(^)(bool complate))complated{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:id_application_key]) {
        if (complated) {
            complated(YES);
            return;
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //get country
        NSString *appStoreCountry = [(NSLocale *)[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        if ([appStoreCountry isEqualToString:@"150"])
        {
            appStoreCountry = @"eu";
        }
        else if ([[appStoreCountry stringByReplacingOccurrencesOfString:@"[A-Za-z]{2}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, 2)] length])
        {
            appStoreCountry = @"us";
        }
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/%@/lookup?bundleId=%@",appStoreCountry,[[NSBundle mainBundle] bundleIdentifier]]]];
        
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (data) {
                NSError *error = nil;
                
                id json = [NSJSONSerialization
                           JSONObjectWithData:data
                           options:kNilOptions
                           error:nil];
                if ([NSJSONSerialization class])
                {
                    json = [[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:&error][@"results"] lastObject];
                }
                else
                {
                    //convert to string
                    json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
                
                
                NSString *bundleID = [self valueForKey:@"bundleId" inJSON:json];
                if (bundleID)
                {
                    if ([bundleID isEqualToString:[[NSBundle mainBundle] bundleIdentifier]])
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:[self valueForKey:@"trackId" inJSON:json] forKey:id_application_key];
                        
                        if (complated) {
                            complated(YES);
                            return;
                        }
                    }
                }
                
                
                if (complated) {
                    complated(NO);
                    return;
                }
                
                
                
            }else{
                if (complated) {
                    complated(NO);
                    return;
                }
            }
        });
        
        
    });
}

- (NSString *)valueForKey:(NSString *)key inJSON:(id)json
{
    if ([json isKindOfClass:[NSString class]])
    {
        //use legacy parser
        NSRange keyRange = [json rangeOfString:[NSString stringWithFormat:@"\"%@\"", key]];
        if (keyRange.location != NSNotFound)
        {
            NSInteger start = keyRange.location + keyRange.length;
            NSRange valueStart = [json rangeOfString:@":" options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
            if (valueStart.location != NSNotFound)
            {
                start = valueStart.location + 1;
                NSRange valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
                if (valueEnd.location != NSNotFound)
                {
                    NSString *value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    while ([value hasPrefix:@"\""] && ![value hasSuffix:@"\""])
                    {
                        if (valueEnd.location == NSNotFound)
                        {
                            break;
                        }
                        NSInteger newStart = valueEnd.location + 1;
                        valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(newStart, [(NSString *)json length] - newStart)];
                        value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    }
                    
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                    value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\f" withString:@"\f"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\b" withString:@"\f"];
                    
                    while (YES)
                    {
                        NSRange unicode = [value rangeOfString:@"\\u"];
                        if (unicode.location == NSNotFound || unicode.location + unicode.length == 0)
                        {
                            break;
                        }
                        
                        uint32_t c = 0;
                        NSString *hex = [value substringWithRange:NSMakeRange(unicode.location + 2, 4)];
                        NSScanner *scanner = [NSScanner scannerWithString:hex];
                        [scanner scanHexInt:&c];
                        
                        if (c <= 0xffff)
                        {
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C", (unichar)c]];
                        }
                        else
                        {
                            //convert character to surrogate pair
                            uint16_t x = (uint16_t)c;
                            uint16_t u = (c >> 16) & ((1 << 5) - 1);
                            uint16_t w = (uint16_t)u - 1;
                            unichar high = 0xd800 | (w << 6) | x >> 10;
                            unichar low = (uint16_t)(0xdc00 | (x & ((1 << 10) - 1)));
                            
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C%C", high, low]];
                        }
                    }
                    return value;
                }
            }
        }
    }
    else
    {
        return json[key];
    }
    return nil;
}


#pragma mark -

@end
