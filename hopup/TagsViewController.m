//
//  TagsViewController.m
//  hopup
//
//  Created by Edward Kim on 9/10/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "MBProgressHUD.h"
#import "TagCell.h"
#import "TagsStore.h"
#import "TagsViewController.h"
#import "TopicsStore.h"

@interface TagsViewController () <UITableViewDataSource,UITableViewDelegate>
@property (strong) UITableView *tableView;
@end

@implementation TagsViewController
@synthesize topicId;
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)loadView {
    self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = self.tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.title = [[[[TopicsStore sharedStore] topicsByTopicId] objectForKey:@(self.topicId)] name];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[TagsStore sharedStore] cacheTagsForTopicId:self.topicId withBlock:^{
        [self.tableView reloadData];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    Tag *tag = [[[TagsStore sharedStore] tagsForTopicId:self.topicId] objectAtIndex:indexPath.row];
    TagCell *tagCell = [TagCell new];
    tagCell.textLabel.text = tag.text;
    tagCell.detailTextLabel.text = tag.location;
    return tagCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[TagsStore sharedStore] tagsForTopicId:self.topicId] count];
}

@end
