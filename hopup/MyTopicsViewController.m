//
//  MyTopicsViewController.m
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "MyTopicsViewController.h"
#import "SessionStore.h"
#import "Topic.h"
#import "TopicsStore.h"
#import "TopicTableViewCell.h"
#import "User.h"

@interface MyTopicsViewController () <UITableViewDataSource,UITableViewDelegate>
@property (strong) UITableView *tableView;

@end

@implementation MyTopicsViewController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"My Topics";
        self.details = @"See the topics you have created";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [[TopicsStore sharedStore] cacheTopicsWithBlock:^{
        [self.tableView reloadData];
    }];
}

- (void)loadView {
    CGRect tableViewRect = [[UIScreen mainScreen] bounds];
    self.tableView = [[UITableView alloc] initWithFrame:tableViewRect];
    self.view = self.tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor darkGrayColor]];
    
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"My Topics" style:UIBarButtonItemStyleBordered target:nil action:nil]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark Data Source methods
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Topic *topic = [[[TopicsStore sharedStore] topicsWithUserId:[SessionStore sharedStore].currentUser.userId] objectAtIndex:indexPath.row];
    TopicTableViewCell *newCell = [TopicTableViewCell new];
    newCell.textLabel.text = topic.name;
    return newCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[TopicsStore sharedStore] topicsWithUserId:[SessionStore sharedStore].currentUser.userId] count];
}

@end
