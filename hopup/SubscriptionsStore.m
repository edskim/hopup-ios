//
//  SubscriptionsStore.m
//  hopup
//
//  Created by Edward Kim on 9/7/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "RestKit.h"
#import "Subscription.h"
#import "SubscriptionsStore.h"
#import "TopicsStore.h"

@interface SubscriptionsStore ()
extern NSString *applicationURL;
@property (strong) NSArray *subscriptions;
@end

@implementation SubscriptionsStore {
    NSArray *_subscribedTopics;
}
@synthesize subscribedTopics;

- (id)init {
    self = [super init];
    if (self) {
        _subscribedTopics = [NSArray new];
    }
    return self;
}

//so no other instance can be created. alloc calls allocwithzone by default
+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

+ (SubscriptionsStore*)sharedStore {
    //shared instance never destroyed because static pointer is strong pointer
    static SubscriptionsStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

- (void)cacheSubscriptions {
    [self cacheSubscriptionsWithBlock:^{}];
}

- (void)cacheSubscriptionsWithBlock:(void (^)(void))block {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [RKClient clientWithBaseURLString:applicationURL];
        RKClient *client = [RKClient sharedClient];
        [client get:@"subscriptions.json" usingBlock:^(RKRequest *request) {
            request.onDidLoadResponse = ^(RKResponse *response) {
                if ([response isSuccessful]) {
                    [self parseRKResponse:response];
                }
                block();
            };
        }];
    });
}

- (NSArray*)subscribedTopics {
    if (!_subscribedTopics) {
        [self cacheSubscriptions];
    }
    return _subscribedTopics;
}

- (void)subscribeToTopic:(int)topicId withBlock:(void(^)(BOOL successful))block {
    
}

- (void)unsubscribeToTopic:(int)topicId withBlock:(void(^)(BOOL successful))block {
    
}

#pragma mark helper methods
- (void)parseRKResponse:(RKResponse *)response {
    NSMutableArray *tempArrForSubscriptions = [NSMutableArray new];
    NSMutableArray *tempArrForSubscribedTopics = [NSMutableArray new];
    NSDictionary *topicsByTopicId = [[TopicsStore sharedStore] topicsByTopicId];
    id parsedResponse = [response parsedBody:nil];
    for (id item in parsedResponse) {
        Subscription *newSubscription = [[Subscription alloc] init];
        newSubscription.userId = [[item objectForKey:@"user_id"] integerValue];
        newSubscription.topicId = [[item objectForKey:@"topic_id"] integerValue];
        [tempArrForSubscriptions addObject:newSubscription];
        
        [tempArrForSubscribedTopics addObject:[topicsByTopicId objectForKey:[NSNumber numberWithInt:newSubscription.topicId]]];
    }
    self.subscriptions = tempArrForSubscriptions;
    _subscribedTopics = tempArrForSubscribedTopics;
}


@end
