//
//  SessionStore.h
//  hopup
//
//  Created by Edward Kim on 9/7/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface SessionStore : NSObject
@property (strong,readonly) User *currentUser;
@property (strong,readonly) NSArray *cookies;
@property (readonly) BOOL signedIn;
+ (SessionStore*)sharedStore;
- (void)createSessionWithEmail:(NSString*)email withPassword:(NSString*)pw withBlock:(void(^)(BOOL))block;
- (void)destroySessionWithBlock:(void(^)(void))block;
- (void)setCurrentUser:(User *)currentUser withCookies:(NSArray*)cookies;
@end
