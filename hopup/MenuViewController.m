//
//  MenuViewController.m
//  hopup
//
//  Created by Edward Kim on 8/27/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "AllTopicsViewController.h"
#import "MenuViewController.h"
#import "MenuTableViewCell.h"
#import "MyTopicsViewController.h"
#import "SignInViewController.h"
#import "SignInViewControllerDelegate.h"
#import "SubscriptionsViewController.h"
#import "TopicsStore.h"

@interface MenuViewController () <SignInViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property BOOL signedIn;
@property (strong) UITableView *tableView;
@property (strong) NSMutableArray *menuControllers;
@end

@implementation MenuViewController
@synthesize signedIn;
@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.menuControllers = [NSMutableArray new];
        [self.menuControllers addObject:[AllTopicsViewController new]];
        [self.menuControllers addObject:[MyTopicsViewController new]];
        [self.menuControllers addObject:[SubscriptionsViewController new]];
    }
    return self;
}

- (void)loadView {
    CGRect tableViewRect = [[UIScreen mainScreen] bounds];
    self.tableView = [[UITableView alloc] initWithFrame:tableViewRect];
    self.view = self.tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor darkGrayColor]];
    
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:nil action:nil]];
}

- (void)viewWillAppear:(BOOL)animated {
    //Show user what selection they were viewing
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
	if (selection)
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self.navigationController navigationBar] setBarStyle:UIBarStyleBlackTranslucent];

    if (!signedIn) {
        [self showSignInScreen];
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

- (void)signInWithUser:(User*)newUser {
    self.signedIn = YES;
    self.user = newUser;
    self.title = newUser.username;
    
    for (NSHTTPCookie *cookie in newUser.cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
}

- (void)signOut {
    self.signedIn = NO;
    self.title = nil;
    for (NSHTTPCookie *cookie in self.user.cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    self.user = nil;
}

- (void)showSignInScreen {
    SignInViewController *signinController = [SignInViewController new];
    signinController.modalPresentationStyle = UIModalPresentationFormSheet;
    signinController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    signinController.delegate = self;
    [self presentViewController:signinController animated:YES completion:NULL];
}

#pragma mark SignInViewController delegate methods
- (void)signInViewController:(SignInViewController *)controller signInSuccessfull:(BOOL)succeeded withUser:(User *)newUser {
    if (succeeded) {
        [self dismissModalViewControllerAnimated:YES];
        [self signInWithUser:newUser];
        [[TopicsStore sharedStore] cacheTopics];
    } else {

    }
}

#pragma mark UITableView Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self.menuControllers count]) {
        [self signOut];
        [self showSignInScreen];
    } else {
        [self.navigationController pushViewController:[self.menuControllers objectAtIndex:indexPath.row] animated:YES];
    }

}

#pragma mark UITableView Data Source methods
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MenuTableViewCell *newCell = [MenuTableViewCell new];
    if (indexPath.row == [self.menuControllers count]) {
        newCell.textLabel.text = @"Sign out";
    } else {
        newCell.textLabel.text = [[self.menuControllers objectAtIndex:indexPath.row] title];
        newCell.detailTextLabel.text = [[self.menuControllers objectAtIndex:indexPath.row] details];
    }
    
    return newCell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuControllers count] + 1;
}

@end
