//
//  SignInViewController.h
//  hopup
//
//  Created by Edward Kim on 8/27/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SignInViewControllerDelegate;

@interface SignInViewController : UIViewController
@property (weak, nonatomic) id<SignInViewControllerDelegate> delegate;
@end
