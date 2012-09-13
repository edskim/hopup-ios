//
//  Topic.m
//  hopup
//
//  Created by Edward Kim on 8/29/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "Topic.h"

@implementation Topic
@synthesize name, creatorId, topicId;

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        Topic *topic = (Topic*)object;
        if ([topic.name isEqual:self.name] && topic.creatorId == self.creatorId && topic.topicId == self.topicId)
            return YES;
    }
    return NO;
}

@end
