//
//  TagCell.m
//  hopup
//
//  Created by Edward Kim on 9/10/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "TagCell.h"

@implementation TagCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
