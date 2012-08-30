//
//  MyTopicsViewController.m
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "CurrentUser.h"
#import "MyTopicsViewController.h"
#import "Topic.h"
#import "TopicsStore.h"
#import "TopicTableViewCell.h"

@interface MyTopicsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor =[UIColor darkGrayColor];
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
    Topic *topic = [[[TopicsStore sharedStore] topicsWithUserId:[CurrentUser currentUser].userId] objectAtIndex:indexPath.row];
    TopicTableViewCell *newCell = [TopicTableViewCell new];
    newCell.textLabel.text = topic.name;
    return newCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[TopicsStore sharedStore] topicsWithUserId:[CurrentUser currentUser].userId] count];
}

@end
