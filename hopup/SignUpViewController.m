//
//  SignUpViewController.m
//  hopup
//
//  Created by Edward Kim on 9/17/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "SignUpViewController.h"
#import "UsersStore.h"

@interface SignUpViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *cPasswordTextField;
@end

@implementation SignUpViewController
@synthesize errorLabel;
@synthesize nameTextField;
@synthesize emailTextField;
@synthesize passwordTextField;
@synthesize cPasswordTextField;
@synthesize completionBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.cPasswordTextField.delegate = self;
}

- (void)viewDidUnload
{
    [self setErrorLabel:nil];
    [self setNameTextField:nil];
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setCPasswordTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)submitPressed:(UIButton *)sender {
    [self.view endEditing:YES];
    
    //Validate fields
    NSMutableArray *errors = [NSMutableArray new];
    if ([self.nameTextField.text length] == 0)
        [errors addObject:@"Username cannot be blank"];
    if ([self.emailTextField.text length] == 0)
        [errors addObject:@"Email cannot be blank"];
    if ([self.passwordTextField.text length] < 6)
        [errors addObject:@"Password must be 6 characteers or longer"];
    if (![self.passwordTextField.text isEqualToString:self.cPasswordTextField.text])
        [errors addObject:@"Password and confirmation do not match"];
    if ([errors count] > 0) {
        self.errorLabel.text = [errors componentsJoinedByString:@"\n"];
        return;
    }
    
    User *newUser = [User new];
    newUser.username = self.nameTextField.text;
    newUser.email = self.emailTextField.text;
    [[UsersStore sharedStore] createUserWithUser:newUser withPassword:self.passwordTextField.text
                        withPasswordConfirmation:self.cPasswordTextField.text withBlock:^(BOOL successful, NSArray *errors) {
                            if (successful) {
                                self.completionBlock();
                            } else {
                                self.errorLabel.text = [errors componentsJoinedByString:@"\n"];
                            }
                        }];
}

- (IBAction)cancelPressed:(UIButton *)sender {
    self.completionBlock();
}

- (IBAction)cancelTextPressed:(UIButton *)sender {
    [self.view endEditing:YES];
}

#pragma mark UITextField delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
