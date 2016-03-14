//
//  YTVideoDataModel.h
//  ytdownloader
//
//  Created by Nate Edwards on 3/13/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTVideoDataModel : NSObject{
    NSDictionary *videoModel;
}

+(YTVideoDataModel *)getInstance;

-(void)setVideoModel:(NSDictionary *)json;
-(NSDictionary *)getVideoModel;
-(void)resetVideoModel;

@end
