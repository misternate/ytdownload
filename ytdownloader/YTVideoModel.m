//
//  YTVideoModel.m
//  ytdownloader
//
//  Created by Nate Edwards on 3/6/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import "YTVideoModel.h"

@implementation YTVideoModel

//-(id)init
//{
//    //self = [super init];
//    self = [self initWithTitle:self.video_title videoFile:self.video_file videoThumb:self.video_thumbnail];
//    return self;
//}

+(id)initWithTitle:(NSString *)aVideoTitle videoFile:(NSURL *)aVideoFile videoThumb:(NSURL *)aVideoThumbnail{
    self = [super init];
    if(self)
    {
        self.video_title = aVideoTitle;
        self.video_file = aVideoFile;
        self.video_thumbnail = aVideoThumbnail;
    }
    return self;
}

@end
