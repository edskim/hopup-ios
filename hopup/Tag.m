//
//  Tag.m
//  hopup
//
//  Created by Edward Kim on 9/10/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "Tag.h"

@implementation Tag
@synthesize lat, lng, text, location, topicId, tagId;

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        Tag *tag = (Tag*)object;
        if (tag.lat == self.lat && tag.lng == self.lng && [tag.text isEqual:self.text] && [tag.location isEqual:self.location] && tag.topicId == self.topicId && tag.tagId == self.tagId)
            return YES;
    }
    return NO;
}

@end
