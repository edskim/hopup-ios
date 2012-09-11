//
//  TagsStore.m
//  hopup
//
//  Created by Edward Kim on 9/8/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "RestKit.h"
#import "SessionStore.h"
#import "TagsStore.h"
#import "User.h"

@interface TagsStore ()
@property (strong) NSMutableDictionary *tagsByTopicId;
@end

@implementation TagsStore
@synthesize tagsByTopicId;

- (id)init {
    self = [super init];
    if (self) {
        self.tagsByTopicId = [NSMutableDictionary new];
    }
    return self;
}

//so no other instance can be created. alloc calls allocwithzone by default
+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

+ (TagsStore*)sharedStore {
    //shared instance never destroyed because static pointer is strong pointer
    static TagsStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

- (void)createTagWithTag:(Tag*)tag {
    [self createTagWithTag:tag withBlock:^{}];
}

- (void)createTagWithTag:(Tag*)tag withBlock:(void(^)(void))block {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        RKClient *client = [RKClient sharedClient];
        [client post:@"tags.json" usingBlock:^(RKRequest *request) {
            NSDictionary *tagParams = [NSDictionary dictionaryWithKeysAndObjects:
                                    @"lat",tag.lat, @"lng",tag.lng,
                                    @"text",tag.text, @"location",tag.location,
                                    @"topic_id",tag.topicId, nil];
            request.params = [NSDictionary dictionaryWithObject:tagParams forKey:@"tag"];
            request.onDidLoadResponse = ^(RKResponse *response) {
                dispatch_async(dispatch_get_main_queue(), block);
            };
        }];
    });
}

//caches tags for topics created by user
- (void)cacheTags {
    [self cacheTagsWithBlock:^{}];
}

//caches tags for topics created by user
- (void)cacheTagsWithBlock:(void(^)(void))block {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        RKClient *client = [RKClient sharedClient];
        [client get:@"tags.json" usingBlock:^(RKRequest *request) {
            request.onDidLoadResponse = ^(RKResponse *response) {
                [self parseRKResponse:response];
                dispatch_async(dispatch_get_main_queue(), block);
            };
        }];
    });
}

- (void)cacheTagsForTopicId:(int)topicId {
    [self cacheTagsForTopicId:topicId withBlock:^{}];
}

- (void)cacheTagsForTopicId:(int)topicId withBlock:(void(^)(void))block {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        RKClient *client = [RKClient sharedClient];
        NSDictionary *queryParams = [NSDictionary dictionaryWithObject:@(topicId) forKey:@"topic_id"];
        NSString *resourcePath = [[[client baseURL] URLByAppendingResourcePath:@"tags.json" queryParameters:queryParams] absoluteString];
        [client get:resourcePath usingBlock:^(RKRequest *request) {
            request.onDidLoadResponse = ^(RKResponse *response) {
                [self parseRKResponse:response];
                dispatch_async(dispatch_get_main_queue(), block);
            };
        }];
    });
}

- (NSArray*)tagsForTopicId:(int)topicId {
    //if no tags for topic, set empty array and attempt to cache
    //lazy loading
    if (![self.tagsByTopicId objectForKey:@(topicId)]) {
        [self.tagsByTopicId setObject:[NSArray new] forKey:@(topicId)];
        [self cacheTagsForTopicId:topicId];
    }
    return [self.tagsByTopicId objectForKey:@(topicId)];
}

#pragma mark Helper Methods
- (void)parseRKResponse:(RKResponse*)response {
    //create mutable dictionary and set tagsByTopicId
    NSMutableDictionary *tempTagsByTopicId = [NSMutableDictionary new];
    
    id parsedResponse = [response parsedBody:nil];
    for (id item in parsedResponse) {
        Tag *newTag = [Tag new];
        newTag.text = [item objectForKey:@"text"];
        newTag.lat = [[item objectForKey:@"lat"] floatValue];
        newTag.lng = [[item objectForKey:@"lng"] floatValue];
        newTag.location = [item objectForKey:@"location"];
        newTag.topicId = [[item objectForKey:@"topic_id"] intValue];
        
        if (![tempTagsByTopicId objectForKey:@(newTag.topicId)]) {
            [tempTagsByTopicId setObject:[NSMutableArray new] forKey:@(newTag.topicId)];
        }
        [[tempTagsByTopicId objectForKey:@(newTag.topicId)] addObject:newTag];
    }
    
    //replace tags for keys in tagsByTopicId dictionary
    for (NSNumber *key in tempTagsByTopicId.allKeys) {
        [self.tagsByTopicId setObject:[tempTagsByTopicId objectForKey:key] forKey:key];
    }
}

@end