//
//  YTUrlInput.m
//  ytdownloader
//
//  Created by Nate Edwards on 2/14/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import "YTUrlInputVC.h"
#import "YTDownloadVideo.h"
#import "UIImage+animatedGIF.h"

#import <Photos/Photos.h>
#import <AFNetworking.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <SVProgressHUD.h>
#import <IQKeyboardManager.h>

@interface YTUrlInputVC ()
@property (nonatomic) UIView *dontFake;
@property (strong, nonatomic) IBOutlet UILabel *formHeaderLabel;
@property (strong, nonatomic) IBOutlet UILabel *formHelperLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *formVideoInfoIndicator;
@property (nonatomic) YTGetVideoProps *ytGetVideo;
@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (strong, nonatomic) IBOutlet UIButton *getVideoButton;
@property (nonatomic) NSTimer *startDontFakeTheFunkTimer;

@end

@implementation YTUrlInputVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.youtubeUrlField.delegate = self;
    
    self.formHelperLabel.hidden = YES;
    self.getVideoButton.hidden = YES;
    
    
    [self getPermissions];
    [self setupView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadCompleted:)
                                                 name:@"downloadComplete"
                                            object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadStarted:)
                                                 name:@"downloadStarted"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadHUDDismissed:)
                                                 name:SVProgressHUDDidDisappearNotification
                                               object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"downloadComplete"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"downloadStarted"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SVProgressHUDDidDisappearNotification
                                                  object:nil];
}


#pragma mark - Notifications

-(void)downloadStarted:(NSNotification *)note
{
    NSString *videoTitle = [self returnShortVideoTitle:[[note userInfo] valueForKey:@"video_title"]];
    
    NSString *videoDownloadingWithTitle = [NSString stringWithFormat:@"Downloading\r%@", videoTitle];
    NSData *videoThumbnailData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:[[note userInfo] valueForKey:@"video_thumbnail"]]]];
    
    UIImage *videoThumbnail = [[UIImage alloc] initWithData:videoThumbnailData];

    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setInfoImage:videoThumbnail];
    
    [SVProgressHUD showWithStatus:videoDownloadingWithTitle];
}

-(void)downloadCompleted:(NSNotification *)note
{
    [SVProgressHUD setMinimumDismissTimeInterval:1.0];
    [SVProgressHUD showSuccessWithStatus:@"Download Complete"];
}

-(void)downloadHUDDismissed: (NSNotification *)note
{
    self.youtubeUrlField.text = @"";
    [self.youtubeUrlField becomeFirstResponder];
}


#pragma mark - Permissions

-(void)getPermissions
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

    if (status == PHAuthorizationStatusAuthorized)
    {
        // Access has been granted.
        [self showKeyboard];
    }

    else if (status == PHAuthorizationStatusDenied)
    {
        // Access has been denied.
        self.youtubeUrlField.enabled = false;
    }

    else if (status == PHAuthorizationStatusNotDetermined)
    {
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
            
            if (status == PHAuthorizationStatusAuthorized)
            {
                // Access has been granted.
            }
            
            else
            {
                // Access has been denied.
            }
        }];
    }

    else if (status == PHAuthorizationStatusRestricted)
    {
        // Restricted access - normally won't happen.
    }
}

- (IBAction)sendVideoId:(id)sender
{
    
    [self.youtubeUrlField resignFirstResponder];
    
    YTGetVideoProps *getVideoManager = [[YTGetVideoProps alloc] init];
    if(self.youtubeUrlField.text.length > 0)
    {
        NSString *videoID = [self returnParsedURL:self.youtubeUrlField.text];
        
        if(videoID)
        {
            [self.youtubeUrlField resignFirstResponder];
            
            [self addTextFieldAlert:@"Gathering Video Information..." withDelay:90.0 andError:NO];
            self.formVideoInfoIndicator.hidden = FALSE;
            [self.formVideoInfoIndicator startAnimating];
            
            [getVideoManager getVideoWithID:videoID completion:^(BOOL success)
            {
                [self clearTextFieldAlert];
                
                if(success)
                {
                    YTDownloadVideo *downloadManager = [[YTDownloadVideo alloc] init];
                    [downloadManager downloadVideo];
                }
                else
                {
                    [self showKeyboard];
                    
                    [self addTextFieldAlert:@"Invalid YouTube link. Try again..." withDelay:1.50 andError:YES];
                }
            }];
        }
    }
}

#pragma mark - Custom Methods

-(void)addTextFieldAlert: (NSString *)alertString withDelay: (double)delayInSeconds andError: (BOOL)error
{
    UIColor *statusColor = error ? [UIColor colorWithRed:0.8 green:0.094 blue:0.118 alpha:.70]: [UIColor colorWithRed:0.792 green:0.792 blue:0.792 alpha:1];

    self.youtubeUrlField.text = @"";
    self.youtubeUrlField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:alertString attributes:@{NSForegroundColorAttributeName: statusColor}];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        self.youtubeUrlField.placeholder = @"Enter a youtu.be or youtube.com link";
        [self.youtubeUrlField becomeFirstResponder];
        self.formVideoInfoIndicator.hidden = TRUE;
    });
}

-(void)clearTextFieldAlert
{
    self.youtubeUrlField.placeholder = @"Enter a youtu.be or youtube.com link";
    self.formVideoInfoIndicator.hidden = YES;
}

-(NSString *)returnParsedURL: (NSString *)fieldString{
    
    if([fieldString containsString:@"youtu.be"])
    {
        NSRange rangeValue = [fieldString rangeOfString:@"youtu.be/" options:NSCaseInsensitiveSearch];
        fieldString = [fieldString substringFromIndex:rangeValue.length + rangeValue.location];
        NSLog(@"fieldString: %@", fieldString);
    }
    else if([fieldString containsString:@"youtube.com/watch?v="])
    {
        NSRange rangeValue = [fieldString rangeOfString:@"youtube.com/watch?v=" options:NSCaseInsensitiveSearch];
        fieldString = [fieldString substringFromIndex:rangeValue.length + rangeValue.location];
        NSLog(@"fieldString: %@", fieldString);
    }
    else if([fieldString isEqualToString: @"dontfakethefunk!"])
    {
        self.youtubeUrlField.text = @"Really?! Why'd you go and do that...";
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.75 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
        {
            [self DontFakeTheFunkErrorKickOff];
        });
        
        return 0;
    }
    else
    {
        [self addTextFieldAlert:@"Link was not a valid YouTube link!" withDelay:1.50 andError:YES];
        
        return 0;
        
    }
    
    return fieldString;
}

-(NSString *)returnShortVideoTitle: (NSString *)videoTitle
{
    if(videoTitle.length > 24)
    {
        NSString *shortVideoTitle = [[videoTitle substringToIndex:24] stringByAppendingString:@"..."];
        return shortVideoTitle;
    }
    else
    {
        return videoTitle;
    }
}


#pragma mark - Keyboard Handling

-(void)updateUrlField:(NSString *)updatedStringValue
{
    self.youtubeUrlField.text = updatedStringValue;
}

-(void)dismissKeyboard
{
    [self.youtubeUrlField resignFirstResponder];
}

-(void)showKeyboard
{
    double delayInSeconds = .40;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        self.youtubeUrlField.text = @"";
        [self.youtubeUrlField becomeFirstResponder];
    });
}


#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0)
    {
        [textField resignFirstResponder];
        [self sendVideoId:textField.text];
    }
    else
    {
        [self addTextFieldAlert:@"No link entered!" withDelay:.40 andError:YES];
    }
    
    return YES;
}

#pragma mark - Setup View

-(void)setupView
{
    //Clear statusbar
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1]; /*#f7f7f7*/
    
    self.formHeaderLabel.textColor = [UIColor whiteColor];
    
    //Textfield Setup
    self.youtubeUrlField.inputAccessoryView = [[UIView alloc] init]; //this removes IQKeyboardManager's toolbar
    self.youtubeUrlField.clearButtonMode = UITextFieldViewModeAlways;
    self.youtubeUrlField.backgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1];  /*#f2f2f2*/
    self.youtubeUrlField.borderStyle = UITextBorderStyleNone;
    self.youtubeUrlField.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium];
    self.youtubeUrlField.textColor = [UIColor colorWithRed:0.502 green:0.502 blue:0.502 alpha:1]; /*#808080*/
    self.youtubeUrlField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter a youtu.be or youtube.com link" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.792 green:0.792 blue:0.792 alpha:1]}];
    
    self.youtubeUrlField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.youtubeUrlField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.youtubeUrlField.tintColor = [UIColor colorWithRed:0.8 green:0.094 blue:0.118 alpha:1]; /*#cc181e*/
    
    //Textfield set inset with spacer view
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    [self.youtubeUrlField setLeftViewMode:UITextFieldViewModeAlways];
    [self.youtubeUrlField setLeftView:spacerView];
    
    //Activity Indicator
    self.formVideoInfoIndicator.tintColor = [UIColor colorWithRed:0.792 green:0.792 blue:0.792 alpha:1];
    self.formVideoInfoIndicator.hidden = YES;
    
    //Background Image Context
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"background"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    self.youtubeUrlField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.youtubeUrlField.keyboardType = UIKeyboardTypeWebSearch;
    self.youtubeUrlField.returnKeyType = UIReturnKeySend;
    
    [self addTwoFingersSettingTap];
}


#pragma mark - ActionSheet Quality

-(void)addTwoFingersSettingTap
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popSettingsSheet)];
    [tapRecognizer setNumberOfTapsRequired:2];
    [tapRecognizer setNumberOfTouchesRequired:2];
    [[self view] addGestureRecognizer:tapRecognizer];
}

-(void)popSettingsSheet
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Download Settings" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
    {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    if([[defaults objectForKey:@"videoQuality"] isEqualToString:@"hd"])
    {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Switch to SD" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"standard" forKey:@"videoQuality"];
            [defaults synchronize];
            
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    }
    else
    {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Switch to HD" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"hd" forKey:@"videoQuality"];
            [defaults synchronize];
            
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}


#pragma mark - Dont Fake the Funk!

-(void)DontFakeTheFunkErrorKickOff
{
    
    self.startDontFakeTheFunkTimer = [NSTimer scheduledTimerWithTimeInterval:.10
                                       target:self
                                     selector:@selector(timedDontFakeTheFunkMessage)
                                     userInfo:nil
                                      repeats:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:8.0
                                     target:self
                                   selector:@selector(popDontFakeTheFunkView)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)timedDontFakeTheFunkMessage
{
    
    int r = 18 + arc4random() % (32 - 18);
    self.youtubeUrlField.text = [self randomStringWithLength:r];
}

-(void)popDontFakeTheFunkView
{
    //Clear out silly textfield stuff
    self.youtubeUrlField.text = @"SASQUATCH(taco) RETURN END";
    [self.startDontFakeTheFunkTimer invalidate];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.25 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        self.dontFake = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        UIImageView *dontFakeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        dontFakeView.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"dontfakethefunk" withExtension:@"gif"]]];
        UIButton *closeDontFake = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [closeDontFake setTitle:@"" forState:UIControlStateNormal];
        [closeDontFake addTarget:self action:@selector(closeDontFakeTheFunk) forControlEvents:UIControlEventTouchUpInside];
        [self.dontFake addSubview:dontFakeView];
        [self.dontFake addSubview:closeDontFake];
        [self.view addSubview:self.dontFake];

    });
}

-(void)closeDontFakeTheFunk
{
    [_dontFake removeFromSuperview];
    self.youtubeUrlField.text = @"";
    [self showKeyboard];
}

-(NSString *)randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}


@end
