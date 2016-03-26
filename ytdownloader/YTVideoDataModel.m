//
//  YTVideoDataModel.m
//  ytdownloader
//
//  Created by Nate Edwards on 3/13/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import "YTVideoDataModel.h"

@implementation YTVideoDataModel

static dispatch_once_t pred;
static YTVideoDataModel *videoDataModel;

+(YTVideoDataModel *)getInstance
{
    dispatch_once(&pred, ^{
        videoDataModel = [[YTVideoDataModel alloc] init];
    });
    
    return videoDataModel;
}

-(void)setVideoModel:(NSDictionary *)json
{
    videoModel = json;
};

-(NSDictionary *)getVideoModel
{
    return videoModel;
}

-(void)resetVideoModel
{
    videoModel = nil;
    NSLog(@"cleared out video model: %@", videoDataModel);
}

@end
