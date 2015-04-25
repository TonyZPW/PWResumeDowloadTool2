//
//  PWDownloader.m
//  PWResumeDowloadTool2
//
//  Created by Tony_Zhao on 4/23/15.
//  Copyright (c) 2015 TonyZPW. All rights reserved.
//

#import "PWDownloader.h"
#import "PWQueue.h"
#import "PWDownloadOperation.h"
static int MAX_CONCURRENT_DOWNLOADS = 5;
static NSString *const DOWNLOADQUEUEID = @"com.zpw.www.downloadQueue";


static dispatch_queue_t downloadFileQueue = nil;
static dispatch_once_t onceToken;

@interface PWDownloader()<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) PWQueue *pwQueue;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) PWDownloadModel *currentDownloadItem;

@end

@implementation PWDownloader


+ (instancetype)sharedDownloader
{
    static PWDownloader *downloader = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        downloader = [[PWDownloader alloc] init];
    });
    return downloader;
}

- (instancetype)init
{
    if(self = [super init]){
        
        [self setMaxConcurrentDownloads:MAX_CONCURRENT_DOWNLOADS];
        
        self.pwQueue = [[PWQueue alloc] init];
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self.operationQueue setMaxConcurrentOperationCount:MAX_CONCURRENT_DOWNLOADS];
        
        dispatch_once(&onceToken, ^{
            downloadFileQueue = dispatch_queue_create([DOWNLOADQUEUEID UTF8String], DISPATCH_QUEUE_SERIAL);
        });
        
    }
    return self;
}

- (void)addItemToDownloadItem:(PWDownloadModel *)item withCompletionBlock:(void (^)(void))completionBlock fail:(DownloadFail)fail startImmediately:(BOOL)startImmediately{
    
    if([self tmpFileExistsWithPath:item.url]){
        [self resumeDownloadWithItem:item completionBlock:completionBlock fail:fail];
    }else{
        
        item.completionBlock = completionBlock;
        item.downLoadFail = fail;
        item.startInmediately = startImmediately;
        self.currentDownloadItem = item;
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:item.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
        req.HTTPMethod = @"HEAD";
        self.connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
        
        [self.connection start];
    }

}


- (void)addItemToDownloadFrom:(NSURL *)url withCompletionBlock:(void (^)(void))completionBlock fail:(DownloadFail)fail startImmediately:(BOOL)startImmediately
{
    if([self tmpFileExistsWithPath:url]){
        [self resumeDownloadWithUrl:url completionBlock:completionBlock fail:fail];
    }else{
        
        PWDownloadModel *downloadItem = [[PWDownloadModel alloc] initWithURL:url complete:completionBlock fail:fail];
        downloadItem.startInmediately = startImmediately;
        self.currentDownloadItem = downloadItem;
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
        req.HTTPMethod = @"HEAD";
        self.connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
        
        [self.connection start];
    }
    
   
}

- (void)addItemToDownload:(PWDownloadModel *)downloadFileItem startImmediately:(BOOL)startImmediately
{
    [self.pwQueue enqueue:downloadFileItem];
    if (startImmediately) {
        [self startDownloads];
    }
}

- (void)startDownloads
{
    dispatch_async(downloadFileQueue, ^{
         [self startAllOperations];
    });
}

- (void)startAllOperations{
    if(self.pwQueue.count == 0)return;
     NSMutableArray *newOperations = [[NSMutableArray alloc] init];
    while(self.pwQueue.count != 0){
        PWDownloadModel *item = [self.pwQueue dequeue];
        
        PWDownloadOperation *downloadFileOperation = [[PWDownloadOperation alloc] initWithDownloadItem:item];
        
        if ([self operation:downloadFileOperation inQueue:self.operationQueue] == NO) {
            
            if (![newOperations containsObject:downloadFileOperation]) {
                [newOperations addObject:downloadFileOperation];
                
            }
        }
    }
    [self.operationQueue addOperations:newOperations waitUntilFinished:NO];
}
-(BOOL)operation:(PWDownloadOperation *)operation inQueue:(NSOperationQueue *)queue {
    
    if ([queue.operations containsObject:operation]) {
        return YES;
    }
    else {
        return NO;
    }
}

-(void)cancelAllDownloads {
    
    [self.operationQueue cancelAllOperations];
}

-(NSArray *)getOperations {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObjectsFromArray:[_operationQueue operations]];
    
    return array;
}

-(void)cancelDownloadForItem:(PWDownloadModel *)item {
    
    PWDownloadOperation *downloadFileOperation = [[PWDownloadOperation alloc] initWithDownloadItem:item];
    
    if ([_operationQueue.operations containsObject:downloadFileOperation]) {
        [downloadFileOperation cancelAndClear:YES];
    }
}

- (void)cancelDownloadWithTag:(NSString *)tag{
    NSInteger index = [_operationQueue.operations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        PWDownloadOperation *downloadFileOperation = obj;
        
        if ([[downloadFileOperation getTag] isEqualToString:tag]) {
            return YES;
        }
        
        else {
            return NO;
        }
    }];
    
    if (index != NSNotFound) {
        
        PWDownloadOperation *downloadFileOperation = [_operationQueue.operations objectAtIndex:index];
        
        if ([downloadFileOperation isExecuting]) {
            
            [downloadFileOperation cancelAndClear:YES];
        }
        
        else {
            [downloadFileOperation cancelBeforeStart];
        }
    }

}


- (void)pauseDownloadWithItem:(PWDownloadModel *)item
{
    PWDownloadModel *downLoadModel = [[PWDownloadModel alloc] initWithURL:item.url complete:item.completionBlock fail:item.downLoadFail];
    
    PWDownloadOperation *downloadFileOperation = [[PWDownloadOperation alloc] initWithDownloadItem:downLoadModel];
    
    if ([_operationQueue.operations containsObject:downloadFileOperation]) {
        NSUInteger index = [_operationQueue.operations indexOfObject:downloadFileOperation];
        if(index != NSNotFound)
        [_operationQueue.operations[index] cancelAndClear:NO];
    }
}

- (void)resumeDownloadWithItem:(PWDownloadModel *)item completionBlock:(DownloadComplete)complete fail:(DownloadFail)fail{
    if([self tmpFileExistsWithPath:item.url]){
        
        NSString *resumePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[[[item url] lastPathComponent] stringByDeletingPathExtension]] stringByAppendingPathExtension:@"rfd"];
        
        PWDownloadModel *storedItem = [NSKeyedUnarchiver unarchiveObjectWithFile:resumePath];
        if(storedItem != nil){
            item.url = storedItem.url;
            item.bytesRecieved = storedItem.bytesRecieved;
            item.totalBytes = storedItem.totalBytes;
        }
        [[[self class] sharedDownloader] addItemToDownload:item startImmediately:YES];
    }
}
- (void)resumeDownloadWithUrl:(NSURL *)url completionBlock:(DownloadComplete)complete fail:(DownloadFail)fail{
    if([self tmpFileExistsWithPath:url]){
        
        NSString *resumePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[[url lastPathComponent] stringByDeletingPathExtension]] stringByAppendingPathExtension:@"rfd"];
        
        PWDownloadModel *item = [NSKeyedUnarchiver unarchiveObjectWithFile:resumePath];
        item.completionBlock = complete;
        item.downLoadFail = fail;
        
        if (item != nil) {
            NSLog(@"%@",self.operationQueue.operations);
            [[[self class] sharedDownloader] addItemToDownload:item startImmediately:YES];
        }
    }
}

- (BOOL)tmpFileExistsWithPath:(NSURL *)url{
    NSString *resumePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[[url lastPathComponent] stringByDeletingPathExtension]] stringByAppendingPathExtension:@"rfd"];
    return [[NSFileManager defaultManager]fileExistsAtPath:resumePath];
}

- (void)resumeDownloadsWithCompletionBlock:(void (^)(void))completionBlock fail:(DownloadFail)fail{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_async(downloadFileQueue, ^{
       
        NSString *fileName = NSTemporaryDirectory();
        NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:fileName];
         NSString *filePath;
        while (filePath = [direnum nextObject]) {
            
            if ([filePath hasSuffix:RESUME_FILE_EXTENSION]) {
                
                PWDownloadModel *item = [NSKeyedUnarchiver unarchiveObjectWithFile:[fileName stringByAppendingPathComponent:filePath]];
                item.completionBlock = completionBlock;
                item.downLoadFail = fail;
                if (item != nil) {
                    [[[self class] sharedDownloader] addItemToDownload:item startImmediately:YES];
                }
            }

        }
        
        dispatch_semaphore_signal(sema);
    });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
     [[[self class] sharedDownloader] startDownloads];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.currentDownloadItem.totalBytes = response.expectedContentLength;
     [self addItemToDownload:self.currentDownloadItem startImmediately:self.currentDownloadItem.startInmediately];
}

@end
