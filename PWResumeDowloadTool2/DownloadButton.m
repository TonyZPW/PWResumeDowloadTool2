//
//  DownloadButton.m
//  PWBreakpointTool
//
//  Created by Tony_Zhao on 4/22/15.
//  Copyright (c) 2015 TonyZPW. All rights reserved.
//

#import "DownloadButton.h"


 int const DOWNLOADBUTTONWIDTH = 50;
 int const DOWNLOADBUTTONHEIGHT = 50;
@implementation DownloadButton


- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        self.layer.cornerRadius = DOWNLOADBUTTONWIDTH / 2;
        self.layer.masksToBounds = YES;
        self.lineWidth = 2;
        self.progressColor = [UIColor greenColor];
        self.progress = 0;
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        [self setTitle:@"下载中.." forState:UIControlStateSelected];
        [self setTitle:@"开始" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [self setBackgroundColor:[UIColor yellowColor]];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setProgressColor:(UIColor *)progressColor{
    _progressColor = progressColor;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth{
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [self updateProgressCircle];
}

- (void)updateProgressCircle{
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2) radius:DOWNLOADBUTTONWIDTH / 2 startAngle:-M_PI_2 endAngle:-M_PI_2 + self.progress * (M_PI * 2) clockwise:YES];
    
    [self.progressColor set];
    
    path.lineWidth = self.lineWidth;
    
//    path.lineJoinStyle = kCGLineJoinMiter;

//    path.lineCapStyle = kCGLineCapRound;
    
    [path stroke];
    
}

- (void)setFrame:(CGRect)frame
{
    frame = CGRectMake(frame.origin.x, frame.origin.y, DOWNLOADBUTTONWIDTH, DOWNLOADBUTTONHEIGHT);
    [super setFrame:frame];
}


@end
