//
//  UsersStore.m
//  hopup
//
//  Created by Edward Kim on 9/11/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "RestKit.h"
#import "UsersStore.h"

@interface UsersStore ()
@property (strong) NSMutableDictionary *usersByUserId;
@end

@implementation UsersStore

- (id)init {
    self = [super init];
    if (self) {
        self.usersByUserId = [NSMutableDictionary new];
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

+ (UsersStore*)sharedStore {
    static UsersStore* sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

- (void)cacheUsers {
    [self cacheUsersWithBlock:^{}];
}

- (void)cacheUsersWithBlock:(void(^)(void))block {
    __weak UsersStore *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[RKClient sharedClient] get:@"users.json" usingBlock:^(RKRequest *request) {
            request.onDidLoadResponse = ^(RKResponse *response) {
                [weakSelf ParseRKResponse:response];
                dispatch_async(dispatch_get_main_queue(), block);
            };
        }];
        
    });
}

- (User*)userWithId:(int)userId {
    if ([self.usersByUserId count] == 0) {
        [self cacheUsers];
    }
    return [self.usersByUserId objectForKey:@(userId)];
}

#pragma mark Helper Methods
- (void)ParseRKResponse:(RKResponse *)response {
    id parsedResponse = [response parsedBody:nil];
    for (id item in parsedResponse) {
        User *newUser = [User new];
        newUser.username = [item objectForKey:@"name"];
        newUser.email = [item objectForKey:@"email"];
        newUser.userId = [[item objectForKey:@"id"] integerValue];
        
        [self.usersByUserId setObject:newUser forKey:@(newUser.userId)];
    }
}

@end
