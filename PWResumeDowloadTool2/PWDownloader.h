//
//  PWDownloader.h
//  PWResumeDowloadTool2
//
//  Created by Tony_Zhao on 4/23/15.
//  Copyright (c) 2015 TonyZPW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWDownloadModel.h"


@interface PWDownloader : NSObject


@property (nonatomic, assign) NSUInteger maxConcurrentDownloads;

+ (instancetype)sharedDownloader;


-(void)addItemToDownloadFrom:(NSURL *)url withCompletionBlock:(void(^)(void))completionBlock fail:(DownloadFail)fail startImmediately:(BOOL)startImmediately;
-(void)addItemToDownloadItem:(PWDownloadModel *)item withCompletionBlock:(void(^)(void))completionBlock fail:(DownloadFail)fail startImmediately:(BOOL)startImmediately;

- (void)addItemToDownload:(PWDownloadModel *)downloadFileItem startImmediately:(BOOL)startImmediately;

-(void)startDownloads;

-(void)cancelAllDownloads;
-(void)cancelDownloadForItem:(PWDownloadModel *)item;
-(void)cancelDownloadWithTag:(NSString *)tag;

-(void)pauseDownloadWithItem:(PWDownloadModel *)item ;
- (void)resumeDownloadWithItem:(PWDownloadModel *)item completionBlock:(DownloadComplete)complete fail:(DownloadFail)fail;
-(void)resumeDownloadsWithCompletionBlock:(void(^)(void))completionBlock fail:(DownloadFail)fail;


@end
