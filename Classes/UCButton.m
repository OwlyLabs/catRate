//
//  UCButton.m
//  dukan
//
//  Created by iSerg on 6/8/15.
//  Copyright (c) 2015 Arthur Hemmer. All rights reserved.
//

#import "UCButton.h"

@implementation UCButton


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.bounds = self.bounds;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}


@end
