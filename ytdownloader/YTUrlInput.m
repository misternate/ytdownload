//
//  YTUrlInput.m
//  ytdownloader
//
//  Created by Nate Edwards on 2/14/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import "YTUrlInput.h"
#import <Photos/Photos.h>
#import "YTGetVideo.h"

@interface YTUrlInput ()

@end

@implementation YTUrlInput

- (void)viewDidLoad {
    [super viewDidLoad];
    self.youtubeUrlField.text = @"enter youtube url";
    
    [self getPermissions];
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

- (IBAction)sendVideoId:(id)sender {
    YTGetVideo *getVideoManager = [[YTGetVideo alloc] init];
    [getVideoManager getVideoWithID:self.youtubeUrlField.text];
}

@end
