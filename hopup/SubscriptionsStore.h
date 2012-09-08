//
//  SubscriptionsStore.h
//  hopup
//
//  Created by Edward Kim on 9/7/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubscriptionsStore : NSObject
@property (strong, readonly) NSArray *subscribedTopics;
+ (SubscriptionsStore*)sharedStore;
- (void)cacheSubscriptions;
- (void)cacheSubscriptionsWithBlock:(void(^)(void))block;
- (void)subscribeToTopic:(int)topicId withBlock:(void(^)(BOOL successful))block;
- (void)unsubscribeToTopic:(int)topicId withBlock:(void(^)(BOOL successful))block;
@end