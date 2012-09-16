//
//  FormCell.m
//  hopup
//
//  Created by Edward Kim on 9/14/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "FormTextCell.h"

@interface FormTextCell () <UITextFieldDelegate>
@end

@implementation FormTextCell
@synthesize onDidCompleteEditing;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.onDidCompleteEditing = ^(FormTextCell *cell){};
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.input = [[UITextField alloc] initWithFrame:CGRectZero];
        self.input.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.input.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.input.returnKeyType = UIReturnKeyDone;
        self.input.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.input.delegate = self;

        self.textLabel.textAlignment = UITextAlignmentLeft;
        
        [self.contentView addSubview:self.input];
    }
    return self;
}

- (id)init {
    self = [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"FormTextCell"];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize contentViewSize = self.contentView.bounds.size;

    CGRect inputFrame = CGRectMake(contentViewSize.width/3.0-10.0, 0.0, contentViewSize.width*2.0/3.0, contentViewSize.height);
    self.input.frame = inputFrame;
    
    CGRect labelFrame = CGRectMake(10.0, 0.0, contentViewSize.width/3.0-25.0, contentViewSize.height);
    self.textLabel.frame = labelFrame;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.onDidCompleteEditing(self);
}

@end
