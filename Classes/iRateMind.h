//
//  iRateMind.h
//  dukan
//
//  Created by iSerg on 5/8/15.
//  Copyright (c) 2015 Arthur Hemmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iRateMind : NSObject


+(iRateMind*)sharedInstance;


-(BOOL)checkRate;

-(void)userDeny;
-(void)userWriteSupport;
-(void)userRated;
-(void)eventAfterLaunch;

@end
