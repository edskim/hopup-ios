//
//  TopicsStore.h
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Topic.h"

@interface TopicsStore : NSObject
@property (strong,readonly) NSDictionary *topicsByTopicId;
+ (TopicsStore*)sharedStore;
- (NSArray*)allTopics;
- (NSArray*)topicsWithUserId:(int)userId;
- (void)createTopicWithName:(NSString*)name;
- (void)createTopicWithName:(NSString*)name withBlock:(void(^)(void))block;
- (void)cacheTopics;
- (void)cacheTopicsWithBlock:(void(^)(void))block;
@end
