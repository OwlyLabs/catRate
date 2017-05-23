//
//  iRateMind.h
//  dukan
//
//  Created by iSerg on 5/8/15.
//  Copyright (c) 2015 Arthur Hemmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

#define MainScreenWidht (([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height)?[UIScreen mainScreen].bounds.size.width:[UIScreen mainScreen].bounds.size.height)

#define MainScreenHeight (([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height)?[UIScreen mainScreen].bounds.size.height:[UIScreen mainScreen].bounds.size.width)

#define RectWidth(f)                        f.size.width
#define RectHeight(f)                       f.size.height
#define RectSetOrigin(f, x, y)              CGRectMake(x, y, RectWidth(f), RectHeight(f))
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IOS8_AND_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define RectSetWidth(f, w)                  CGRectMake(RectX(f), RectY(f), w, RectHeight(f))
#define RectSetHeight(f, h)                 CGRectMake(RectX(f), RectY(f), RectWidth(f), h)
#define RectX(f)                            f.origin.x
#define RectY(f)                            f.origin.y
#define RectSetX(f, x)                      CGRectMake(x, RectY(f), RectWidth(f), RectHeight(f))
#define RectSetY(f, y)                      CGRectMake(RectX(f), y, RectWidth(f), RectHeight(f))

@interface iRateMind : NSObject

+(iRateMind*)sharedInstance;

-(BOOL)checkRate;

-(void)userDeny;
-(void)userWriteSupport;
-(void)userRated;
-(void)eventAfterLaunch;
-(void)setDebugMode:(BOOL)isDebug;



-(void)resetRateData;



-(void)setIntervalFirstLaunch:(int)intervalDays;
-(void)setIntervalAfterCancel:(int)intervalDays;
-(void)setCountLaunchesToShow:(int)intervalDays;
-(int)getIntervalFirstLaunch;
-(int)getIntervalAfterCancel;
-(int)getIntervalCountLaunches;

- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString;


-(void)userWriteSupportAction;
-(void)userRateAction:(int)stars;
-(void)userDenyAction;
@end
