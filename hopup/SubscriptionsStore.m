//
//  SubscriptionsStore.m
//  hopup
//
//  Created by Edward Kim on 9/7/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "LocationManagerStore.h"
#import "RestKit.h"
#import "SessionStore.h"
#import "Subscription.h"
#import "SubscriptionsStore.h"
#import "TopicsStore.h"

@interface SubscriptionsStore ()
@property (strong) NSMutableDictionary *subscriptionsByTopicIdPrivate;
@end

@implementation SubscriptionsStore

- (id)init {
    self = [super init];
    if (self) {
        self.subscriptionsByTopicIdPrivate = [NSMutableDictionary new];
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
    __weak SubscriptionsStore *weakSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        RKClient *client = [RKClient sharedClient];
        [client get:@"subscriptions.json" usingBlock:^(RKRequest *request) {
            request.onDidLoadResponse = ^(RKResponse *response) {
                if ([response isSuccessful]) {
                    [weakSelf parseRKResponse:response];
                }
                dispatch_async(dispatch_get_main_queue(), block);
            };
        }];
    });
}

- (void)subscribeToTopic:(int)topicId withBlock:(void(^)(BOOL successful))block {
    __weak SubscriptionsStore *weakSelf = self;
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
                    [weakSelf.subscriptionsByTopicIdPrivate setObject:newSubscription forKey:@(topicId)];
                    [[LocationManagerStore sharedStore] monitorTagsForTopic:newSubscription.topicId];
                }
                dispatch_async(dispatch_get_main_queue(), ^{block([response isSuccessful]);});
            };
        }];
    });
}

- (void)unsubscribeToTopic:(int)topicId withBlock:(void(^)(BOOL successful))block {
    __weak SubscriptionsStore *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        RKClient *client = [RKClient sharedClient];
        int subscriptionId = [[weakSelf.subscriptionsByTopicIdPrivate objectForKey:@(topicId)] subscriptionId];
        NSString *resourcePath = [[[client baseURL] URLByAppendingResourcePath:[NSString stringWithFormat:@"subscriptions/%d.json",subscriptionId]] absoluteString];
        [client delete:resourcePath usingBlock:^(RKRequest *request) {
            request.onDidLoadResponse = ^(RKResponse *response) {
                if ([response isSuccessful]) {
                    [weakSelf.subscriptionsByTopicIdPrivate removeObjectForKey:@(topicId)];
                    [[LocationManagerStore sharedStore] stopMonitoringTagsForTopic:topicId];
                }
                dispatch_async(dispatch_get_main_queue(), ^{block([response isSuccessful]);});
            };
        }];
    });
}

- (BOOL)isSubscribedToTopicWithId:(int)topicId {
    if ([self.subscriptionsByTopicIdPrivate objectForKey:@(topicId)]) {
        return YES;
    }
    return NO;
}

- (NSArray*)subscribedTopics {
    NSMutableArray *tempSubscribedTopics = [NSMutableArray new];
    TopicsStore *sharedStore = [TopicsStore sharedStore];
    for (NSNumber *key in self.subscriptionsByTopicIdPrivate) {
        [tempSubscribedTopics addObject:[[sharedStore topicsByTopicId] objectForKey:key]];
    }
    return [NSArray arrayWithArray:tempSubscribedTopics];
}

- (NSArray *)subscribedTopicIds {
    return self.subscriptionsByTopicIdPrivate.allKeys;
}

- (void)removeLocalStoreSubscriptionWithTopicId:(int)topicId {
    [self.subscriptionsByTopicIdPrivate removeObjectForKey:@(topicId)];
}

#pragma mark helper methods
- (void)parseRKResponse:(RKResponse *)response {
    NSMutableDictionary *tempArrForSubscriptionsByTopicId = [NSMutableDictionary new];
    id parsedResponse = [response parsedBody:nil];
    for (id item in parsedResponse) {
        Subscription *newSubscription = [[Subscription alloc] init];
        newSubscription.userId = [[item objectForKey:@"user_id"] integerValue];
        newSubscription.topicId = [[item objectForKey:@"topic_id"] integerValue];
        newSubscription.subscriptionId = [[item objectForKey:@"id"] integerValue];
        [tempArrForSubscriptionsByTopicId setObject:newSubscription forKey:@(newSubscription.topicId)];
    }
    self.subscriptionsByTopicIdPrivate = tempArrForSubscriptionsByTopicId;
}

@end
