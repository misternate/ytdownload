//
//  YTVideoModel.h
//  ytdownloader
//
//  Created by Nate Edwards on 3/6/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTVideoModel : NSObject
@property (nonatomic) NSURL *video_file;
@property (nonatomic) NSURL *video_thumbnail;
@property (nonatomic) NSString *video_title;

@end
