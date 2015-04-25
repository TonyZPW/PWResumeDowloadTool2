//
//  PWDownloadOperation.m
//  PWResumeDowloadTool2
//
//  Created by Tony_Zhao on 4/23/15.
//  Copyright (c) 2015 TonyZPW. All rights reserved.
//

#import "PWDownloadOperation.h"
#import "PWDownloadModel.h"

#define PWLog(formatString, ...) NSLog((@"%s " formatString), __PRETTY_FUNCTION__, ##__VA_ARGS__);


NSString *const RESUME_FILE_EXTENSION = @"rfd";
static NSString *const FILES_FOLDER = @"Files";
@interface PWDownloadOperation()
{
    //自己控制状态
    BOOL        pwExecuting;
    BOOL        pwFinished;
    BOOL        pwCancelled;
    
}
@property NSURLConnection *downloadConnection;
@property NSOutputStream *fileOutputStream;
@property NSString *resumableFilePath;
@property NSString *tag;

@end

@implementation PWDownloadOperation

- (instancetype)init
{
    assert(@"Use initWithDownloadItem Method");
    return [self initWithDownloadItem:[[PWDownloadModel alloc] init]];
}

- (instancetype)initWithDownloadItem:(PWDownloadModel *)item
{
    if(self = [super init])
    {
        self.downloadItem = item;
         self.completionBlock = item.completionBlock;
        
        self.tag = item.url.absoluteString;
        pwExecuting = YES;
        pwFinished = NO;
        pwCancelled = NO;
        
        if(item.url == nil){
            _resumableFilePath = nil;
        }else{
            
            _resumableFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[[[_downloadItem url] lastPathComponent] stringByDeletingPathExtension]] stringByAppendingPathExtension:RESUME_FILE_EXTENSION];
            
            NSLog(@"%@",_resumableFilePath);
             [self getBytesDownloadedFromFile:_resumableFilePath];
        }
    }
    
    return self;
}

- (void)main
{
    @try {
     if ([self isCancelled])
     {
        [self.downloadConnection cancel];
        [self.fileOutputStream close];
         
        [self cancelAndClear:YES];
        return;
     }
     if([self isFinished]){
        [self.downloadConnection cancel];
        [self.fileOutputStream close];
     }
        
        [self willChangeValueForKey:@"isExecuting"];
        pwExecuting = YES;
        [self didChangeValueForKey:@"isExecuting"];
        
         NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[self.downloadItem url] lastPathComponent]];
        self.fileOutputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
         [self.fileOutputStream open];
        
        self.downloadConnection = [[NSURLConnection alloc] initWithRequest:[self createRequest:self.downloadItem.url startingAt:self.downloadItem.bytesRecieved] delegate:self startImmediately:NO];
        
        [self.downloadConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [self.downloadConnection start];
        
        while ([self isExecuting]) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
     }
    @catch(...) {
        
    }
}

-(NSURLRequest *)createRequest:(NSURL *)url startingAt:(unsigned long long)bytesWritten {
    
    if(url == nil)return nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    
    if (bytesWritten > 0) {
        
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", bytesWritten];
        [request setValue:requestRange forHTTPHeaderField:@"Range"];
    }
    
    return request;
}

- (unsigned long long)getBytesDownloadedFromFile:(NSString *)filePath{
    
    if([filePath isEqualToString:@""] || filePath == nil){
        return 0;
    }else{
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            
            PWDownloadModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

            if (model != nil) {
                self.downloadItem.bytesRecieved = model.bytesRecieved;
                self.downloadItem.totalBytes = model.totalBytes;
                self.downloadItem.progress = model.progress;
                return self.downloadItem.bytesRecieved;
            }else{
                NSError *deleteError;
                
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&deleteError];
                
                if (deleteError != nil) {
                    NSLog(@"%@",[[deleteError userInfo] description]);
                }
                
                return [self getBytesDownloadedFromFile:filePath];
            }
        }
        else {
            
            [self writeResumableFile];
            
            return [self getBytesDownloadedFromFile:filePath];
        }
    }
}

-(void)removeFileFromTemp {
    
    NSString *tempfilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[self.downloadItem url] lastPathComponent]];
    
    NSError *error;
    
    [[NSFileManager defaultManager] removeItemAtPath:tempfilePath error:&error];
    
    if (error != nil) {
        NSLog(@"%@",[[error userInfo] description]);
    }
}

-(BOOL)writeResumableFile {
    
    BOOL success = [NSKeyedArchiver archiveRootObject:self.downloadItem toFile:self.resumableFilePath];
    
    if (!success) {
        NSLog(@"failed to save rfd object");
    }
    
    return success;
}

- (void)cancelAndClear:(BOOL)clear{
    
    [self.downloadConnection cancel];
    if (clear) {
        [self removeFileFromTemp];
    }
    else {
        [self writeResumableFile];
    }
    
    [self willChangeValueForKey:@"isCancelled"];
    pwCancelled = YES;
    [self didChangeValueForKey:@"isCancelled"];
    
    [self willChangeValueForKey:@"isExecuting"];
    pwExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    pwFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
}
-(BOOL)writeData:(NSData *)data toStream:(NSOutputStream *)stream {
    
    NSInteger startWriteLength = [data length];
    NSInteger actualStartWrittenLength = [stream write:[data bytes] maxLength:startWriteLength];
    
    if (actualStartWrittenLength == -1 || actualStartWrittenLength != startWriteLength) {
        return NO;
    }
    
    else {
        
        self.downloadItem.bytesRecieved += [data length];
        
        return YES;
    }
}

-(void)cancelBeforeStart {
    
    [self.downloadConnection cancel];
    
    [self removeFileFromTemp];
    
    [self willChangeValueForKey:@"isCancelled"];
    pwCancelled = YES;
    [self didChangeValueForKey:@"isCancelled"];
    
    [self willChangeValueForKey:@"isExecuting"];
    pwExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
}

-(NSString *)getTag {
    
    return _tag;
}

#pragma mark -NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    PWLog()
    self.downloadItem.downLoadFail(error);
     [self.fileOutputStream close];
    [self cancelAndClear:NO];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSOutputStream *outputStream;
    
    self.downloadItem.bytesRecieved += [data length];
    self.downloadItem.progress = (double)self.downloadItem.bytesRecieved / (double)self.downloadItem.totalBytes;

    outputStream = self.fileOutputStream;
    
    if (![self writeData:data toStream:outputStream]) {
        [self cancelAndClear:NO];
    };
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
     PWLog()
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    NSInteger statusCode = [httpResponse statusCode];
    
    if ((statusCode < 200 || statusCode > 299) && statusCode != 416) {
        
                NSLog(@"%@ canceled", [[[connection currentRequest] URL] absoluteString]);
        [self cancelAndClear:YES];
    }
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
     PWLog()
    [self.fileOutputStream close];
    self.downloadConnection = nil;
    [self writeResumableFile];
    [self addFileToDirectory];
    
    [self willChangeValueForKey:@"isExecuting"];
    pwExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    pwFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
}


-(void)addFileToDirectory {
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[self.downloadItem url] lastPathComponent]];
    
    NSString *documentsDirectory = [[self class] getFileFolder];
    
    NSError *moveError;
    
    [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:[documentsDirectory stringByAppendingPathComponent:[[self.downloadItem url] lastPathComponent]] error:&moveError];
    
    if (moveError != nil) {
        
        if ([moveError code] != NSFileWriteFileExistsError) {
            NSLog(@"%@",[[moveError userInfo] description]);
        }
        
        [self removeFileFromTemp];
    }
    
    [self removeResumableFile];
}

-(void)removeResumableFile {
    
    NSString *tempfilePath = [[[NSTemporaryDirectory() stringByAppendingPathComponent:[[self.downloadItem url] lastPathComponent]] stringByDeletingPathExtension] stringByAppendingPathExtension:RESUME_FILE_EXTENSION];
    
    NSError *error;
    
    [[NSFileManager defaultManager] removeItemAtPath:tempfilePath error:&error];
    
    if (error != nil) {
        NSLog(@"%@",[[error userInfo] description]);
    }
}

+(NSString *)getDocumentsDirectionPath:(NSString *)path {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory stringByAppendingPathComponent:path];
    
    return documentsPath;
}

+(NSString *)getFileFolder {
    
    NSString *path = [[self class] getDocumentsDirectionPath:FILES_FOLDER];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if ([fileManager fileExistsAtPath:path] == NO) {
        
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
    return path;
}

#pragma mark 操作状态
//自己控制状态
- (BOOL)isExecuting
{
    return pwExecuting;
}

- (BOOL)isCancelled
{
    return pwCancelled;
}

- (BOOL)isFinished
{
    return pwFinished;
}

- (BOOL)isConcurrent{
    return YES;
}

//重写isEqual方法判断operation是否相等
- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        
        PWDownloadOperation * downloadItem = object;
        
        if ([_downloadItem.url isEqual:[downloadItem downloadItem].url]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    return NO;
}
@end
