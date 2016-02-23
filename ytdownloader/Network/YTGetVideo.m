//
//  YTNetworkVideoId.m
//  ytdownloader
//
//  Created by Nate Edwards on 2/14/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import "YTGetVideo.h"
#import <AFNetworking.h>

@implementation YTGetVideo

- (void)getVideoWithID:(NSString *)videoId
{
    
    NSString *youtubeVideoIdUrl = [NSString stringWithFormat:@"%@%@%@", @"http://192.168.0.254/ytdownload/getvideo.php?videoid=" , videoId, @"&format=ipad"];
    
    NSLog(@"youtube url---%@---", youtubeVideoIdUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [manager GET:youtubeVideoIdUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *videoObject = [responseObject objectForKey:@"data"];
        NSLog(@"Video Object: %@", videoObject);
        
        NSString *videoFile = [[videoObject valueForKey:@"video_file"] firstObject];
        
        if(![videoFile isEqualToString:@""])
        {
//            NSData *data = [[NSData alloc] initWithData:responseObject];
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *documentsDirectory = [paths objectAtIndex:0];
//            NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"someFile.mp4"];
//            [data writeToFile:filePath atomically:YES];
            
            NSURL *url = [NSURL URLWithString:videoFile];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[url lastPathComponent]];
            
            [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
            
            [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                NSLog(@"bytesRead: %lu, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", (unsigned long)bytesRead, totalBytesRead, totalBytesExpectedToRead);
            }];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
                
                NSError *error;
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
                
                if (error) {
                    NSLog(@"ERR: %@", [error description]);
                } else {
                    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
                    long long fileSize = [fileSizeNumber longLongValue];
                    
                    NSLog(@"File Size: %lld", fileSize);
                    
                    NSData *videoData = [[NSData alloc] initWithData:responseObject];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"thefile.mp4"];
                    
                    //saving is done on main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [videoData writeToFile:filePath atomically:YES];
                        NSLog(@"File Saved !");
                    });
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"ERR: %@", [error description]);
            }];
            
            [operation start];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(error.code == -1001){
            
        }else{
            
        }
    }];
}



@end
