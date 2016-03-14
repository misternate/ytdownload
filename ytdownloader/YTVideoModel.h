//
//  YTVideoModel.h
//  ytdownloader
//
//  Created by Nate Edwards on 3/6/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTVideoModel : NSObject
@property (strong) NSURL *video_file;
@property (strong) NSURL *video_thumbnail;
@property (strong) NSString *video_title;

//-(id)init;
+(id)initWithTitle: (NSString *)aVideoTitle videoFile:(NSURL *)aVideoFile videoThumb: (NSURL *)aVideoThumbnail;

@end
