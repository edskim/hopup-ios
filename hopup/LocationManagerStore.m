//
//  LocationManagerStore.m
//  hopup
//
//  Created by Edward Kim on 9/18/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "LocationManagerStore.h"
#import "SubscriptionsStore.h"
#import "TagsStore.h"
#import "Topic.h"

@interface LocationManagerStore () <CLLocationManagerDelegate>
@property (strong) CLLocationManager *locationManager;
@end

@implementation LocationManagerStore

- (id)init {
    self = [super init];
    if (self) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

+ (LocationManagerStore*)sharedStore {
    static LocationManagerStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

- (void)resetMonitoredRegions {
    [self stopMonitoringAllRegions];
    
    for (Topic *topic in [[SubscriptionsStore sharedStore] subscribedTopics]) {
        [self monitorTagsForTopic:topic.topicId];
    }
}

- (void)monitorTagsForTopic:(int)topicId {
    [[TagsStore sharedStore] cacheTagsForTopicId:topicId withBlock:^(BOOL successful) {
        NSLog(@"checking tags for topic id:%d",topicId);
        for (Tag *tag in [[TagsStore sharedStore] tagsForTopicId:topicId]) {
            NSLog(@"Monitoring tag %@ for topicid:%d",tag.text,tag.topicId);
            [self monitorTag:tag];
        }
    }];
}

- (void)stopMonitoringTagsForTopic:(int)topicId {
    NSSet *regions = [NSSet setWithSet:self.locationManager.monitoredRegions];
    for (CLRegion *region in regions) {
        NSString *sTopicId = [[region.identifier componentsSeparatedByString:@" "] objectAtIndex:0];
        if ([sTopicId integerValue] == topicId) {
            [self.locationManager stopMonitoringForRegion:region];
        }
    }
}

//monitor tag for when tag added to subscribed topic
- (void)monitorTag:(Tag *)tag {
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(tag.lat, tag.lng);
    NSString *identifier = [NSString stringWithFormat:@"%d %d",tag.topicId,tag.tagId];
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:coord radius:50 identifier:identifier];
    [self.locationManager startMonitoringForRegion:region];
}

//stop monitoring tag when tag deleted
- (void)stopMonitoringTag:(Tag *)tag {
    NSString *identifier = [NSString stringWithFormat:@"%d %d",tag.topicId,tag.tagId];
    NSSet *regions = [NSSet setWithSet:self.locationManager.monitoredRegions];
    for (CLRegion *region in regions) {
        if ([region.identifier isEqualToString:identifier]) {
            [self.locationManager stopMonitoringForRegion:region];
        }
    }
}

- (void)stopMonitoringAllRegions {
    NSSet *regions = [NSSet setWithSet:self.locationManager.monitoredRegions];
    for (CLRegion *region in regions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
}

#pragma mark CLLocationManager delegate methods
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"region %@ entered",region);
    NSArray *ids = [region.identifier componentsSeparatedByString:@" "];
    int topicId = [[ids objectAtIndex:0] integerValue];
    int tagId = [[ids objectAtIndex:1] integerValue];
    NSArray *tags = [[TagsStore sharedStore] tagsForTopicId:topicId];
    for (Tag *tag in tags) {
        if (tagId == tag.tagId) {
            UILocalNotification *localNotif = [UILocalNotification new];
            localNotif.alertBody = tag.text;
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            int newBadgeNum = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:newBadgeNum];
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
            return;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSInteger currBadgeVal = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:MAX(0,currBadgeVal-1)];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"\n-----------------monitoring region %@ succeeded",region);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"\n+++++++++++++++++monitoring failed for region %@ error;%@",region,error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"\n****************manager failed error:%@",error);
}

@end
