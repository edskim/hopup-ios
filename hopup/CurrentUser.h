//
//  CurrentUser.h
//  hopup
//
//  Created by Edward Kim on 8/29/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentUser : NSObject
@property (strong) NSString *username;
@property (strong) NSArray *cookies;
@property int userId;
+ (CurrentUser*)currentUser;
@end
