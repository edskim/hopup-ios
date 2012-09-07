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
#import "User.h"

@interface SessionStore () {
    __block User *_currentUser;
    __block BOOL _signedIn;
    __block NSArray *_cookies;
}
extern NSString* applicationURL;
@property (strong) __block NSArray *cookies;
@end

@implementation SessionStore

- (id)init {
    self = [super init];
    if (self) {
        _currentUser = nil;
        _signedIn = NO;
        [RKClient clientWithBaseURLString:applicationURL];
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
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            RKClient *client = [RKClient sharedClient];
            NSDictionary *userNamePassword = [NSDictionary dictionaryWithKeysAndObjects:
                                              @"email",email,
                                              @"password",pw, nil];
            NSDictionary *params = [NSDictionary dictionaryWithObject:userNamePassword forKey:@"session"];
            [client post:@"sessions.json" usingBlock:^(RKRequest *request) {
                
                request.params = params;
                
                request.onDidLoadResponse = ^(RKResponse *response) {
                    _signedIn = [response isSuccessful];
                    if ([response isSuccessful]) {
                        _currentUser = [User new];
                        self.cookies = [response cookies];
                        
                        id parsedObject = [response parsedBody:nil];
                        _currentUser.username = [parsedObject objectForKey:@"email"];
                        _currentUser.userId = [[parsedObject objectForKey:@"id"] integerValue];
                        
                        for (NSHTTPCookie *cookie in self.cookies) {
                            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                        }
                        [[TopicsStore sharedStore] cacheTopicsWithBlock:^{
                            [[SubscriptionsStore sharedStore] cacheSubscriptions];
                        }];
                    }
                    block(self.signedIn);
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
    _currentUser = nil;
    _signedIn = NO;
}

@end
