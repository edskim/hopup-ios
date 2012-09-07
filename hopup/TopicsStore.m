//
//  TopicsStore.m
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "Topic.h"
#import "TopicsStore.h"
#import "RestKit.h"


@interface TopicsStore () <RKRequestDelegate>
extern NSString *applicationURL;
@property (strong) NSArray *topics;
@property (strong) NSDictionary *topicsByUserId;
@end

@implementation TopicsStore
@synthesize topics;
@synthesize topicsByUserId;

- (id)init {
    self = [super init];
    if (self) {
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

- (void)cacheTopics {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self requestTopics];
    });
}

- (void)cacheTopicsWithBlock:(void (^)(void))block {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [RKClient clientWithBaseURLString:applicationURL];
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
    if ([self.topicsByUserId count] == 0) {
        [self populateTopicsByUserId];
    }
    return [self.topicsByUserId objectForKey:[NSString stringWithFormat:@"%d",userId]];
}

#pragma mark Helper Methods

- (void)populateTopicsByUserId {
    if (!self.topics || [self.topics count] == 0) {
        [self cacheTopicsWithBlock:^{
            [self createTopicsByUserId];
        }];
    } else {
        [self createTopicsByUserId];
    }

}
- (void)createTopicsByUserId {
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    for (Topic *topic in self.topics) {
        NSString *userId = [NSString stringWithFormat:@"%d",topic.creatorId];
        if (![tempDic objectForKey:userId]) {
            [tempDic setValue:[NSMutableArray new] forKey:userId];
        }
        [[tempDic objectForKey:userId] addObject:topic];
    }
    self.topicsByUserId = tempDic;
}

#pragma mark RKRequest helper
- (void)requestTopics {
    [RKClient clientWithBaseURLString:applicationURL];
    RKClient *client = [RKClient sharedClient];
    [client get:@"topics.json" delegate:self];
}

#pragma mark RKResponse handling and parsing
- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    //for some reason exception thrown on signout/login when this is queued
    [self parseRKResponse:response];
}

- (void)parseRKResponse:(RKResponse *)response {
    NSMutableArray *tempArr = [NSMutableArray new];
    id parsedResponse = [response parsedBody:nil];
    for (id item in parsedResponse) {
        Topic *newTopic = [[Topic alloc] init];
        newTopic.name = [item objectForKey:@"name"];
        newTopic.creatorId = [[item objectForKey:@"creator_id"] integerValue];
        newTopic.topicId = [[item objectForKey:@"id"] integerValue];
        [tempArr addObject:newTopic];
    }
    self.topics = tempArr;
    [self populateTopicsByUserId];
}



@end
