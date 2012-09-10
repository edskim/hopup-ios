//
//  MenuTableViewCell.m
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = [UIColor orangeColor];
        self.detailTextLabel.textColor = [UIColor lightGrayColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (id)init {
    self = [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
