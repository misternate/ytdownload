//
//  YTNetworkVideoId.m
//  ytdownloader
//
//  Created by Nate Edwards on 2/14/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import "YTGetVideoProps.h"
#import "YTVideoDataModel.h"
#import "YTURLPaths.h"
#import "YTDownloadVideo.h"

#import <AFNetworking.h>

@implementation YTGetVideoProps

- (void)getVideoWithID:(NSString *)videoId completion:(void (^)(BOOL success))completion
{
    YTURLPaths *ytURLPaths = [[YTURLPaths alloc] init];
    NSString *youtubeVideoIdUrl = [ytURLPaths getVideoPropsURL:videoId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [manager GET:youtubeVideoIdUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *videoResponseObject = [[responseObject objectForKey:@"data"] objectAtIndex:0];
        YTVideoDataModel *videoDataModel = [YTVideoDataModel getInstance];
        [videoDataModel setVideoModel:videoResponseObject];
        
        
//        YTVideoModel *videoModel = [[YTVideoModel alloc] init];
//        videoModel.video_file = [NSURL URLWithString: [[videoResponseObject valueForKey:@"video_file"] objectAtIndex:0]];
//        videoModel.video_thumbnail = [[videoResponseObject valueForKey:@"video_file"] objectAtIndex:0];
//        videoModel.video_title = [[videoResponseObject valueForKey:@"video_title"] objectAtIndex: 0];
        
        completion(YES);
        
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        completion(NO);

    }];
}

@end
