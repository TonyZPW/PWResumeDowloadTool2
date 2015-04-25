//
//  DownloadTableViewCell.h
//  PWBreakpointTool
//
//  Created by Tony_Zhao on 4/22/15.
//  Copyright (c) 2015 TonyZPW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadButton.h"
#import "PWDownloadModel.h"
@interface DownloadTableViewCell : UITableViewCell

@property (nonatomic, strong) DownloadButton *downloadBtn;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) PWDownloadModel *downloadModel;



@end
