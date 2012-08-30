//
//  CurrentUser.m
//  hopup
//
//  Created by Edward Kim on 8/29/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "CurrentUser.h"

@implementation CurrentUser
@synthesize username;
@synthesize cookies;
@synthesize userId;


//so no other instance can be created. alloc calls allocwithzone by default
+ (id)allocWithZone:(NSZone *)zone {
    return [self currentUser];
}

+ (CurrentUser*)currentUser {
    //shared instance never destroyed because static pointer is strong pointer
    static CurrentUser *currentUser = nil;
    if (!currentUser) {
        currentUser = [[super allocWithZone:nil] init];
    }
    return currentUser;
}
@end
