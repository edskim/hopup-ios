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
- (void)createTagWithTag:(Tag*)tag;
- (void)createTagWithTag:(Tag*)tag withBlock:(void(^)(BOOL successful))block;
- (void)cacheTags;
- (void)cacheTagsWithBlock:(void(^)(BOOL successful))block;
- (void)cacheTagsForTopicId:(int)topicId;
- (void)cacheTagsForTopicId:(int)topicId withBlock:(void(^)(BOOL successful))block;
- (NSArray*)tagsForTopicId:(int)topicId;
- (void)deleteTagWithId:(int)tagId;
- (void)deleteTagWithId:(int)tagId withBlock:(void(^)(BOOL successful))block;
@end
