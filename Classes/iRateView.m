//
//  iRateView.m
//
//  Created by iSerg on 5/7/15.
//  Copyright (c) 2015 Arthur Hemmer. All rights reserved.
//

#import "iRateView.h"
#import "iRateMind.h"
#import <sys/utsname.h>
#import "UIColor+HEX.h"
#import "iRateManager.h"



typedef NS_ENUM (NSInteger, popup_state){
    popup_state_empty = 1,
    popup_state_bad_choise,
    popup_state_good_choise
};

@implementation iRateView

UIView *alphaView;
UIView *star_rate_view;


UIView *header_view;
UIImageView *main_img;
UIView *separ;
UIView *cover;


UIButton *actionBtn;
UCButton *cancelBtn;

popup_state stateAlert;
int cur_stars = 0;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.backgroundColor = [UIColor clearColor];
    [self initData];
    return self;
}

-(void)initData{
    cur_stars = 0;
    stateAlert = popup_state_empty;
}




-(void)clearView{
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
}

UIVisualEffectView *blurEffectView;
UIBlurEffect *blurEffect;
-(void)showView{
    [self clearView];
    self.alpha = 0;
    self.hidden = NO;
    cur_stars = 0;
    self.backgroundColor = [UIColor clearColor];
    /*if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown) {
            
            self.frame = CGRectMake(0, 0, MainScreenHeight, MainScreenWidht);
        }else{
            self.frame = CGRectMake(0, 0, MainScreenWidht, MainScreenHeight);
        }
    }*/
    
    alphaView = [[UIView alloc] initWithFrame:self.frame];
    alphaView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    alphaView.alpha = 1;
    if (IOS8_AND_LATER) {
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
            alphaView.backgroundColor = [UIColor clearColor];
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.frame = alphaView.bounds;
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            blurEffectView.alpha = 1.0;
            [alphaView addSubview:blurEffectView];
        } else {
            alphaView.backgroundColor = [UIColor blackColor];
            alphaView.alpha = 0.4;
        }
    } else {
        alphaView.backgroundColor = [UIColor blackColor];
        alphaView.alpha = 0.4;
    }
    
    [self addSubview:alphaView];
    
    UIView *rate_v = [self rateView];
    rate_v.center = self.center;
    rate_v.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    [self addSubview:rate_v];
    [self setRate:cur_stars];
    
    
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
}


- (void) didRotate:(NSNotification *)notification {
    
}

-(UIView*)rateView{
    if (IS_IPAD) {
        return [self coverForIPad];
    }else{
        return [self coverForIPhone];
    }
}

-(UIView*)headerView:(popup_state)state forCover:(UIView*)cover{
    
    NSMutableParagraphStyle *paragraphStyle_big_title = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle_big_title.lineSpacing = 1*0.45;
    paragraphStyle_big_title.minimumLineHeight = (IS_IPAD)?36.f:24.f;
    paragraphStyle_big_title.maximumLineHeight = (IS_IPAD)?36.f:24.f;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 1*0.45;
    paragraphStyle.minimumLineHeight = (IS_IPAD)?36:16.f;
    paragraphStyle.maximumLineHeight = 36.f;
    
    NSMutableParagraphStyle *paragraphStyle_2 = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle_2.lineSpacing = 1*1.9;
    paragraphStyle_2.minimumLineHeight = (IS_IPAD)?22:16.f;
    paragraphStyle_2.maximumLineHeight = 36.f;
    
    switch (state) {
        case popup_state_empty:{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 19, cover.frame.size.width - 40, 70)];
            
            
            
            NSMutableAttributedString *stringForRecom = [[NSMutableAttributedString alloc] initWithString: [[iRateMind sharedInstance] localizedStringForKey:@"iRateView_do_you_like" withDefault:@"Вам нравится приложение?"] attributes: @{NSParagraphStyleAttributeName : paragraphStyle_big_title, NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:(IS_IPAD)?30.0:20.0]}];
            
            UILabel *like_app = [[UILabel alloc] initWithFrame:CGRectMake(0, (IS_IPAD)?-4.5:0, view.frame.size.width, (IS_IPAD)?80:50)];
            
            [like_app setAttributedText:stringForRecom];
            
            like_app.font = [UIFont fontWithName:@"HelveticaNeue" size:(IS_IPAD)?30.0:20.0];
            like_app.textAlignment = NSTextAlignmentCenter;
            like_app.numberOfLines = 2;
            like_app.textColor = [UIColor colorWithHex:@"189395" alpha:1.0];
            [view addSubview:like_app];
            return view;
            break;}
        case popup_state_bad_choise:{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, (IS_IPAD)?19+9:19, cover.frame.size.width - 40, 70+((IS_IPAD)?-9:0))];
            UILabel *thanksTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, (IS_IPAD)?30:25)];
            
            
            
            
            thanksTitle.text = [[iRateMind sharedInstance] localizedStringForKey:@"iRateView_what_happened" withDefault:@"Что случилось?"];
            thanksTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:(IS_IPAD)?30:20.0];
            thanksTitle.textAlignment = NSTextAlignmentCenter;
            thanksTitle.numberOfLines = 1;
            thanksTitle.textColor = [UIColor colorWithHex:@"189395" alpha:1.0];
            [view addSubview:thanksTitle];
            
            
            
            
            NSMutableAttributedString *atrStr = [[NSMutableAttributedString alloc] initWithString: [[iRateMind sharedInstance] localizedStringForKey:@"iRateView_what_please_write" withDefault:@"Пожалуйста, напишите, как мы\nможем улучшить приложение"] attributes: @{NSParagraphStyleAttributeName : paragraphStyle_2, NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:(IS_IPAD)?22:15.0]}];
            
            UILabel *thanksTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(thanksTitle.frame)+((IS_IPAD)?2.5:0), view.frame.size.width, (IS_IPAD)?60:45)];
            [thanksTitle2 setAttributedText:atrStr];
            
            
            thanksTitle2.font = [UIFont fontWithName:@"HelveticaNeue" size:(IS_IPAD)?22:15.0];
            thanksTitle2.textAlignment = NSTextAlignmentCenter;
            thanksTitle2.numberOfLines = 2;
            thanksTitle2.textColor = [UIColor colorWithHex:@"5d7185" alpha:1.0];
            [view addSubview:thanksTitle2];
            return view;
            break;}
        case popup_state_good_choise:{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 19, cover.frame.size.width - 40, 70)];
            UILabel *thanksTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, (IS_IPAD)?9:0, view.frame.size.width, (IS_IPAD)?30:25)];
            
            thanksTitle.text = [[iRateMind sharedInstance] localizedStringForKey:@"iRateView_good" withDefault:@"Отлично! Спасибо!"];
            thanksTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:(IS_IPAD)?30:20.0];
            thanksTitle.textAlignment = NSTextAlignmentCenter;
            thanksTitle.numberOfLines = 1;
            thanksTitle.textColor = [UIColor colorWithHex:@"189395" alpha:1.0];
            [view addSubview:thanksTitle];
            
            
            NSMutableAttributedString *atrStr = [[NSMutableAttributedString alloc] initWithString: [[iRateMind sharedInstance] localizedStringForKey:@"iRateView_support" withDefault:@"Поддержите приложение,\nоставьте отзыв в App Store"] attributes: @{NSParagraphStyleAttributeName : paragraphStyle_2, NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:(IS_IPAD)?22:15.0]}];
            
            UILabel *thanksTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(thanksTitle.frame)+((IS_IPAD)?2.5:0), view.frame.size.width, (IS_IPAD)?60:45)];
            
            [thanksTitle2 setAttributedText:atrStr];
            
            thanksTitle2.font = [UIFont fontWithName:@"HelveticaNeue" size:(IS_IPAD)?22:15.0];
            thanksTitle2.textAlignment = NSTextAlignmentCenter;
            thanksTitle2.numberOfLines = 3;
            thanksTitle2.textColor = [UIColor colorWithHex:@"5d7185" alpha:1.0];
            [view addSubview:thanksTitle2];
            
            return view;
            break;}
            
        default:
            break;
    }
    return nil;
}



-(UIImageView*)imageView:(popup_state)state forCover:(UIView*)cover{
    switch (state) {
        case popup_state_empty:{
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IPAD)?@"empty_recall_ipad":@"empty_recall"]];
            return imgView;
            break;}
        case popup_state_bad_choise:{
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IPAD)?@"bad_recall_ipad":@"bad_recall"]];
            return imgView;
            break;}
        case popup_state_good_choise:{
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IPAD)?@"good_recall_ipad":@"good_recall"]];
            return imgView;
            break;}
        default:
            break;
    }
    return nil;
}



int count_stars = 5;
float distance = 10.0;
-(UIView*)getStarsViewForCover:(UIView*)cover{
    distance = (IS_IPAD)?17:10;
    if (!star_rate_view) {
        float margin = 27.0;
        UIImage *start_img = [UIImage imageNamed:(IS_IPAD)?@"rate_empty_star_ipad":@"rate_empty_star"];
        star_rate_view = [[UIView alloc] initWithFrame:CGRectMake(margin, 0, (distance+start_img.size.width)*(count_stars), (IS_IPAD)?45:33)];
        float lastX = 0;
        for (int i = 0; i < count_stars; i++) {
            UIImageView *star = [[UIImageView alloc] initWithFrame:CGRectMake(distance/2 + lastX, 0, start_img.size.width, start_img.size.height)];
            star.image = start_img;
            star.tag = i+1;
            [star_rate_view addSubview:star];
            lastX = CGRectGetMaxX(star.frame) + distance/2;
        }
        UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(handlePan:)];
        [star_rate_view addGestureRecognizer:pgr];
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(handlePan:)];
        [star_rate_view addGestureRecognizer:tgr];
    }
    return star_rate_view;
}



#pragma mark - Gesture

-(IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:star_rate_view];
    float position = 0;
    if (point.x < 0) {
        position = 0;
    }else{
        if (point.x > star_rate_view.bounds.size.width) {
            position = star_rate_view.bounds.size.width;
        }else{
            position = point.x;
        }
    }
    int value_star = star_rate_view.bounds.size.width/count_stars;
    int rate = floor(position/value_star) + 1;
    if (position == 0) {
        rate = 0;
    }
    [self setRate:rate];
}

#pragma mark -



-(void)setRate:(int)rate{
    
    cur_stars = rate;
    
    if (star_rate_view) {
        for (UIView *imgV in [star_rate_view subviews]) {
            if ([imgV isKindOfClass:[UIImageView class]]) {
                if ([imgV tag]<=rate) {
                    [((UIImageView*)imgV) setImage:[UIImage imageNamed:(IS_IPAD)?@"rate_full_star_ipad":@"rate_full_star"]];
                }else{
                    [((UIImageView*)imgV) setImage:[UIImage imageNamed:(IS_IPAD)?@"rate_empty_star_ipad":@"rate_empty_star"]];
                }
            }
        }
    }
    
    if (rate == 0) {
        stateAlert = popup_state_empty;
    }else{
        if (rate < 4) {
            stateAlert = popup_state_bad_choise;
        }else{
            stateAlert = popup_state_good_choise;
        }
    }
    
    
    [self rateView];
}


-(UIButton*)getActionButtonForCover:(UIView*)cover andState:(popup_state)state{
    
    UIButton *action_button = [UIButton buttonWithType:UIButtonTypeCustom];
    float margin = (IS_IPAD)?79:27.0;
    [action_button setFrame:CGRectMake(margin, 0, cover.frame.size.width - margin*2, 41)];
    switch (state) {
        case popup_state_empty:{
            
            
            
            
            
            [action_button setTitle:[[iRateMind sharedInstance] localizedStringForKey:@"iRateView_rate_app" withDefault:@"Оцените приложение"] forState:UIControlStateNormal];
            action_button.backgroundColor = [UIColor colorWithHex:@"e5e8e8" alpha:1.0];
            [action_button setTitleColor:[UIColor colorWithHex:@"5d7185" alpha:1.0] forState:UIControlStateNormal];
            action_button.userInteractionEnabled = NO;
            break;}
        case popup_state_bad_choise:{
            
            [action_button setTitle:[[iRateMind sharedInstance] localizedStringForKey:@"iRateView_write_support" withDefault:@"Написать разработчику"] forState:UIControlStateNormal];
            [action_button setBackgroundImage:[UIImage imageNamed:@"rate_action_btn_bg"] forState:UIControlStateNormal];
            [action_button setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
            break;}
        case popup_state_good_choise:{
            [action_button setTitle:[[iRateMind sharedInstance] localizedStringForKey:@"iRateView_rate" withDefault:@"Оставить отзыв"] forState:UIControlStateNormal];
            [action_button setBackgroundImage:[UIImage imageNamed:@"rate_action_btn_bg"] forState:UIControlStateNormal];
            [action_button setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
            break;}
        default:
            break;
    }
    
    
    
    action_button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:(IS_IPAD)?27:18.0];
    //
    action_button.layer.cornerRadius = 5.0;
    action_button.clipsToBounds = YES;
    return action_button;
}

-(UCButton*)getCancelButtonForCover:(UIView*)cover{
    UCButton *cancel_button = [UCButton buttonWithType:UIButtonTypeCustom];
    [cancel_button setFrame:CGRectMake(0, 0, cover.frame.size.width, (IS_IPAD)?50:32)];
    [cancel_button addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    [cancel_button setTitle:[[iRateMind sharedInstance] localizedStringForKey:@"iRateView_cancel" withDefault:@"Отмена"] forState:UIControlStateNormal];
    [cancel_button setTitleColor:[UIColor colorWithHex:@"515151" alpha:1.0] forState:UIControlStateNormal];
    [cancel_button setTitleColor:[UIColor colorWithHex:@"515151" alpha:0.8] forState:UIControlStateHighlighted];
    
    cancel_button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:(IS_IPAD)?30:20.0];
    
    return cancel_button;
}




-(UIView*)coverForIPhone{
    //
    if (!cover) {
        cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 262, 406)];
        cover.backgroundColor = [UIColor colorWithHex:@"#f2f5f5" alpha:1];
        cover.center = CGPointMake(self.center.x, self.center.y + 9.5);
        cover.layer.cornerRadius = 5;
    }
    
    //
    [header_view removeFromSuperview];
    header_view = [self headerView:stateAlert forCover:cover];
    [cover addSubview:header_view];
    
    //
    [main_img removeFromSuperview];
    main_img = [self imageView:stateAlert forCover:cover];
    main_img.frame = RectSetOrigin(main_img.frame, (cover.frame.size.width - main_img.frame.size.width)/2, CGRectGetMaxY(header_view.frame));
    [cover addSubview:main_img];
    
    //
    if (!star_rate_view) {
        [self getStarsViewForCover:cover];
        [cover addSubview:star_rate_view];
    }
    star_rate_view.frame = RectSetOrigin(star_rate_view.frame, (cover.frame.size.width - star_rate_view.frame.size.width)/2, CGRectGetMaxY(main_img.frame) + 8);
    
    //
    [actionBtn removeFromSuperview];
    actionBtn = nil;
    actionBtn = [self getActionButtonForCover:cover andState:stateAlert];
    [cover addSubview:actionBtn];
    [actionBtn setFrame:CGRectMake(20, CGRectGetMaxY(star_rate_view.frame) + 17, cover.frame.size.width - 40, 41.0)];
    
    
    switch (stateAlert) {
        case popup_state_bad_choise:{
            [actionBtn addTarget:self action:@selector(writeDeveloper) forControlEvents:UIControlEventTouchUpInside];
            break;}
        case popup_state_good_choise:{
            [actionBtn addTarget:self action:@selector(rateApplication) forControlEvents:UIControlEventTouchUpInside];
            break;}
        default:
            break;
    }
    
    //
    if (!separ) {
        separ = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(actionBtn.frame) + 10, cover.frame.size.width, 0.5)];
        [cover addSubview:separ];
        separ.backgroundColor = [UIColor colorWithHex:@"a2adb9" alpha:1.0];
    }
    
    
    
    //
    if (!cancelBtn) {
        cancelBtn = [self getCancelButtonForCover:cover];
        [cover addSubview:cancelBtn];
    }
    [cancelBtn setTitle:[[iRateMind sharedInstance] localizedStringForKey:@"iRateView_cancel" withDefault:@"Отмена"] forState:UIControlStateNormal];
    [cancelBtn setFrame:CGRectMake(0, CGRectGetMaxY(separ.frame) + 5, cover.frame.size.width, 32.0)];
    
    
    return cover;
}




-(UIView*)coverForIPad{
    //
    if (!cover) {
        cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 436, 644)];
        cover.backgroundColor = [UIColor colorWithHex:@"#f2f5f5" alpha:1];
        cover.center = CGPointMake(self.center.x, self.center.y - 30);
        cover.layer.cornerRadius = 5;
    }
    
    //
    [header_view removeFromSuperview];
    header_view = [self headerView:stateAlert forCover:cover];
    [cover addSubview:header_view];
    
    //
    [main_img removeFromSuperview];
    main_img = [self imageView:stateAlert forCover:cover];
    main_img.frame = RectSetOrigin(main_img.frame, (cover.frame.size.width - main_img.frame.size.width)/2, CGRectGetMaxY(header_view.frame)+46);
    [cover addSubview:main_img];
    
    //
    if (!star_rate_view) {
        [self getStarsViewForCover:cover];
        [cover addSubview:star_rate_view];
    }
    star_rate_view.frame = RectSetOrigin(star_rate_view.frame, (cover.frame.size.width - star_rate_view.frame.size.width)/2, CGRectGetMaxY(main_img.frame) + 37);
    
    //
    [actionBtn removeFromSuperview];
    actionBtn = nil;
    actionBtn = [self getActionButtonForCover:cover andState:stateAlert];
    [cover addSubview:actionBtn];
    [actionBtn setFrame:CGRectMake(40, CGRectGetMaxY(star_rate_view.frame) + 20, cover.frame.size.width - 40*2, 67.5)];
    
    
    switch (stateAlert) {
        case popup_state_bad_choise:{
            [actionBtn addTarget:self action:@selector(writeDeveloper) forControlEvents:UIControlEventTouchUpInside];
            break;}
        case popup_state_good_choise:{
            [actionBtn addTarget:self action:@selector(rateApplication) forControlEvents:UIControlEventTouchUpInside];
            break;}
        default:
            break;
    }
    
    //
    if (!separ) {
        separ = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(actionBtn.frame) + 10+17, cover.frame.size.width, 1)];
        [cover addSubview:separ];
        separ.backgroundColor = [UIColor colorWithHex:@"c2c5c5" alpha:1.0];
    }
    
    
    
    //
    if (!cancelBtn) {
        cancelBtn = [self getCancelButtonForCover:cover];
        [cover addSubview:cancelBtn];
    }
    [cancelBtn setTitle:[[iRateMind sharedInstance] localizedStringForKey:@"iRateView_cancel" withDefault:@"Отмена"] forState:UIControlStateNormal];
    [cancelBtn setFrame:CGRectMake(0, CGRectGetMaxY(separ.frame) + 4, cover.frame.size.width, 50.0)];
    
    
    return cover;
}






#pragma mark - button action

-(void)writeDeveloper{
    [[iRateMind sharedInstance] userWriteSupportAction];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}



-(void)rateApplication{
    [[iRateMind sharedInstance] userRateAction:cur_stars];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


-(void)cancelAction{
    [[iRateMind sharedInstance] userDenyAction];
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}



@end

