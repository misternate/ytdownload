//
//  YTDownloadVideo.m
//  ytdownloader
//
//  Created by Nate Edwards on 3/13/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import "YTDownloadVideo.h"
#import "YTVideoDataModel.h"
#import "YTUrlInputVC.h"
#import "YTAppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AFNetworking.h>

@implementation YTDownloadVideo

-(void)downloadVideo{
    
    YTVideoDataModel *videoModel = [YTVideoDataModel getInstance];
    NSDictionary *videoDictionary = [videoModel getVideoModel];
    NSString *videoFilePath = [videoDictionary valueForKey:@"video_file"];
    
    if(![videoFilePath isEqualToString:@""])
    {
        [[YTAppDelegate getdelegate] showIndicator];
        
        //Let's download the file
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURL *URL = [NSURL URLWithString:videoFilePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSProgress *progress;
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
          {
              NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
              return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
          }
            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
          {
              //Write file to photo album
              ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
              [assetLibrary writeVideoAtPathToSavedPhotosAlbum:filePath completionBlock:^(NSURL *assetURL, NSError *error)
               {
                   NSError *removeError = nil;
                   //Cleanup file in local directory
                   [[NSFileManager defaultManager] removeItemAtURL:filePath error:&removeError];
                   
                   UIAlertView *downloadCompleteAlert = [[UIAlertView alloc] initWithTitle:@"Downloaded!" message:@"download completed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                   
                   [[YTAppDelegate getdelegate] hideIndicator];
                   
                   [downloadCompleteAlert show];
               }];
          }];
        
        [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite)
         {
             //self.percentageOfFileDownloaded = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
             
             NSLog(@"%lld, %lld", totalBytesWritten, totalBytesExpectedToWrite);
             
             if(totalBytesWritten == totalBytesExpectedToWrite)
             {
                 YTUrlInputVC *urlInputVC = [[YTUrlInputVC alloc] init];
                 urlInputVC.youtubeUrlField.text = @"downloaded.";
             }
             //NSLog(@"P: %@", self.percentageOfFileDownloaded);
             
             //[self setPercentageOfFileDownloaded: [[NSNumber numberWithFloat:(float)totalBytesWritten / (float)totalBytesExpectedToWrite] stringValue]];
         }];
        [downloadTask resume];
    }
}

@end
