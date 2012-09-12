//
//  TopicTableViewCell.m
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "TopicCell.h"

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

@end
