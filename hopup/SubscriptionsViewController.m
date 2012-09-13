//
//  SubscriptionsViewController.m
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "SubscriptionsStore.h"
#import "SubscriptionsViewController.h"
#import "TagsViewController.h"
#import "Topic.h"
#import "TopicsStore.h"
#import "TopicCell.h"
#import "UsersStore.h"

@interface SubscriptionsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong) UITableView *tableView;

@end

@implementation SubscriptionsViewController
@synthesize tableView;
@synthesize details;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"My Subscriptions";
        self.details = @"See the topics you have subscribed to";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[SubscriptionsStore sharedStore] cacheSubscriptionsWithBlock:^{
        [self.tableView reloadData];
    }];
    [[UsersStore sharedStore] cacheUsersWithBlock:^{
        [self.tableView reloadData];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)loadView {
    CGRect tableViewRect = [[UIScreen mainScreen] bounds];
    self.tableView = [[UITableView alloc] initWithFrame:tableViewRect];
    self.view = self.tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Subscriptions" style:UIBarButtonItemStyleBordered target:nil action:nil]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Topic *topic = [[[SubscriptionsStore sharedStore] subscribedTopics] objectAtIndex:(indexPath.row)];
    TagsViewController *tagsVC = [[TagsViewController alloc] init];
    tagsVC.topicId = topic.topicId;
    [self.navigationController pushViewController:tagsVC animated:YES];
}

#pragma mark Data Source methods
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Topic *topic = [[[SubscriptionsStore sharedStore] subscribedTopics] objectAtIndex:indexPath.row];
    TopicCell *newCell = (TopicCell *)[self.tableView dequeueReusableCellWithIdentifier:@"TopicCell"];
    if (newCell == nil) {
        newCell = [TopicCell new];
    }
    newCell.topic = topic;
    return newCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[SubscriptionsStore sharedStore] subscribedTopics] count];
}

@end
