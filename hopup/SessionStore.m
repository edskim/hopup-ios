//
//  SessionStore.m
//  hopup
//
//  Created by Edward Kim on 9/7/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "RestKit.h"
#import "SessionStore.h"
#import "SubscriptionsStore.h"
#import "TopicsStore.h"

@interface SessionStore ()
@property (strong) User *currentUser;
@property BOOL signedIn;
@property (strong) NSArray *cookies;
@end

@implementation SessionStore

- (id)init {
    self = [super init];
    if (self) {
        self.currentUser = nil;
        self.signedIn = NO;
    }
    return self;
}

//so no other instance can be created. alloc calls allocwithzone by default
+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

+ (SessionStore*)sharedStore {
    //shared instance never destroyed because static pointer is strong pointer
    static SessionStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

- (void)createSessionWithEmail:(NSString *)email withPassword:(NSString *)pw withBlock:(void (^)(BOOL))block {
    if (!self.signedIn) {
        __weak SessionStore *weakSelf = self;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            RKClient *client = [RKClient sharedClient];
            NSDictionary *userNamePassword = [NSDictionary dictionaryWithKeysAndObjects:
                                              @"email",email,
                                              @"password",pw, nil];
            NSDictionary *params = [NSDictionary dictionaryWithObject:userNamePassword forKey:@"session"];
            [client post:@"sessions.json" usingBlock:^(RKRequest *request) {
                
                request.params = params;
                
                request.onDidLoadResponse = ^(RKResponse *response) {
                    weakSelf.signedIn = [response isSuccessful];
                    if ([response isSuccessful]) {
                        weakSelf.currentUser = [User new];
                        weakSelf.cookies = [response cookies];
                        
                        id parsedObject = [response parsedBody:nil];
                        weakSelf.currentUser.username = [parsedObject objectForKey:@"name"];
                        weakSelf.currentUser.email = [parsedObject objectForKey:@"email"];
                        weakSelf.currentUser.userId = [[parsedObject objectForKey:@"id"] integerValue];
                        
                        for (NSHTTPCookie *cookie in weakSelf.cookies) {
                            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                        }
                        [[TopicsStore sharedStore] cacheTopicsWithBlock:^{
                            [[SubscriptionsStore sharedStore] cacheSubscriptions];
                        }];
                    }
                    block(weakSelf.signedIn);
                };
                
            }];
        });
    } else {
        block(self.signedIn);
    }
}

- (void)destroySessionWithBlock:(void(^)(void))block {
    for (NSHTTPCookie *cookie in self.cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    self.cookies = nil;
    self.currentUser = nil;
    self.signedIn = NO;
}

@end
