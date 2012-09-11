//
//  UsersStore.h
//  hopup
//
//  Created by Edward Kim on 9/11/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UsersStore : NSObject
+ (UsersStore*)sharedStore;
- (void)cacheUsers;
- (void)cacheUsersWithBlock:(void(^)(void))block;
- (User*)userWithId:(int)userId;
@end
