//
//  FormPickerCell.m
//  hopup
//
//  Created by Edward Kim on 9/14/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "FormPickerCell.h"
#import "SessionStore.h"
#import "TopicsStore.h"

@interface FormPickerCell () <UIPickerViewDataSource,UIPickerViewDelegate>
@property (strong) UIActionSheet *actionSheet;
@property (strong) UIPickerView *pickerView;
@end

@implementation FormPickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.input = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.input addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchUpInside];
        [self.input setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.input setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        self.textLabel.textAlignment = UITextAlignmentLeft;
        
        [self.contentView addSubview:self.input];
        
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        CGRect pickerFrame = CGRectMake(0.0, 44.0, 320.0, 256.0);
        self.pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        self.pickerView.showsSelectionIndicator = YES;
        self.pickerView.delegate = self;
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelActionSheet:)];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePickingTopic:)];
        [toolbar setItems:[NSArray arrayWithObjects:cancelButton,[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] ,doneButton,nil]];
        
        [self.actionSheet addSubview:toolbar];
        [self.actionSheet addSubview:self.pickerView];
    }
    return self;
}

- (id)init {
    self = [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"FormPickerCell"];
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

#pragma mark helper methods

- (void)showActionSheet:(UIButton*)button {
    [self.actionSheet showInView:self.superview];
    [self.actionSheet setFrame:CGRectMake(0.0, 200.0, 320.0, 300.0)];
    [self.actionSheet sizeToFit];
}

- (void)cancelActionSheet:(UIBarButtonItem*)button {
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)donePickingTopic:(UIBarButtonItem*)button {
    NSArray *userTopics = [[TopicsStore sharedStore] topicsWithUserId:[[[SessionStore sharedStore] currentUser] userId]];
    [self.input setTitle:[[userTopics objectAtIndex:[self.pickerView selectedRowInComponent:0]] name] forState:UIControlStateNormal];
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *userTopics = [[TopicsStore sharedStore] topicsWithUserId:[[[SessionStore sharedStore] currentUser] userId]];
    return [[userTopics objectAtIndex:row] name];
}

#pragma mark UIPickerViewDataSource methods

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *userTopics = [[TopicsStore sharedStore] topicsWithUserId:[[[SessionStore sharedStore] currentUser] userId]];
    return [userTopics count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

@end
