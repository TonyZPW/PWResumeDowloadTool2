//
//  DownloadTableViewCell.m
//  PWBreakpointTool
//
//  Created by Tony_Zhao on 4/22/15.
//  Copyright (c) 2015 TonyZPW. All rights reserved.
//

#import "DownloadTableViewCell.h"
#import "PWDownloader.h"
@interface DownloadTableViewCell()
{
    BOOL hasAddObserver;
}

@end

@implementation DownloadTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        self.backgroundColor = [UIColor clearColor];
        self.downloadBtn = [DownloadButton buttonWithType:UIButtonTypeCustom];
        self.downloadBtn.frame = CGRectMake(self.frame.size.width - 10 - DOWNLOADBUTTONWIDTH, self.center.y - DOWNLOADBUTTONHEIGHT / 3, DOWNLOADBUTTONWIDTH, DOWNLOADBUTTONHEIGHT);
        self.downloadBtn.selected = NO;
        [self.downloadBtn addTarget:self action:@selector(controlDownload:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.downloadBtn];
    }
    return self;
}

- (void)controlDownload:(DownloadButton *)sender{
    
    sender.selected = !sender.selected;
    
    NSAssert(_downloadModel != nil, @"model is nil");
    
    if(sender.selected){
        
        [[PWDownloader sharedDownloader] addItemToDownloadItem:self.downloadModel withCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!sender.selected)return;
                self.progress = 0;
                self.downloadBtn.selected = NO;
                [self.downloadBtn setTitle:@"下载完成" forState:UIControlStateNormal];
            });
        } fail:^(NSError *error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.progress = 0;
                 self.downloadBtn.selected = NO;
                 [self.downloadBtn setTitle:@"下载失败" forState:UIControlStateNormal];
             });
        } startImmediately:YES];
        
    }else{
        
        [[PWDownloader sharedDownloader] pauseDownloadWithItem:self.downloadModel];
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.downloadBtn setTitle:@"继续" forState:UIControlStateNormal];
         });
    }
    
}

- (void)setDownloadModel:(PWDownloadModel *)downloadModel
{
    _downloadModel = downloadModel;
    
    NSArray *components = [[_downloadModel.url absoluteString] pathComponents];
    self.textLabel.text = components[components.count - 1];
    
    NSAssert(_downloadModel != nil, @"DownloadModel can't be nil");
    
    if(!hasAddObserver){
        [_downloadModel addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
        hasAddObserver = YES;
    }
    
}

- (void)setProgress:(CGFloat)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadBtn.progress = progress;
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"progress"]){
        
        self.progress = [change[@"new"] floatValue];
    }
}

- (void)dealloc
{
    [self.downloadModel removeObserver:self forKeyPath:@"progress"];
}

@end
