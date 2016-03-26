//
//  YTVideoPreviewVC.m
//  ytdownloader
//
//  Created by Nate Edwards on 3/13/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import "YTVideoPreviewVC.h"
#import "YTVideoDataModel.h"
#import <UIImageView+WebCache.h>

@interface YTVideoPreviewVC ()
@property (strong, nonatomic) IBOutlet UILabel *videoTitle;
@property (strong, nonatomic) IBOutlet UIImageView *videoThumbnail;

@end

@implementation YTVideoPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    YTVideoDataModel *videoDataModel = [YTVideoDataModel getInstance];
    self.videoTitle.text = [[videoDataModel getVideoModel] valueForKey:@"video_title"];
    [self.videoThumbnail sd_setImageWithURL:[[videoDataModel getVideoModel] valueForKey:@"video_thumbnail"] placeholderImage:nil];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
