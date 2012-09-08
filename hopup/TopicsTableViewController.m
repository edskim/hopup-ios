//
//  TopicsTableViewController.m
//  hopup
//
//  Created by Edward Kim on 9/7/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "MBProgressHUD.h"
#import "NewTopicCell.h"
#import "Topic.h"
#import "TopicsStore.h"
#import "TopicsTableViewController.h"
#import "TopicTableViewCell.h"

@interface TopicsTableViewController () <UITableViewDataSource,UITableViewDelegate,
                                        UITextFieldDelegate,UIGestureRecognizerDelegate,
                                        UISearchBarDelegate>
@property (strong) UITableView *tableView;
@property (strong) NSMutableArray *topics;
@property (strong) NSString *filterText;
@property (strong) UIButton *shadedSearchViewButton;
@property __block BOOL addingTopic;
@end

@implementation TopicsTableViewController
@synthesize tableView;
@synthesize details;
@synthesize backButtonText;
@synthesize dataSourceBlock;
@synthesize filterText;

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
    [self.tableView setBackgroundColor:[UIColor darkGrayColor]];
    
    //setup toolbar
    [self addAddButton];
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:self.navigationController.toolbar.frame];
    [[[searchBar subviews] objectAtIndex:0] removeFromSuperview];
    searchBar.placeholder = @"Search";

    searchBar.delegate = self;
    
    self.navigationItem.titleView = searchBar;
    
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:self.backButtonText style:UIBarButtonItemStyleBordered target:nil action:nil]];
    
    self.shadedSearchViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shadedSearchViewButton.frame = self.tableView.frame;
    self.shadedSearchViewButton.backgroundColor = [UIColor blackColor];
    self.shadedSearchViewButton.alpha = 0.5;
    [self.shadedSearchViewButton addTarget:self action:@selector(leaveSearchEditingMode) forControlEvents:UIControlEventTouchUpInside];
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
    [self addCancelButton];
}

- (void)cancelAddTopic:(UIBarButtonItem*)button {
    [self addAddButton];
    [self.view endEditing:YES];
    self.addingTopic = NO;
    NSIndexPath *newTopicIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newTopicIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)addAddButton {
    UIBarButtonItem *addTopicButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTopic:)];
    self.navigationItem.rightBarButtonItem = addTopicButton;
}

- (void)addCancelButton {
    UIBarButtonItem *cancelAddTopicButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleBordered target:self action:@selector(cancelAddTopic:)];
    cancelAddTopicButton.title = @"Cancel";
    self.navigationItem.rightBarButtonItem = cancelAddTopicButton;
}

- (NSArray*)filteredTopics {
    
    if (!filterText || [filterText length] == 0)
        return dataSourceBlock();
    
    NSMutableArray *filteredTopics = [NSMutableArray new];
    for (Topic *topic in dataSourceBlock()) {
        if ([[topic.name lowercaseString] rangeOfString:[self.filterText lowercaseString]].location != NSNotFound) {
            [filteredTopics addObject:topic];
        }
    }
    return filteredTopics;
}

#pragma mark Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark Data Source methods
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.addingTopic && indexPath.row == 0) {
        NewTopicCell *newCell = [[NewTopicCell alloc] init];
        newCell.textField.delegate = self;
        return newCell;
    } else {
        TopicTableViewCell *newCell = [[TopicTableViewCell alloc] init];
        Topic *topic = [[self filteredTopics] objectAtIndex:(indexPath.row-self.addingTopic)];
        newCell.textLabel.text = topic.name;
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
                [self cancelAddTopic:nil];
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
