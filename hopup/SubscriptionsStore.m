//
//  SubscriptionsStore.m
//  hopup
//
//  Created by Edward Kim on 9/7/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "RestKit.h"
#import "SessionStore.h"
#import "Subscription.h"
#import "SubscriptionsStore.h"
#import "TopicsStore.h"

@interface SubscriptionsStore ()
@property (strong) NSMutableDictionary *subscriptionsByTopicId;
@end

@implementation SubscriptionsStore 
@synthesize subscribedTopics = _subscribedTopics;

- (id)init {
    self = [super init];
    if (self) {
        _subscribedTopics = [NSMutableArray new];
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
        RKClient *client = [RKClient sharedClient];
        [client get:@"subscriptions.json" usingBlock:^(RKRequest *request) {
            request.onDidLoadResponse = ^(RKResponse *response) {
                if ([response isSuccessful]) {
                    [self parseRKResponse:response];
                }
                dispatch_async(dispatch_get_main_queue(), block);
            };
        }];
    });
}

- (NSMutableArray*)subscribedTopics {
    if (!_subscribedTopics) {
        [self cacheSubscriptions];
    }
    return _subscribedTopics;
}

- (void)subscribeToTopic:(int)topicId withBlock:(void(^)(BOOL successful))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        RKClient *client = [RKClient sharedClient];
        [client post:@"subscriptions.json" usingBlock:^(RKRequest *request) {
            NSDictionary *subscription = [NSDictionary dictionaryWithKeysAndObjects:
                                          @"topic_id",@(topicId),
                                          @"user_id",@([[[SessionStore sharedStore] currentUser] userId]), nil];
            request.params = [NSDictionary dictionaryWithObject:subscription forKey:@"subscription"];
            request.onDidLoadResponse = ^(RKResponse *response) {
                if ([response isSuccessful]) {
                    id parsedResponse = [response parsedBody:nil];
                    Subscription *newSubscription = [Subscription new];
                    newSubscription.topicId = [[parsedResponse objectForKey:@"topic_id"] integerValue];
                    newSubscription.userId = [[parsedResponse objectForKey:@"user_id"] integerValue];
                    newSubscription.subscriptionId = [[parsedResponse objectForKey:@"id"] integerValue];
                    [_subscribedTopics addObject:[[[TopicsStore sharedStore] topicsByTopicId] objectForKey:@(newSubscription.topicId)]];                    
                    [self.subscriptionsByTopicId setObject:newSubscription forKey:@(topicId)];
                }
                dispatch_async(dispatch_get_main_queue(), ^{block([response isSuccessful]);});
            };
        }];
    });
}

- (void)unsubscribeToTopic:(int)topicId withBlock:(void(^)(BOOL successful))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        RKClient *client = [RKClient sharedClient];
        int subscriptionId = [[self.subscriptionsByTopicId objectForKey:@(topicId)] subscriptionId];
        NSString *resourcePath = [[[client baseURL] URLByAppendingResourcePath:[NSString stringWithFormat:@"subscriptions/%d.json",subscriptionId]] absoluteString];
        [client delete:resourcePath usingBlock:^(RKRequest *request) {
            request.onDidLoadResponse = ^(RKResponse *response) {
                if ([response isSuccessful]) {
                    [_subscribedTopics removeObject:[[[TopicsStore sharedStore] topicsByTopicId] objectForKey:@(topicId)]];
                    [self.subscriptionsByTopicId removeObjectForKey:@(topicId)];
                }
                dispatch_async(dispatch_get_main_queue(), ^{block([response isSuccessful]);});
            };
        }];
    });
}

- (BOOL)isSubscribedToTopicWithId:(int)topicId {
    if ([self.subscriptionsByTopicId objectForKey:@(topicId)]) {
        return YES;
    }
    return NO;
}

#pragma mark helper methods
- (void)parseRKResponse:(RKResponse *)response {
    NSMutableDictionary *tempArrForSubscriptionsByTopicId = [NSMutableDictionary new];
    NSMutableArray *tempArrForSubscribedTopics = [NSMutableArray new];
    NSDictionary *topicsByTopicId = [[TopicsStore sharedStore] topicsByTopicId];
    id parsedResponse = [response parsedBody:nil];
    for (id item in parsedResponse) {
        Subscription *newSubscription = [[Subscription alloc] init];
        newSubscription.userId = [[item objectForKey:@"user_id"] integerValue];
        newSubscription.topicId = [[item objectForKey:@"topic_id"] integerValue];
        newSubscription.subscriptionId = [[item objectForKey:@"id"] integerValue];
        [tempArrForSubscriptionsByTopicId setObject:newSubscription forKey:@(newSubscription.topicId)];
        
        
        [tempArrForSubscribedTopics addObject:[topicsByTopicId objectForKey:@(newSubscription.topicId)]];
    }
    self.subscriptionsByTopicId = tempArrForSubscriptionsByTopicId;
    _subscribedTopics = tempArrForSubscribedTopics;
}

@end
