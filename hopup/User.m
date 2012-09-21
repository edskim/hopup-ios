//
//  User.m
//  hopup
//
//  Created by Edward Kim on 8/27/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize username;
@synthesize email;
@synthesize userId;

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeInt:self.userId forKey:@"userId"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.userId = [aDecoder decodeIntForKey:@"userId"];
    }
    return self;
}

@end
