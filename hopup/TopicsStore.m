//
//  TopicsStore.m
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "RestKit.h"
#import "SessionStore.h"
#import "Topic.h"
#import "TopicsStore.h"
#import "User.h"


@interface TopicsStore ()
extern NSString *applicationURL;
@property (strong) NSArray *topics;
@property (strong) NSDictionary *topicsByUserId;
@end

@implementation TopicsStore
@synthesize topics;
@synthesize topicsByUserId;
@synthesize topicsByTopicId = _topicsByTopicId;

- (id)init {
    self = [super init];
    if (self) {
        _topicsByTopicId = [NSDictionary new];
        [RKClient clientWithBaseURLString:applicationURL];
    }
    return self;
}

//so no other instance can be created. alloc calls allocwithzone by default
+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

+ (TopicsStore*)sharedStore {
    //shared instance never destroyed because static pointer is strong pointer
    static TopicsStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

- (void)createTopicWithName:(NSString *)name {
    [self createTopicWithName:name withBlock:^{}];
}

- (void)createTopicWithName:(NSString *)name withBlock:(void (^)(void))block {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        RKClient *client = [RKClient sharedClient];
        [client post:@"topics.json" usingBlock:^(RKRequest *request) {
            int userId = [[[SessionStore sharedStore] currentUser] userId];
            NSDictionary *topic = [NSDictionary dictionaryWithKeysAndObjects:
                                    @"name",name,
                                    @"creator_id",@(userId), nil];
            request.params = [NSDictionary dictionaryWithObject:topic forKey:@"topic"];
            request.onDidLoadResponse = ^(RKResponse *response) {
                dispatch_async(dispatch_get_main_queue(), block);
            };
        }];
    });
}

- (void)cacheTopics {
    [self cacheTopicsWithBlock:^{}];
}

- (void)cacheTopicsWithBlock:(void (^)(void))block {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        RKClient *client = [RKClient sharedClient];
        [client get:@"topics.json" usingBlock:^(RKRequest *request) {
            request.onDidLoadResponse = ^(RKResponse *response) {
                [self parseRKResponse:response];
                dispatch_async(dispatch_get_main_queue(), block);
            };
        }];
    });
}

- (NSArray*)allTopics {
    return self.topics;
}

- (NSArray*)topicsWithUserId:(int)userId {
    return [self.topicsByUserId objectForKey:[NSString stringWithFormat:@"%d",userId]];
}

#pragma mark Helper Methods

- (void)parseRKResponse:(RKResponse *)response {
    NSMutableArray *tempArr = [NSMutableArray new];
    NSMutableDictionary *tempUserIdDic = [NSMutableDictionary new];
    NSMutableDictionary *tempTopicIdDic = [NSMutableDictionary new];
    id parsedResponse = [response parsedBody:nil];
    for (id item in parsedResponse) {
        Topic *newTopic = [[Topic alloc] init];
        newTopic.name = [item objectForKey:@"name"];
        newTopic.creatorId = [[item objectForKey:@"creator_id"] integerValue];
        newTopic.topicId = [[item objectForKey:@"id"] integerValue];
        [tempArr addObject:newTopic];
        
        //add topic to dictionary by user id
        NSString *userId = [NSString stringWithFormat:@"%d",newTopic.creatorId];
        if (![tempUserIdDic objectForKey:userId]) {
            [tempUserIdDic setValue:[NSMutableArray new] forKey:userId];
        }
        [[tempUserIdDic objectForKey:userId] addObject:newTopic];
        
        //add topic to dictionary by topic id
        [tempTopicIdDic setObject:newTopic forKey:[NSNumber numberWithInt:newTopic.topicId]];
    }
    self.topics = tempArr;
    self.topicsByUserId = tempUserIdDic;
    _topicsByTopicId = tempTopicIdDic;
}

@end
