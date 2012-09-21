//
//  SessionStore.m
//  hopup
//
//  Created by Edward Kim on 9/7/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "LocationManagerStore.h"
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
        
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        if ([userDefaults boolForKey:@"signedIn"] && [userDefaults objectForKey:@"currentUser"]
            && [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] count] > 0) {
            self.currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"currentUser"]];
            self.signedIn = [userDefaults boolForKey:@"signedIn"];
            [[TopicsStore sharedStore] cacheTopics];
        }
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
                    if ([response isSuccessful]) {
                        id parsedObject = [response parsedBody:nil];
                        User *newUser = [User new];
                        newUser.username = [parsedObject objectForKey:@"name"];
                        newUser.email = [parsedObject objectForKey:@"email"];
                        newUser.userId = [[parsedObject objectForKey:@"id"] integerValue];
                        
                        [weakSelf setCurrentUser:newUser withCookies:[response cookies]];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{block(weakSelf.signedIn);});
                };
                
            }];
        });
    } else {
        block(self.signedIn);
    }
}

- (void)destroySessionWithBlock:(void(^)(void))block {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults removeObjectForKey:@"signedIn"];
    [userDefaults removeObjectForKey:@"currentUser"];
    
    NSArray *cookiesToDelete = [NSArray arrayWithArray:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    for (NSHTTPCookie *cookie in cookiesToDelete) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }

    self.cookies = nil;
    self.currentUser = nil;
    self.signedIn = NO;
    [[LocationManagerStore sharedStore] stopMonitoringAllRegions];
}

- (void)setCurrentUser:(User *)currentUser withCookies:(NSArray*)cookies {
    self.signedIn = YES;
    self.currentUser = currentUser;
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setBool:self.signedIn forKey:@"signedIn"];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.currentUser] forKey:@"currentUser"];
    
    [[TopicsStore sharedStore] cacheTopicsWithBlock:^{
        [[SubscriptionsStore sharedStore] cacheSubscriptionsWithBlock:^{
            [[LocationManagerStore sharedStore] resetMonitoredRegions];
        }];
    }];
}

@end
