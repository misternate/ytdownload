//
//  YTUrlInput.m
//  ytdownloader
//
//  Created by Nate Edwards on 2/14/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import "YTUrlInputVC.h"
#import "YTDownloadVideo.h"

#import <Photos/Photos.h>
#import <AFNetworking.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <SVProgressHUD.h>
#import <IQKeyboardManager.h>

@interface YTUrlInputVC ()

@property (strong, nonatomic) IBOutlet UILabel *formHeaderLabel;
@property (strong, nonatomic) IBOutlet UILabel *formHelperLabel;
@property (nonatomic) YTGetVideoProps *ytGetVideo;
@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (strong, nonatomic) IBOutlet UIButton *getVideoButton;

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

-(void)downloadStarted:(NSNotification *)note
{
    NSString *videoTitle = [[note userInfo] valueForKey:@"video_title"];
    NSString *shortVideoTitle = [[videoTitle substringToIndex:24] stringByAppendingString:@"..."];
    NSString *videoDownloadingWithTitle = [NSString stringWithFormat:@"Downloading\r%@", shortVideoTitle];
    NSData *videoThumbnailData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:[[note userInfo] valueForKey:@"video_thumbnail"]]]];
    
    UIImage *videoThumbnial = [[UIImage alloc] initWithData:videoThumbnailData];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setInfoImage:videoThumbnial];
    
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

- (IBAction)sendVideoId:(id)sender {
    
    [self.youtubeUrlField resignFirstResponder];
    
    YTGetVideoProps *getVideoManager = [[YTGetVideoProps alloc] init];
    if(self.youtubeUrlField.text.length > 0)
    {
        NSString *videoID = [self returnParsedURL:self.youtubeUrlField.text];
        
        if(videoID)
        {
            [getVideoManager getVideoWithID:videoID completion:^(BOOL success)
            {
                if(success)
                {
                    YTDownloadVideo *downloadManager = [[YTDownloadVideo alloc] init];
                    [downloadManager downloadVideo];
                    
    //                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //                UIViewController *videoPreview = [mainStoryboard instantiateViewControllerWithIdentifier:@"videoPreviewViewController"];
    //                [self presentViewController:videoPreview animated:YES completion:nil];
                }
                else
                {
                    [self showKeyboard];
                    
                    UIAlertController *blankFieldAlert = [UIAlertController alertControllerWithTitle: @"Download Failed!"
                                                                                             message: @"Please check your link"
                                                                                      preferredStyle: UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [blankFieldAlert addAction:defaultAction];
                    
                    [self presentViewController:blankFieldAlert animated:YES completion:nil];
                }
            }];
        }
    }
}

-(NSString *)returnParsedURL: (NSString *)fieldString{
    
    if([fieldString containsString:@"youtu.be"])
    {
        NSRange rangeValue = [fieldString rangeOfString:@"youtu.be/" options:NSCaseInsensitiveSearch];
        fieldString = [fieldString substringFromIndex:rangeValue.length + rangeValue.location];
        NSLog(@"fieldString: %@", fieldString);
    }
    else if([fieldString containsString:@"youtube.com"])
    {
        NSRange rangeValue = [fieldString rangeOfString:@"youtube.com/watch?v=" options:NSCaseInsensitiveSearch];
        fieldString = [fieldString substringFromIndex:rangeValue.length + rangeValue.location];
        NSLog(@"fieldString: %@", fieldString);
    }
    else
    {
        [self addTextFieldAlert:@"Invalid link entered!" withDelay:.750];
        return 0;

    }
    
    return fieldString;
}

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
    
    //Background Image Context
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"background"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    //Keyboard Setup and Actions
    UITapGestureRecognizer *dismissKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:dismissKeyboardTap];
    self.youtubeUrlField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.youtubeUrlField.keyboardType = UIKeyboardTypeWebSearch;
    self.youtubeUrlField.returnKeyType = UIReturnKeySend;
    
    NSLog(@"frame width: %f // frame height: %f", self.view.frame.size.height, self.view.frame.size.width);
}

#pragma mark - Custom Methods

-(void)addTextFieldAlert: (NSString *)alertString withDelay: (double)delayInSeconds
{
    self.youtubeUrlField.text = @"";
    self.youtubeUrlField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:alertString attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.8 green:0.094 blue:0.118 alpha:.70]}];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
       self.youtubeUrlField.placeholder = @"Enter a youtu.be or youtube.com link";
       [self.youtubeUrlField becomeFirstResponder];
    });
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
        [self addTextFieldAlert:@"No link entered!" withDelay:.40];
    }
    
    return YES;
}

@end
