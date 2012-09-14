//
//  TopicsStore.m
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "RestKit.h"
#import "SessionStore.h"
#import "TopicsStore.h"
#import "User.h"


@interface TopicsStore ()
@property (strong) NSMutableArray *topics;
@property (strong) NSMutableDictionary *topicsByUserId;
@property (strong) NSMutableDictionary *topicsByTopicIdPrivate;
@end

@implementation TopicsStore
@synthesize topics;
@synthesize topicsByUserId;

- (id)init {
    self = [super init];
    if (self) {
        self.topicsByTopicIdPrivate = [NSMutableDictionary new];
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
    [self createTopicWithName:name withBlock:^(BOOL successful){}];
}

- (void)createTopicWithName:(NSString *)name withBlock:(void (^)(BOOL successful))block {
    __weak TopicsStore *weakSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        RKClient *client = [RKClient sharedClient];
        [client post:@"topics.json" usingBlock:^(RKRequest *request) {
            int userId = [[[SessionStore sharedStore] currentUser] userId];
            NSDictionary *topic = [NSDictionary dictionaryWithKeysAndObjects:
                                    @"name",name,
                                    @"creator_id",@(userId), nil];
            request.params = [NSDictionary dictionaryWithObject:topic forKey:@"topic"];
            request.onDidLoadResponse = ^(RKResponse *response) {
                
                if ([response isSuccessful]) {
                    id parsedResponse = [response parsedBody:nil];
                    Topic *newTopic = [Topic new];
                    newTopic.name = [parsedResponse objectForKey:@"name"];
                    newTopic.creatorId = [[parsedResponse objectForKey:@"creator_id"] integerValue];
                    newTopic.topicId = [[parsedResponse objectForKey:@"id"] integerValue];
                    [weakSelf.topics addObject:newTopic];
                    [weakSelf.topicsByTopicIdPrivate setObject:newTopic forKey:@(newTopic.topicId)];
                    if (![weakSelf.topicsByUserId objectForKey:@(userId)])
                        [weakSelf.topicsByUserId setObject:[NSMutableArray new] forKey:@(userId)];
                    [[weakSelf.topicsByUserId objectForKey:@(userId)] addObject:newTopic];
                }
                dispatch_async(dispatch_get_main_queue(), ^{block([response isSuccessful]);});
            };
        }];
    });
}

- (void)cacheTopics {
    [self cacheTopicsWithBlock:^{}];
}

- (void)cacheTopicsWithBlock:(void (^)(void))block {
    __weak TopicsStore *weakSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        RKClient *client = [RKClient sharedClient];
        [client get:@"topics.json" usingBlock:^(RKRequest *request) {
            request.onDidLoadResponse = ^(RKResponse *response) {
                [weakSelf parseRKResponse:response];
                dispatch_async(dispatch_get_main_queue(), block);
            };
        }];
    });
}

- (NSArray*)allTopics {
    return self.topics;
}

- (NSArray*)topicsWithUserId:(int)userId {
    return [self.topicsByUserId objectForKey:@(userId)];
}

- (void)deleteTopicWithTopicId:(int)topicId {
    [self deleteTopicWithTopicId:topicId withBlock:^(BOOL successful){}];
}

- (void)deleteTopicWithTopicId:(int)topicId withBlock:(void (^)(BOOL successful))block {
    __weak TopicsStore *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        RKClient *client = [RKClient sharedClient];
        NSString *resourcePath = [[[client baseURL] URLByAppendingResourcePath:[NSString stringWithFormat:@"topics/%d.json",topicId]] absoluteString];
        
        [client delete:resourcePath usingBlock:^(RKRequest *request) {
            request.onDidLoadResponse = ^(RKResponse *response) {
                if ([response isSuccessful]) {
                    Topic* topicToRemove = [weakSelf.topicsByTopicIdPrivate objectForKey:@(topicId)];
                    [weakSelf.topics removeObject:topicToRemove];
                    [[weakSelf.topicsByUserId objectForKey:@(topicToRemove.creatorId)] removeObject:topicToRemove];
                    [weakSelf.topicsByTopicIdPrivate removeObjectForKey:@(topicId)];
                }
                dispatch_async(dispatch_get_main_queue(), ^{block([response isSuccessful]);});
            };
        }];
    });
}

- (NSDictionary*)topicsByTopicId {
    return [NSDictionary dictionaryWithDictionary:self.topicsByTopicIdPrivate];
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
        if (![tempUserIdDic objectForKey:@(newTopic.creatorId)]) {
            [tempUserIdDic setObject:[NSMutableArray new] forKey:@(newTopic.creatorId)];
        }
        [[tempUserIdDic objectForKey:@(newTopic.creatorId)] addObject:newTopic];
        
        //add topic to dictionary by topic id
        [tempTopicIdDic setObject:newTopic forKey:[NSNumber numberWithInt:newTopic.topicId]];
    }
    self.topics = tempArr;
    self.topicsByUserId = tempUserIdDic;
    self.topicsByTopicIdPrivate = tempTopicIdDic;
}

@end
