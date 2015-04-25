//
//  PWQueue.h
//  PWResumeDowloadTool2
//
//  Created by Tony_Zhao on 4/23/15.
//  Copyright (c) 2015 TonyZPW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWQueue : NSObject


- (void)enqueue:(id)obj;
- (id)dequeue;
- (id)peek;
- (NSUInteger)count;
- (void)enqueueArray:(NSArray *)array;
@end
