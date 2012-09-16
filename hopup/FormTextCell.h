//
//  FormCell.h
//  hopup
//
//  Created by Edward Kim on 9/14/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormTextCell : UITableViewCell
@property (strong) UITextField *input;
@property (strong) void (^onDidCompleteEditing)(FormTextCell*);
@end
