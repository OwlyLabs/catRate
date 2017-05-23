//
//  iRateAppPopup.h
//  dukan
//
//  Created by Serg Rudenko on 23/05/2017.
//  Copyright © 2017 OwlyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iRateAppPopup : UIView
-(iRateAppPopup*)initRatePopupWithParentView:(UIView*)parent;
-(iRateAppPopup*)initRatePopupWithParentView:(UIView*)parent withRootInsets:(UIEdgeInsets)edge;
-(void)updateView;

-(void)showPopup:(BOOL)show withAnimation:(BOOL)animated underView:(UIView*)underView withTopOffset:(float)offset withCallback:(void(^)(BOOL close))onClose onComplateAnimation:(void(^)(BOOL complatedAnimation))complatedAnimation;


@end
