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
//https://ytdownloader.herokuapp.com/
@implementation YTURLPaths
NSString * const YOUTUBE_GETVIDEO_URL = @"https://ytdownloader.herokuapp.com/getvideo.php?videoid=";

-(NSString *)getVideoPropsURL:(NSString *)videoId{
    NSString *quality;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"videoQuality"] isEqualToString:@"hd"])
    {
        quality = @"best";
    }
    else
    {
        quality = @"ipad";
    }
    NSString *videoPropsURL = [NSString stringWithFormat:@"%@%@&format=%@", YOUTUBE_GETVIDEO_URL, videoId, quality];
    NSLog(@"videoPropsURL: %@", videoPropsURL);
    return videoPropsURL;
}

@end
