//
//  LocationManagerStore.h
//  hopup
//
//  Created by Edward Kim on 9/18/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
@class Tag;

@interface LocationManagerStore : NSObject
@property (strong,readonly) CLLocationManager *locationManager;
+ (LocationManagerStore*)sharedStore;
- (void)resetMonitoredRegions;
- (void)monitorTagsForTopic:(int)topicId;
- (void)stopMonitoringTagsForTopic:(int)topicId;
- (void)monitorTag:(Tag*)tag;
- (void)stopMonitoringTag:(Tag*)tag;
- (void)stopMonitoringAllRegions;
@end
