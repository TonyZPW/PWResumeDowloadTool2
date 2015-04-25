//
//  DownloadButton.h
//  PWBreakpointTool
//
//  Created by Tony_Zhao on 4/22/15.
//  Copyright (c) 2015 TonyZPW. All rights reserved.
//

#import <UIKit/UIKit.h>

extern int const DOWNLOADBUTTONWIDTH;
extern int const DOWNLOADBUTTONHEIGHT;

@interface DownloadButton : UIButton

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIColor *progressColor;

@property (nonatomic, assign) CGFloat lineWidth;
@end
