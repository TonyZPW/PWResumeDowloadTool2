//
//  PWDownloadOperation.h
//  PWResumeDowloadTool2
//
//  Created by Tony_Zhao on 4/23/15.
//  Copyright (c) 2015 TonyZPW. All rights reserved.
// 自定义操作

#import <Foundation/Foundation.h>


extern NSString * const RESUME_FILE_EXTENSION;

@class PWDownloadModel;
@interface PWDownloadOperation : NSOperation<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property (nonatomic, strong) PWDownloadModel *downloadItem;

- (instancetype)initWithDownloadItem:(PWDownloadModel *)item;
- (void)cancelAndClear:(BOOL)clear;
-(void)cancelBeforeStart;
-(BOOL)isCancelled;
-(BOOL)isExecuting;
-(BOOL)isFinished;
-(NSString *)getTag;

@end
