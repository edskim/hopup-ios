//
//  ProfileViewController.m
//  hopup
//
//  Created by Edward Kim on 9/17/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "FormTextCell.h"
#import "ProfileViewController.h"
#import "SessionStore.h"

@interface ProfileViewController () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *profilePicBorder;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UITableView *userPropertyTableView;
@property (strong) NSArray *userProperties;
@end

@implementation ProfileViewController
@synthesize profilePicBorder;
@synthesize profilePicture;
@synthesize userPropertyTableView;
@synthesize userProperties;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.userProperties = [NSArray arrayWithObjects:@"Username",@"Email", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]];
    self.profilePicBorder.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundNavigationBar.png"]];
    self.profilePicture.image = [UIImage imageNamed:@"AvatarPlaceholder.png"];
}

- (void)viewDidUnload
{
    [self setProfilePicBorder:nil];
    [self setProfilePicture:nil];
    [self setUserPropertyTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITablView data source methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FormTextCell *field = [FormTextCell new];
    field.textLabel.text = [self.userProperties objectAtIndex:indexPath.row];
    User *currentUser = [[SessionStore sharedStore] currentUser];
    if ([field.textLabel.text isEqualToString:@"Username"]) {
        field.input.text = currentUser.username;
    } else if ([field.textLabel.text isEqualToString:@"Email"]) {
        field.input.text = currentUser.email;
    }
    return field;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.userProperties count];
}

@end
