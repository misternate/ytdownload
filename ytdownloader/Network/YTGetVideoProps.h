//
//  YTNetworkVideoId.h
//  ytdownloader
//
//  Created by Nate Edwards on 2/14/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YTGetVideoProps : NSObject

@property (nonatomic) NSString *percentageOfFileDownloaded;

- (void)getVideoWithID:(NSString *)videoId completion:(void (^)(BOOL success))completion;

@end
