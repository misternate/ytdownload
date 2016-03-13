//
//  YTUrlInput.m
//  ytdownloader
//
//  Created by Nate Edwards on 2/14/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import "YTUrlInputVC.h"
//#import "YTGetVideo.h"
#import <Photos/Photos.h>
#import <AFNetworking.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface YTUrlInputVC ()

@property (nonatomic) YTGetVideoProps *ytGetVideo;
@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgressView;

@end

@implementation YTUrlInputVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.youtubeUrlField.placeholder = @"enter youtube url";
    [self getPermissions];
}

-(void)viewWillAppear:(BOOL)animated
{

}

-(void)viewWillDisappear:(BOOL)animated
{

}

-(void)getPermissions
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

    if (status == PHAuthorizationStatusAuthorized)
    {
        // Access has been granted.
        [self.youtubeUrlField becomeFirstResponder];
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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (object == self.ytGetVideo && [keyPath isEqualToString:@"percentageOfFileDownloaded"]) {
        float percentage = [keyPath isEqualToString:@"percentageOfFileDownloaded"];
        NSLog(@"file download percentage: %f", percentage);
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.youtubeUrlField.text = @"";
    self.youtubeUrlField.placeholder = @"";
    return 0;
}

- (IBAction)sendVideoId:(id)sender {
    YTGetVideoProps *getVideoManager = [[YTGetVideoProps alloc] init];
    //[getVideoManager getVideoWithID:self.youtubeUrlField.text];
    if(self.youtubeUrlField.text.length > 0)
    {
        [getVideoManager getVideoWithID:self.youtubeUrlField.text completion:^(BOOL success) {
            if(success)
            {
                //
                //[self performSegueWithIdentifier:@"toVideoPreviewVC" sender:self];
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *videoPreview = [mainStoryboard instantiateViewControllerWithIdentifier:@"videoPreviewViewController"];
                [self presentViewController:videoPreview animated:YES completion:nil];
            }
            else
            {
                NSLog(@"getting video properties failed!");
            }
        }];
    }
    else
    {
        UIAlertController *blankFieldAlert = [UIAlertController alertControllerWithTitle: @"Blank Field!"
                                                                                 message: @"Please enter a valid field"
                                                                          preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [blankFieldAlert addAction:defaultAction];
        
        [self presentViewController:blankFieldAlert animated:YES completion:nil];
    }
    //[self getVideoWithID:self.youtubeUrlField.text];
}

#pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }


@end
