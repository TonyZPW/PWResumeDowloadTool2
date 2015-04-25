//
//  PWQueue.m
//  PWResumeDowloadTool2
//
//  Created by Tony_Zhao on 4/23/15.
//  Copyright (c) 2015 TonyZPW. All rights reserved.
//

#import "PWQueue.h"

@interface PWQueue()

@property NSMutableArray *queue;
@end

@implementation PWQueue

-(id)init {
    
    self = [super init];
    
    if (self) {
        self.queue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)enqueue:(id)obj
{
    [self.queue addObject:obj];
}
- (id)dequeue
{
    id item = nil;
    if([self count] != 0){
        item = [self.queue objectAtIndex:0];
        [self.queue removeObjectAtIndex:0];
    }
    return item;
}
-(id)peek {
    
    id item = nil;
    
    if ([self count] != 0) {
        item = [self.queue objectAtIndex:0];
    }
    
    return item;
}
-(NSUInteger)count {
    return [self.queue count];
}

-(void)enqueueArray:(NSArray *)array {
    
    for (id item in array) {
        [self enqueue:item];
    }
}
@end
