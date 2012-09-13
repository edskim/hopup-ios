//
//  TopicTableViewCell.m
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "SubscriptionsStore.h"
#import "Topic.h"
#import "TopicCell.h"
#import "UsersStore.h"

@interface TopicCell ()
@property BOOL subscribed;
@property (strong) UIButton *subscribeButton;
@end

@implementation TopicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = [UIColor brownColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0];
        self.detailTextLabel.textColor = [UIColor brownColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundCell.png"]];
        
        CGRect subscribeButtonFrame = CGRectMake(self.contentView.bounds.size.width*3.0/5.0,
                                                 self.contentView.bounds.size.height/2.0+5.0,
                                                 self.contentView.bounds.size.width/3.0,
                                                 self.contentView.bounds.size.height/3.0);
        self.subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.subscribeButton.frame = subscribeButtonFrame;
        self.subscribeButton.backgroundColor = [UIColor clearColor];
        self.subscribeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        [self.subscribeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.subscribeButton addTarget:self action:@selector(subscribeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.subscribeButton];
    }
    return self;
}

- (id)init {
    self = [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TopicCell"];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)subscribeButtonPressed {
    [self.subscribeButton setUserInteractionEnabled:NO];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (self.subscribed) {
        [[SubscriptionsStore sharedStore] unsubscribeToTopic:self.topic.topicId withBlock:^(BOOL successful){
            if (successful) {
                self.subscribed = NO;
                [self.subscribeButton setTitle:@"Subscribe" forState:UIControlStateNormal];
                [self.subscribeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [(UITableView*)self.superview reloadData];
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.subscribeButton setUserInteractionEnabled:YES];
        }];
        
    } else {
        [[SubscriptionsStore sharedStore] subscribeToTopic:self.topic.topicId withBlock:^(BOOL successful){
            if (successful) {
                self.subscribed = YES;
                [self.subscribeButton setTitle:@"Unsubscribe" forState:UIControlStateNormal];
                [self.subscribeButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.subscribeButton setUserInteractionEnabled:YES];
        }];
    }
}

- (void)setTopic:(Topic *)topic {
    
    _topic = topic;
    self.textLabel.text = topic.name;
    self.detailTextLabel.text = [[[UsersStore sharedStore] userWithId:topic.creatorId] username];
    
    self.subscribed = [[SubscriptionsStore sharedStore] isSubscribedToTopicWithId:topic.topicId];
    if (self.subscribed) {
        [self.subscribeButton setTitle:@"Unsubscribe" forState:UIControlStateNormal];
        [self.subscribeButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    } else {
        [self.subscribeButton setTitle:@"Subscribe" forState:UIControlStateNormal];
        [self.subscribeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }

}

@end
