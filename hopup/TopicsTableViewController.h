//
//  TopicsTableViewController.h
//  hopup
//
//  Created by Edward Kim on 9/7/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicsTableViewController : UITableViewController
@property (strong) NSString *backButtonText;
@property (strong) NSString *details;
@property (strong) NSArray* (^dataSourceBlock)(void);
- (id)initWithTitle:(NSString*)title;
@end
