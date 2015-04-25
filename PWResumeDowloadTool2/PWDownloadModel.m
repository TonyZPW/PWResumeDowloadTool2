//
//  PWDownloadModel.m
//  PWResumeDowloadTool2
//
//  Created by Tony_Zhao on 4/23/15.
//  Copyright (c) 2015 TonyZPW. All rights reserved.
//

#import "PWDownloadModel.h"

#define OBJC_STRINGIFY(x) @#x
#define encodeObject(x) [aCoder encodeObject:x forKey:OBJC_STRINGIFY(x)]
#define decodeObject(x) x = [aDecoder decodeObjectForKey:OBJC_STRINGIFY(x)]
#define encodeBool(x) [aCoder encodeBool:x forKey:OBJC_STRINGIFY(x)]
#define decodeBool(x) x = [aDecoder decodeBoolForKey:OBJC_STRINGIFY(x)]
#define encodeInt64(x) [aCoder encodeInt64:x forKey:OBJC_STRINGIFY(x)]
#define decodeInt64(x) x = [aDecoder decodeInt64ForKey:OBJC_STRINGIFY(x)]
#define encodeFloat(x) [aCoder encodeFloat:x forKey:OBJC_STRINGIFY(x)]
#define decodeFloat(x) x = [aDecoder decodeFloatForKey:OBJC_STRINGIFY(x)]
@implementation PWDownloadModel

- (instancetype)initWithURL:(NSURL *)url complete:(DownloadComplete)complete fail:(DownloadFail)fail
{
    if(self = [super init]){
        
        self.bytesRecieved = 0;
        self.totalBytes = ULONG_LONG_MAX;
        self.progress = 0;
        self.url = url;
        self.completionBlock = complete;
        self.downLoadFail = fail;
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    encodeObject(_url);
    encodeInt64(_bytesRecieved);
    encodeInt64(_totalBytes);
    encodeFloat(_progress);
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if(self = [super init]){
        decodeObject(_url);
        decodeInt64(_bytesRecieved);
        decodeInt64(_totalBytes);
        decodeFloat(_progress);
    }
    return self;
}

-(BOOL)isEqual:(id)object {
    
    if ([object isKindOfClass:[PWDownloadModel class]]) {
        
        PWDownloadModel *downloadItem = (PWDownloadModel *)object;
        
        if ([_url.absoluteString isEqualToString:downloadItem.url.absoluteString]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    return NO;
}


@end
