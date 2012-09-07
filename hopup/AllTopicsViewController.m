//
//  AllTopicsViewController.m
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "AllTopicsViewController.h"
#import "Topic.h"
#import "TopicsStore.h"
#import "TopicTableViewCell.h"

@interface AllTopicsViewController () <UITableViewDataSource,UITableViewDelegate>
@property (strong) UITableView *tableView;
@property (strong) NSMutableArray *topics;
@end

@implementation AllTopicsViewController
@synthesize tableView;
@synthesize details;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"All Topics";
        self.details = @"See all topics available";
    }
    return self;
}

-(void)loadView {
    CGRect tableViewRect = [[UIScreen mainScreen] bounds];
    self.tableView = [[UITableView alloc] initWithFrame:tableViewRect];
    self.view = self.tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor darkGrayColor]];
    
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"All Topics" style:UIBarButtonItemStyleBordered target:nil action:nil]];
}

- (void)viewWillAppear:(BOOL)animated {
    [[TopicsStore sharedStore] cacheTopicsWithBlock:^{
        [self.tableView reloadData];
    }];
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
    TopicsStore *sharedStore = [TopicsStore sharedStore];
    TopicTableViewCell *newCell = [[TopicTableViewCell alloc] init];
    Topic *topic = [[sharedStore allTopics] objectAtIndex:indexPath.row];
    newCell.textLabel.text = topic.name;
    return newCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TopicsStore *sharedStore = [TopicsStore sharedStore];
    return [[sharedStore allTopics] count];
}

@end
