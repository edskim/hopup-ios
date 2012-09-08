//
//  NewTopicCell.m
//  hopup
//
//  Created by Edward Kim on 9/7/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "NewTopicCell.h"

@implementation NewTopicCell
@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.textField = [[UITextField alloc] initWithFrame:CGRectInset(self.frame, 10, 7)];
        self.textField.backgroundColor = [UIColor whiteColor];
        self.textField.placeholder = @"Enter new topic name.";
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        [self addSubview:self.textField];
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
