//
//  MenuViewController.m
//  hopup
//
//  Created by Edward Kim on 8/27/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuCell.h"
#import "ProfileViewController.h"
#import "SessionStore.h"
#import "SignInViewController.h"
#import "SignInViewControllerDelegate.h"
#import "SubscriptionsViewController.h"
#import "TopicsStore.h"
#import "TopicsViewController.h"
#import "User.h"

@interface MenuViewController () <SignInViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property BOOL signedIn;
@property (strong) UITableView *tableView;
@property (strong) NSMutableArray *menuControllers;
@end

@implementation MenuViewController
@synthesize signedIn;

- (void)resetMenuControllers {
    self.menuControllers = [NSMutableArray new];
    
    TopicsViewController *allTopicsViewController = [[TopicsViewController alloc] initWithTitle:@"All Topics"];
    allTopicsViewController.backButtonText = @"All Topics";
    allTopicsViewController.details = @"See all topics from all users.";
    allTopicsViewController.dataSourceBlock = ^NSArray*(void){
        return [[TopicsStore sharedStore] allTopics];
    };
    [self.menuControllers addObject:allTopicsViewController];
    
    TopicsViewController *myTopicsViewController = [[TopicsViewController alloc] initWithTitle:@"My Topics"];
    myTopicsViewController.backButtonText = @"My Topics";
    myTopicsViewController.details = @"See topics you created.";
    myTopicsViewController.dataSourceBlock = ^NSArray*(void){
        return [[TopicsStore sharedStore] topicsWithUserId:[[SessionStore sharedStore] currentUser].userId];
    };
    [self.menuControllers addObject:myTopicsViewController];
    
    [self.menuControllers addObject:[SubscriptionsViewController new]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self resetMenuControllers];
    }
    return self;
}

- (void)loadView {
    CGRect tableViewRect = [[UIScreen mainScreen] bounds];
    self.tableView = [[UITableView alloc] initWithFrame:tableViewRect];
    self.view = self.tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    profileButton.frame = CGRectMake(0.0, 0.0, 25, 25);
    [profileButton setBackgroundImage:[UIImage imageNamed:@"AvatarPlaceholder.png"] forState:UIControlStateNormal];
    [profileButton addTarget:self action:@selector(showProfile) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *profileBarButton = [[UIBarButtonItem alloc] initWithCustomView:profileButton];
    self.navigationItem.rightBarButtonItem = profileBarButton;
    
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

- (void)signIn {
    self.signedIn = YES;
    self.title = [SessionStore sharedStore].currentUser.username;
}

- (void)signOut {
    self.signedIn = NO;
    self.title = nil;
    [[SessionStore sharedStore] destroySessionWithBlock:^{}];
    [self resetMenuControllers];
}

- (void)showSignInScreen {
    SignInViewController *signinController = [SignInViewController new];
    signinController.modalPresentationStyle = UIModalPresentationFormSheet;
    signinController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    signinController.delegate = self;
    [self presentViewController:signinController animated:YES completion:nil];
}

- (void)showProfile {
    [self.navigationController pushViewController:[ProfileViewController new] animated:YES];
}

#pragma mark SignInViewController delegate methods
- (void)signInViewController:(SignInViewController *)controller signInSuccessfull:(BOOL)succeeded {
    if (succeeded) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self signIn];
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
    
    MenuCell *newCell = [MenuCell new];
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
