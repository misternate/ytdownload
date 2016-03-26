//
//  TYURLPaths.m
//  ytdownloader
//
//  Created by Nate Edwards on 3/13/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import "YTURLPaths.h"
//172.27.5.24
//192.168.0.254
@implementation YTURLPaths
NSString * const YOUTUBE_GETVIDEO_URL = @"http://192.168.0.254/ytdownload/getvideo.php?videoid=";

-(NSString *)getVideoPropsURL:(NSString *)videoId{
    NSString *videoPropsURL = [NSString stringWithFormat:@"%@%@&format=ipad", YOUTUBE_GETVIDEO_URL, videoId];
    
    return videoPropsURL;
}

@end
