//
//  SubscriptionsStore.h
//  hopup
//
//  Created by Edward Kim on 9/7/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubscriptionsStore : NSObject
+ (SubscriptionsStore*)sharedStore;
- (void)cacheSubscriptions;
- (void)cacheSubscriptionsWithBlock:(void(^)(void))block;
- (void)subscribeToTopic:(int)topicId withBlock:(void(^)(BOOL successful))block;
- (void)unsubscribeToTopic:(int)topicId withBlock:(void(^)(BOOL successful))block;
- (BOOL)isSubscribedToTopicWithId:(int)topicId;
- (NSArray*)subscribedTopics;
- (void)removeLocalStoreSubscriptionWithTopicId:(int)topicId;
@end
