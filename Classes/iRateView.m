//
//  iRateView.m
//
//  Created by iSerg on 5/7/15.
//  Copyright (c) 2015 Arthur Hemmer. All rights reserved.
//

#import "iRateView.h"
#import "iRateMind.h"
#import "UIDevice+machine.h"

#define MainScreenWidht (([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height)?[UIScreen mainScreen].bounds.size.width:[UIScreen mainScreen].bounds.size.height)

#define MainScreenHeight (([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height)?[UIScreen mainScreen].bounds.size.height:[UIScreen mainScreen].bounds.size.width)

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


static NSString *id_application_key = @"trackIdKey";






- (UIViewController *)parentViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
    //return self.parentVC;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.backgroundColor = [UIColor clearColor];
    [self initData];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    return self;
}

-(void)initData{
    cur_stars = 0;
    stateAlert = popup_state_empty;
    
    /*[YMMYandexMetrica reportEvent:@"CatRate"
                        onFailure:^(NSError *error) {
                            NSLog(@"REPORT ERROR: %@", [error localizedDescription]);
                        }];*/
    
}




-(void)clearView{
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
}



- (void)drawRect:(CGRect)rect{
    [self clearView];
    [self setAlpha:0];
    [UIView animateWithDuration:0.1 animations:^{
        [self setAlpha:1];
    }];
    
    cur_stars = 0;
    
    self.backgroundColor = [UIColor clearColor];
    
    
    if (IS_IPAD) {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown) {
            
            self.frame = CGRectMake(0, 0, MainScreenHeight, MainScreenWidht);
            
            
            //alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidht, MainScreenHeight)];
        }else{
            //alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainScreenHeight, MainScreenWidht)];
            self.frame = CGRectMake(0, 0, MainScreenWidht, MainScreenHeight);
        }
    }
    
    alphaView = [[UIView alloc] initWithFrame:self.frame];
    
    
    
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        alphaView.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = alphaView.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blurEffectView.alpha = 0.85;
        [alphaView addSubview:blurEffectView];
    } else {
        alphaView.backgroundColor = [UIColor blackColor];
        alphaView.alpha = 0.4;
    }
    
    
    
    //alphaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    [alphaView removeFromSuperview];
    
    
    
    
    
    alphaView.frame = self.frame;
    
    [self addSubview:alphaView];
    
    
    UIView *rate_v = [self rateView];
    rate_v.center = self.center;
    
    alphaView.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview:rate_v];
    [self setRate:cur_stars];
}



- (void) didRotate:(NSNotification *)notification
{  
    return;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    
    [self setNeedsDisplay];
    
    
    if (orientation == UIDeviceOrientationLandscapeLeft)
    {
        NSLog(@"Landscape Left!");
    }
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
            
            
            
            
            
            NSMutableAttributedString *stringForRecom = [[NSMutableAttributedString alloc] initWithString: [self localizedStringForKey:@"iRateView_do_you_like" withDefault:@"Вам нравится приложение?"] attributes: @{NSParagraphStyleAttributeName : paragraphStyle_big_title, NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeueCyr-Roman" size:(IS_IPAD)?30.0:20.0]}];
            
            UILabel *like_app = [[UILabel alloc] initWithFrame:CGRectMake(0, (IS_IPAD)?-4.5:0, view.frame.size.width, (IS_IPAD)?80:50)];
            
            [like_app setAttributedText:stringForRecom];
            
            like_app.font = [UIFont fontWithName:@"HelveticaNeueCyr-Roman" size:(IS_IPAD)?30.0:20.0];
            like_app.textAlignment = NSTextAlignmentCenter;
            like_app.numberOfLines = 2;
            like_app.textColor = [UIColor colorWithHex:@"189395" alpha:1.0];
            [view addSubview:like_app];
            return view;
            break;}
        case popup_state_bad_choise:{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, (IS_IPAD)?19+9:19, cover.frame.size.width - 40, 70+((IS_IPAD)?-9:0))];
            UILabel *thanksTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, (IS_IPAD)?30:25)]; 
            
            
            
            
            thanksTitle.text = [self localizedStringForKey:@"iRateView_what_happened" withDefault:@"Что случилось?"];
            thanksTitle.font = [UIFont fontWithName:@"HelveticaNeueCyr-Roman" size:(IS_IPAD)?30:20.0];
            thanksTitle.textAlignment = NSTextAlignmentCenter;
            thanksTitle.numberOfLines = 1;
            thanksTitle.textColor = [UIColor colorWithHex:@"189395" alpha:1.0];
            [view addSubview:thanksTitle];
            
            
            
            
            NSMutableAttributedString *atrStr = [[NSMutableAttributedString alloc] initWithString: [self localizedStringForKey:@"iRateView_what_please_write" withDefault:@"Пожалуйста, напишите, как мы\nможем улучшить приложение"] attributes: @{NSParagraphStyleAttributeName : paragraphStyle_2, NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeueCyr-Roman" size:(IS_IPAD)?22:15.0]}];
            
            UILabel *thanksTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(thanksTitle.frame)+((IS_IPAD)?2.5:0), view.frame.size.width, (IS_IPAD)?60:45)];
            [thanksTitle2 setAttributedText:atrStr];
            
            
            thanksTitle2.font = [UIFont fontWithName:@"HelveticaNeueCyr-Roman" size:(IS_IPAD)?22:15.0];
            thanksTitle2.textAlignment = NSTextAlignmentCenter;
            thanksTitle2.numberOfLines = 2;
            thanksTitle2.textColor = [UIColor colorWithHex:@"5d7185" alpha:1.0];
            [view addSubview:thanksTitle2];
            return view;
            break;}
        case popup_state_good_choise:{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 19, cover.frame.size.width - 40, 70)];
            UILabel *thanksTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, (IS_IPAD)?9:0, view.frame.size.width, (IS_IPAD)?30:25)];
            
            thanksTitle.text = [self localizedStringForKey:@"iRateView_good" withDefault:@"Отлично! Спасибо!"];
            thanksTitle.font = [UIFont fontWithName:@"HelveticaNeueCyr-Roman" size:(IS_IPAD)?30:20.0];
            thanksTitle.textAlignment = NSTextAlignmentCenter;
            thanksTitle.numberOfLines = 1;
            thanksTitle.textColor = [UIColor colorWithHex:@"189395" alpha:1.0];
            [view addSubview:thanksTitle];
            
            
            NSMutableAttributedString *atrStr = [[NSMutableAttributedString alloc] initWithString: [self localizedStringForKey:@"iRateView_support" withDefault:@"Поддержите приложение,\nоставьте отзыв в App Store"] attributes: @{NSParagraphStyleAttributeName : paragraphStyle_2, NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeueCyr-Roman" size:(IS_IPAD)?22:15.0]}];
            
            UILabel *thanksTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(thanksTitle.frame)+((IS_IPAD)?2.5:0), view.frame.size.width, (IS_IPAD)?60:45)];
            
            [thanksTitle2 setAttributedText:atrStr];
            
            thanksTitle2.font = [UIFont fontWithName:@"HelveticaNeueCyr-Roman" size:(IS_IPAD)?22:15.0];
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
    //star_rate_view.backgroundColor = [UIColor redColor];
    return star_rate_view;
}



#pragma mark - Gesture

-(IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:star_rate_view];
    //NSLog(@"%@",NSStringFromCGPoint(point));
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
            
            
            
            
            
            [action_button setTitle:[self localizedStringForKey:@"iRateView_rate_app" withDefault:@"Оцените приложение"] forState:UIControlStateNormal];
            action_button.backgroundColor = [UIColor colorWithHex:@"e5e8e8" alpha:1.0];
            [action_button setTitleColor:[UIColor colorWithHex:@"5d7185" alpha:1.0] forState:UIControlStateNormal];
            action_button.userInteractionEnabled = NO;
            break;}
        case popup_state_bad_choise:{
            
            [action_button setTitle:[self localizedStringForKey:@"iRateView_write_support" withDefault:@"Написать разработчику"] forState:UIControlStateNormal];
            [action_button setBackgroundImage:[UIImage imageNamed:@"rate_action_btn_bg"] forState:UIControlStateNormal];
            [action_button setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
            break;}
        case popup_state_good_choise:{
            [action_button setTitle:[self localizedStringForKey:@"iRateView_rate" withDefault:@"Оставить отзыв"] forState:UIControlStateNormal];
            [action_button setBackgroundImage:[UIImage imageNamed:@"rate_action_btn_bg"] forState:UIControlStateNormal];
            [action_button setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
            break;}
        default:
            break;
    }
    
    
    
    action_button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Roman" size:(IS_IPAD)?27:18.0];
    //
    action_button.layer.cornerRadius = 5.0;
    action_button.clipsToBounds = YES;
    return action_button;
}

-(UCButton*)getCancelButtonForCover:(UIView*)cover{
    UCButton *cancel_button = [UCButton buttonWithType:UIButtonTypeCustom];
    [cancel_button setFrame:CGRectMake(0, 0, cover.frame.size.width, (IS_IPAD)?50:32)];
    [cancel_button addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    [cancel_button setTitle:[self localizedStringForKey:@"iRateView_cancel" withDefault:@"Отмена"] forState:UIControlStateNormal];
    [cancel_button setTitleColor:[UIColor colorWithHex:@"515151" alpha:1.0] forState:UIControlStateNormal];
    [cancel_button setTitleColor:[UIColor colorWithHex:@"515151" alpha:0.8] forState:UIControlStateHighlighted];
    if (IS_IPAD){
        cancel_button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Roman" size:(IS_IPAD)?30:20.0];
    }
    //cancel_button.backgroundColor = [UIColor redColor];
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
        separ = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(actionBtn.frame) + 10, cover.frame.size.width, 1)];
        [cover addSubview:separ];
        separ.backgroundColor = [UIColor colorWithHex:@"c2c5c5" alpha:1.0];
    }
    
    
    
    //
    if (!cancelBtn) {
        cancelBtn = [self getCancelButtonForCover:cover];
        [cover addSubview:cancelBtn];
    }
    [cancelBtn setFrame:CGRectMake(0, CGRectGetMaxY(separ.frame) + 5, cover.frame.size.width, 32.0)];
    
    
    return cover;
}




-(UIView*)coverForIPad{
    //
    if (!cover) {
        cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 436, 638)];
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
    [cancelBtn setFrame:CGRectMake(0, CGRectGetMaxY(separ.frame) + 4, cover.frame.size.width, 50.0)];
    
    
    return cover;
}






#pragma mark - button action

-(void)writeDeveloper{
    //NSLog(@"writeDeveloper");
    [[iRateMind sharedInstance] userWriteSupport];
    UIViewController *vc = [self parentViewController];
    if (vc) {
        [self supportMail];
    }
    [self removeFromSuperview];
}



-(void)rateApplication{
    //NSLog(@"rateApplication");
    
    /*[YMMYandexMetrica reportEvent:@"CatRate-AppStore"
                        onFailure:^(NSError *error) {
                            NSLog(@"REPORT ERROR: %@", [error localizedDescription]);
                        }
     ];
    
    
    [YMMYandexMetrica reportEvent:[NSString stringWithFormat:@"CatRate-%i",cur_stars]
                        onFailure:^(NSError *error) {
                            NSLog(@"REPORT ERROR: %@", [error localizedDescription]);}
     ];*/
    
    
    
    
    [[iRateMind sharedInstance] userRated];
    [self checkApplicationID:^(bool complate) {
        if (complate) {
            if ([UserDefaults objectForKey:id_application_key]) {
                
                NSString *URLString;
                NSString *iRateiOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%@";
                NSString *iRateiOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
                
                float iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
                if (iOSVersion >= 7.0f && iOSVersion < 7.1f)
                {
                    URLString = iRateiOS7AppStoreURLFormat;
                }
                else
                {
                    URLString = iRateiOSAppStoreURLFormat;
                }
                NSURL *ratingsURL = [NSURL URLWithString:[NSString stringWithFormat:URLString, [UserDefaults objectForKey:id_application_key]]];
                
                if ([[UIApplication sharedApplication] canOpenURL:ratingsURL])
                {
                    [[UIApplication sharedApplication] openURL:ratingsURL];
                }                
            }
        }
    }];
    [self removeFromSuperview];
}


-(void)cancelAction{
    [[iRateMind sharedInstance] userDeny];
    [self removeFromSuperview];
}


#pragma mark - MFMailComposeViewController

- (void)supportMail{
    if ([MFMailComposeViewController canSendMail]) {
        
        /*[YMMYandexMetrica reportEvent:@"CatRate-Contact"
                            onFailure:^(NSError *error) {
                                NSLog(@"REPORT ERROR: %@", [error localizedDescription]);
                            }];*/
        
        
        MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = (id)self;
        [mailController setToRecipients:[NSArray arrayWithObjects:@"support@owlylabs.com",nil]];
        [mailController setSubject:[NSString stringWithFormat:@"%@ (iOS). Тех. поддержка",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] ]];
        [mailController.navigationBar setTintColor:RGB(39, 175, 195)];
        
        NSMutableString *seriaDevice = [[NSMutableString alloc] initWithCapacity:10];
        [seriaDevice appendString:[[UIDevice currentDevice] machine]];
        
        [seriaDevice replaceOccurrencesOfString:@"," withString:@"."
                                        options:NSCaseInsensitiveSearch range:NSMakeRange(0, seriaDevice.length)];
        [seriaDevice replaceOccurrencesOfString:@"iPhone" withString:@"iPhone "
                                        options:NSCaseInsensitiveSearch range:NSMakeRange(0, seriaDevice.length)];
        [seriaDevice replaceOccurrencesOfString:@"iPod" withString:@"iPod "
                                        options:NSCaseInsensitiveSearch range:NSMakeRange(0, seriaDevice.length)];
        [seriaDevice replaceOccurrencesOfString:@"iPad" withString:@"iPad "
                                        options:NSCaseInsensitiveSearch range:NSMakeRange(0, seriaDevice.length)];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        [mailController setMessageBody:[NSString stringWithFormat:@"Здравствуйте, Owly Labs\n\n\nУстройство:\n %@ \n iOS %@ \n%@ %@", seriaDevice, [[UIDevice currentDevice] systemVersion],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"], version] isHTML:NO];
        
        
        [[self parentViewController] presentViewController:mailController animated:YES completion:nil];
        
    }else {
        [[[UIAlertView alloc] initWithTitle:@"" message:[self localizedStringForKey:@"iRateView_error_email_settings" withDefault:@"Для отправки сообщения необходимо авторизировать почтовый ящик"] delegate:self cancelButtonTitle:[self localizedStringForKey:@"iRateView_support_close" withDefault:@"Закрыть"] otherButtonTitles:nil] show];
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
    
    if ([UserDefaults objectForKey:id_application_key]) {
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
                        [UserDefaults setObject:[self valueForKey:@"trackId" inJSON:json] forKey:id_application_key];
                        
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


#pragma mark - localize


- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"iRateCat" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}

#pragma mark -


@end

