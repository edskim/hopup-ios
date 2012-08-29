//
//  TopicsStore.m
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "TopicsStore.h"
#import "RestKit.h"



@interface TopicsStore () <RKRequestDelegate>
extern NSString *applicationURL;
@property (strong) NSArray *topics;
@end

@implementation TopicsStore

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
    if (!sharedStore)
        sharedStore = [[super allocWithZone:nil] init];
    return sharedStore;
}

- (void)cacheTopics {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [RKClient clientWithBaseURLString:applicationURL];
        RKClient *client = [RKClient sharedClient];
        [client get:@"topics.json" delegate:self];
    });
}

- (NSArray*)allTopics {
    if (!self.topics) {
        [RKClient clientWithBaseURLString:applicationURL];
        RKClient *client = [RKClient sharedClient];
        [client get:@"topics.json" delegate:self];
    }
    return self.topics;
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
    });
}

@end
