//
//  FormPickerCell.h
//  hopup
//
//  Created by Edward Kim on 9/14/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormPickerCell : UITableViewCell
@property (strong) UIButton *input;
@property (strong) NSString *pickerText;
@property (strong) NSString* (^dataSource)(void); //not yet implemented
@end
