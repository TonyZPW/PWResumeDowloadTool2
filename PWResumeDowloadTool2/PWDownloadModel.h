//
//  PWDownloadModel.h
//  PWResumeDowloadTool2
//
//  Created by Tony_Zhao on 4/23/15.
//  Copyright (c) 2015 TonyZPW. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^DownloadComplete)();
typedef void(^DownloadFail)(NSError *error);
@interface PWDownloadModel : NSObject<NSCoding>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) DownloadComplete completionBlock;
@property (nonatomic, copy) DownloadFail downLoadFail;
@property (nonatomic, assign) BOOL startInmediately;
@property (nonatomic, assign) CGFloat progress;
@property unsigned long long bytesRecieved;
@property unsigned long long totalBytes;


- (instancetype)initWithURL:(NSURL *)url complete:(DownloadComplete)complete fail:(DownloadFail)fail;
@end
