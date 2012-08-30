//
//  TopicsStore.h
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicsStore : NSObject
+ (TopicsStore*)sharedStore;
- (NSArray*)allTopics;
- (NSArray*)topicsWithUserId:(int)userId;
- (void)cacheTopics;
- (void)cacheTopicsWithBlock:(void(^)(void))block;
@end
