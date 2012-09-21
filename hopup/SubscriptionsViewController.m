//
//  SubscriptionsViewController.m
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "MBProgressHUD.h"
#import "SessionStore.h"
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
    
    //Show user what selection they were viewing
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
	if (selection)
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
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
    
    __weak SubscriptionsViewController* weakSelf = self;
    __weak TopicCell *weakCell = newCell;
    newCell.onDidUnSubscribe = ^{
        [weakSelf.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[weakSelf.tableView indexPathForCell:weakCell]] withRowAnimation:UITableViewRowAnimationLeft];
    };
    
    return newCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray* myTopics = [[TopicsStore sharedStore] topicsWithUserId:[[SessionStore sharedStore] currentUser].userId];
    return ([myTopics containsObject:[[[SubscriptionsStore sharedStore] subscribedTopics] objectAtIndex:(indexPath.row)]]);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        TopicCell *cellToDelete = (TopicCell*)[self.tableView cellForRowAtIndexPath:indexPath];

        [[TopicsStore sharedStore] deleteTopicWithTopicId:cellToDelete.topic.topicId withBlock:^(BOOL successful) {
            if (successful) {
                [[SubscriptionsStore sharedStore] removeLocalStoreSubscriptionWithTopicId:cellToDelete.topic.topicId];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[SubscriptionsStore sharedStore] subscribedTopics] count];
}



@end
