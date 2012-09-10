//
//  TagsStore.h
//  hopup
//
//  Created by Edward Kim on 9/8/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tag.h"

@interface TagsStore : NSObject
+ (TagsStore*)sharedStore;
@property (strong,readonly) NSDictionary *tagsByTopicId;
- (void)createTagWithTag:(Tag*)tag;
- (void)createTagWithTag:(Tag*)tag withBlock:(void(^)(void))block;
- (void)cacheTags;
- (void)cacheTagsWithBlock:(void(^)(void))block;
@end
