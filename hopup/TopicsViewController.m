//
//  TopicsTableViewController.m
//  hopup
//
//  Created by Edward Kim on 9/7/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "MBProgressHUD.h"
#import "NewTopicCell.h"
#import "SubscriptionsStore.h"
#import "TagsViewController.h"
#import "Topic.h"
#import "TopicsStore.h"
#import "TopicsViewController.h"
#import "TopicCell.h"
#import "UsersStore.h"

@interface TopicsViewController () <UITableViewDataSource,UITableViewDelegate,
                                        UITextFieldDelegate,UIGestureRecognizerDelegate,
                                        UISearchBarDelegate>
@property (strong) UITableView *tableView;
@property (strong) NSMutableArray *topics;
@property (strong) UISearchBar *searchBar;
@property (strong) NSString *filterText;
@property (strong) UIButton *shadedSearchViewButton;
@property (strong) UIButton *shadedNewTopicButton;
@property __block BOOL addingTopic;
@end

@implementation TopicsViewController
@synthesize tableView;
@synthesize details;
@synthesize backButtonText;
@synthesize dataSourceBlock;
@synthesize filterText;
@synthesize searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.title = title;
    }
    return self;
}

-(void)loadView {
    CGRect tableViewRect = [[UIScreen mainScreen] bounds];
    self.tableView = [[UITableView alloc] initWithFrame:tableViewRect];
    self.view = self.tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //setup toolbar
    [self addAddButton];
    self.searchBar = [[UISearchBar alloc] initWithFrame:self.navigationController.toolbar.frame];
    [[[self.searchBar subviews] objectAtIndex:0] removeFromSuperview];
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:self.backButtonText style:UIBarButtonItemStyleBordered target:nil action:nil]];
    
    [self setupShadedButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[TopicsStore sharedStore] cacheTopicsWithBlock:^{
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

- (void)viewWillDisappear:(BOOL)animated {
    if (self.addingTopic) {
        [self cancelAddTopic];
    }
    [self leaveSearchEditingMode];
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

#pragma mark helper methods
- (void)addTopic:(UIBarButtonItem*)button {
    NSIndexPath *insertPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.addingTopic = YES;
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:insertPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView scrollToRowAtIndexPath:insertPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.tableView addSubview:self.shadedNewTopicButton];
    [self addCancelButton];
    [self.searchBar setHidden:YES];
}

- (void)cancelAddTopic {
    [self.shadedNewTopicButton removeFromSuperview];
    [self addAddButton];
    [self.view endEditing:YES];
    self.addingTopic = NO;
    NSIndexPath *newTopicIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newTopicIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.searchBar setHidden:NO];
}

- (void)addAddButton {
    UIBarButtonItem *addTopicButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTopic:)];
    self.navigationItem.rightBarButtonItem = addTopicButton;
}

- (void)addCancelButton {
    UIBarButtonItem *cancelAddTopicButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleBordered target:self action:@selector(cancelAddTopic)];
    cancelAddTopicButton.title = @"Cancel";
    self.navigationItem.rightBarButtonItem = cancelAddTopicButton;
}

- (NSArray*)filteredTopics {
    
    if (!filterText || [filterText length] == 0)
        return dataSourceBlock();
    
    NSMutableArray *filteredTopics = [NSMutableArray new];
    for (Topic *topic in dataSourceBlock()) {
        NSString *username = [[[UsersStore sharedStore] userWithId:topic.creatorId] username];
        if ([[topic.name lowercaseString] rangeOfString:[self.filterText lowercaseString]].location != NSNotFound ||
            [[username lowercaseString] rangeOfString:[self.filterText lowercaseString]].location != NSNotFound) {
            [filteredTopics addObject:topic];
        }
    }
    return filteredTopics;
}

- (void)setupShadedButtons {
    self.shadedSearchViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shadedSearchViewButton.frame = self.tableView.frame;
    self.shadedSearchViewButton.backgroundColor = [UIColor blackColor];
    self.shadedSearchViewButton.alpha = 0.5;
    [self.shadedSearchViewButton addTarget:self action:@selector(leaveSearchEditingMode) forControlEvents:UIControlEventTouchUpInside];
    
    self.shadedNewTopicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NewTopicCell *cell = [[NewTopicCell alloc] init];
    CGFloat insertCellHeight = cell.bounds.size.height;
    CGRect shadedButtonFrame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + insertCellHeight, self.tableView.bounds.size.width, self.tableView.bounds.size.height - insertCellHeight);
    self.shadedNewTopicButton.frame = shadedButtonFrame;
    self.shadedNewTopicButton.backgroundColor = [UIColor blackColor];
    self.shadedNewTopicButton.alpha = 0.5;
    [self.shadedNewTopicButton addTarget:self action:@selector(cancelAddTopic) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Topic *topic = [[self filteredTopics] objectAtIndex:(indexPath.row)];
    TagsViewController *tagsVC = [[TagsViewController alloc] init];
    tagsVC.topicId = topic.topicId;
    [self.navigationController pushViewController:tagsVC animated:YES];
}

#pragma mark Data Source methods
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.addingTopic && indexPath.row == 0) {
        NewTopicCell *newCell = [[NewTopicCell alloc] init];
        newCell.textField.delegate = self;
        return newCell;
    } else {
        TopicCell *newCell = (TopicCell *)[self.tableView dequeueReusableCellWithIdentifier:@"TopicCell"];
        if (newCell == nil) {
            newCell = [TopicCell new];
        }
        Topic *topic = [[self filteredTopics] objectAtIndex:(indexPath.row-self.addingTopic)];
        newCell.topic = topic;
        return newCell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self filteredTopics] count]+self.addingTopic;
}

#pragma mark UITextField delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    //process new topic here
    if ([textField.text length] > 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[TopicsStore sharedStore] createTopicWithName:textField.text withBlock:^{
            [[TopicsStore sharedStore] cacheTopicsWithBlock:^{
                [self.tableView reloadData];
                [self cancelAddTopic];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        }];
    }
    return NO;
}

#pragma mark UISearchBar delegate methods
- (void)leaveSearchEditingMode {
    [self.shadedSearchViewButton removeFromSuperview];
    [self.navigationItem.titleView endEditing:YES];
    [self addAddButton];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.filterText = searchText;
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.navigationItem.rightBarButtonItem = nil;
    [self.tableView addSubview:self.shadedSearchViewButton];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self leaveSearchEditingMode];
}

@end
