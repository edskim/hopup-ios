//
//  SignInViewControllerDelegate.h
//  hopup
//
//  Created by Edward Kim on 8/27/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SignInViewController;
@class User;

@protocol SignInViewControllerDelegate <NSObject>

- (void)signInViewController:(SignInViewController*)controller signInSuccessfull:(BOOL)succeeded;

@end
