//
//  MenuViewController.m
//  hopup
//
//  Created by Edward Kim on 8/27/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "MenuViewController.h"
#import "SignInViewController.h"
#import "SignInViewControllerDelegate.h"

@interface MenuViewController () <SignInViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property BOOL signedIn;
@end

@implementation MenuViewController
@synthesize signedIn;
@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    CGRect tableViewRect = [[UIScreen mainScreen] bounds];
    self.view = [[UITableView alloc] initWithFrame:tableViewRect];
    ((UITableView*)self.view).delegate = self;
    ((UITableView*)self.view).dataSource = self;
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!signedIn) {
        SignInViewController *signinController = [SignInViewController new];
        signinController.modalPresentationStyle = UIModalPresentationFormSheet;
        signinController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        signinController.delegate = self;
        [self presentViewController:signinController animated:YES completion:NULL];
    }
         
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)signInViewController:(SignInViewController *)controller signInSuccessfull:(BOOL)succeeded withUser:(User *)newUser {
    if (succeeded) {
        [self dismissModalViewControllerAnimated:YES];
        self.signedIn = YES;
        self.user = newUser;
    } else {

    }
}

//UITableView Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

//UITableView DataSource methods
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

@end
