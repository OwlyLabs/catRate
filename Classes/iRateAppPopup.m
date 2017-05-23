//
//  iRateAppPopup.m
//  dukan
//
//  Created by Serg Rudenko on 23/05/2017.
//  Copyright © 2017 OwlyLabs. All rights reserved.
//

#import "iRateAppPopup.h"
#import "UIColor+HEX.h"
#import "iRateMind.h"
#import "iRateManager.h"

typedef NS_ENUM (NSInteger, popup_state){
    popup_state_empty = 1,
    popup_state_bad_choise,
    popup_state_good_choise
};

@interface iRateAppPopup (){
    UIView *coverView;
    UIButton *closePopup;
    UILabel *titleLabel;
    UIView *parentView;
    UIEdgeInsets insets;
    UIView *header_view;
    popup_state stateAlert;
    UIImageView *main_img;
    UIView *star_rate_view;
    UIView *underViewBlock;
    UIButton *actionBtn;
    int cur_stars;
    int count_stars;
    float distance;
    float topOffset;
}
@property (nonatomic, copy) void (^collbackBlock)(BOOL close);
@property (nonatomic, copy) void (^collbackAnimationBlock)(BOOL complatedAnimation);
@end



@implementation iRateAppPopup

-(iRateAppPopup*)initRatePopupWithParentView:(UIView*)parent{
    [self initData];
    
    parentView = parent;
    insets = UIEdgeInsetsMake(10, 10, 10, 10);
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 220)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self configurteViewWithEdges:insets];
    }
    return self;
}


-(iRateAppPopup*)initRatePopupWithParentView:(UIView*)parent withRootInsets:(UIEdgeInsets)edge{
    [self initData];
    parentView = parent;
    insets = edge;
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 220)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self configurteViewWithEdges:insets];
    }
    return self;
}


-(void)initData{
    cur_stars = 0;
    stateAlert = popup_state_empty;
    count_stars = 5;
    distance = 10.0;
}


-(void)updateView{
    [self initData];
    [self setRate:cur_stars];
}


-(void)showPopup:(BOOL)show withAnimation:(BOOL)animated underView:(UIView*)underView withTopOffset:(float)offset withCallback:(void(^)(BOOL close))onClose onComplateAnimation:(void(^)(BOOL complatedAnimation))complatedAnimation{
    
    _collbackBlock = onClose;
    _collbackAnimationBlock = complatedAnimation;
    topOffset = offset;
    underViewBlock = underView;
    float duration = (animated)?0.3:0;
    if (show) {
        if (!self.superview) {
            [UIView animateWithDuration:duration animations:^{
                [self upViews:YES value:self.frame.size.height];
                [parentView addSubview:self];
                self.frame = RectSetY(self.frame, topOffset);
            } completion:^(BOOL finished) {
                if (_collbackAnimationBlock) {
                    _collbackAnimationBlock(YES);
                }
            }];
        }else{
            if (_collbackAnimationBlock) {
                _collbackAnimationBlock(YES);
            }
        }
    }else{
        
        if (!self.superview) {
            if (_collbackBlock) {
                _collbackBlock(YES);
            }
        }
        
        
        float cur_chart_y = underView.frame.origin.y;
        if (cur_chart_y != topOffset) {
            float edge = underView.frame.origin.y - topOffset;
            [UIView animateWithDuration:duration animations:^{
                [self upViews:NO value:edge];
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if (_collbackBlock) {
                    _collbackBlock(YES);
                }
            }];
        }else{
            if (_collbackBlock) {
                _collbackBlock(YES);
            }
        }
    }
    
}




-(void)upViews:(BOOL)up value:(float)value{
    for (UIView *view in [parentView subviews]) {
        view.frame = RectSetY(view.frame, view.frame.origin.y + ((up)?value:(-value)));
    }
}















-(void)configurteViewWithEdges:(UIEdgeInsets)edge{
    //float padding = 10;
    
    if (!coverView) {
        coverView = [[UIView alloc] initWithFrame:CGRectMake(edge.left, edge.top, self.frame.size.width - (edge.left + edge.right), self.frame.size.height)];
        coverView.backgroundColor = [UIColor colorWithHex:@"#f6f8fb" alpha:1.0];
        
        coverView.layer.masksToBounds = NO;
        coverView.layer.shadowOffset = CGSizeMake(0,0.5);
        coverView.layer.shadowRadius = 1;
        coverView.layer.shadowOpacity = 0.2;
    }
    
    
    if (!closePopup) {
        closePopup = [UIButton buttonWithType:UIButtonTypeCustom];
        [closePopup setFrame:CGRectMake(0, 0, 41, 37)];
        [closePopup setImage:[UIImage imageNamed:@"closeAuthPopup"] forState:UIControlStateNormal];
        [closePopup addTarget:self action:@selector(closePopup) forControlEvents:UIControlEventTouchUpInside];
        [coverView addSubview:closePopup];
    }
    
    
    [header_view removeFromSuperview];
    header_view = [self headerView:stateAlert forCover:coverView];
    [coverView addSubview:header_view];
    
    //
    [main_img removeFromSuperview];
    main_img = [self imageView:stateAlert forCover:coverView];
    main_img.frame = RectSetOrigin(main_img.frame, (coverView.frame.size.width - main_img.frame.size.width)/2, CGRectGetMaxY(header_view.frame));
    [coverView addSubview:main_img];
    
    //
    
    if (!star_rate_view) {
        [self getStarsViewForCover:coverView];
        [coverView addSubview:star_rate_view];
    }
    star_rate_view.frame = RectSetOrigin(star_rate_view.frame, (coverView.frame.size.width - star_rate_view.frame.size.width)/2, CGRectGetMaxY(main_img.frame) + 8);
    
    //
    
    [actionBtn removeFromSuperview];
    actionBtn = nil;
    actionBtn = [self getActionButtonForCover:coverView andState:stateAlert];
    [coverView addSubview:actionBtn];
    
    [actionBtn setFrame:CGRectMake(20, CGRectGetMaxY(star_rate_view.frame) + 17, coverView.frame.size.width - 40, 41.0)];
    
    
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
    
    float maxY = [self getMaxYInView:coverView];
    float lastElementBottonPadding = 20;
    
    coverView.frame = RectSetHeight(coverView.frame, maxY + lastElementBottonPadding);
    self.frame = RectSetHeight(self.frame, CGRectGetHeight(coverView.frame) + (edge.top + edge.bottom));
    [self addSubview:coverView];
}




-(float)getMaxYInView:(UIView*)view{
    float maxY = 0;
    for (UIView *v in [view subviews]) {
        if (CGRectGetMaxY(v.frame) > maxY) {
            maxY = CGRectGetMaxY(v.frame);
        }
    }
    return maxY;
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
    [self configurteViewWithEdges:insets];
}


#pragma mark - actions

-(void)closePopup{
    [[iRateMind sharedInstance] userDenyAction];
    [self showPopup:NO withAnimation:YES underView:underViewBlock withTopOffset:topOffset withCallback:_collbackBlock onComplateAnimation:_collbackAnimationBlock];
}


-(void)writeDeveloper{
    [[iRateMind sharedInstance] userWriteSupportAction];
    [self showPopup:NO withAnimation:YES underView:underViewBlock withTopOffset:topOffset withCallback:_collbackBlock onComplateAnimation:_collbackAnimationBlock];
}

-(void)rateApplication{
    [[iRateMind sharedInstance] userRateAction:cur_stars];
    [self showPopup:NO withAnimation:YES underView:underViewBlock withTopOffset:topOffset withCallback:_collbackBlock onComplateAnimation:_collbackAnimationBlock];
}


@end
