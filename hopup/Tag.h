//
//  Tag.h
//  hopup
//
//  Created by Edward Kim on 9/10/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tag : NSObject
@property double lat;
@property double lng;
@property (strong) NSString *text;
@property (strong) NSString *location;
@property int topicId;
@property int tagId;
@end
