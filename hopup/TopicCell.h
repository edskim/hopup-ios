//
//  TopicTableViewCell.h
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Topic;

@interface TopicCell : UITableViewCell
@property (strong, nonatomic) Topic *topic;
@end
