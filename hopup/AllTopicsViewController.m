//
//  AllTopicsViewController.m
//  hopup
//
//  Created by Edward Kim on 8/28/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "AllTopicsViewController.h"
#import "MBProgressHUD.h"
#import "Topic.h"
#import "TopicsStore.h"
#import "TopicTableViewCell.h"

@interface AllTopicsViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>
@property (strong) UITableView *tableView;
@property (strong) NSMutableArray *topics;
@property __block BOOL addingTopic;
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
    

    [self addAddButton];
//    UISearchBar *testSearch = [[UISearchBar alloc] initWithFrame:self.navigationController.toolbar.frame];
//    self.navigationItem.titleView = testSearch;
    
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

#pragma mark Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark Data Source methods
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TopicTableViewCell *newCell = [[TopicTableViewCell alloc] init];
    if (self.addingTopic && indexPath.row == 0) {
        newCell.accessoryType = UITableViewCellAccessoryNone;
        UITextField *newTopicTextField = [[UITextField alloc] initWithFrame:CGRectInset(newCell.frame, 10, 7)];
        newTopicTextField.backgroundColor = [UIColor whiteColor];
        newTopicTextField.placeholder = @"Enter new topic name.";
        newTopicTextField.borderStyle = UITextBorderStyleRoundedRect;
        newTopicTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        newTopicTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        newTopicTextField.delegate = self;
        
        [newCell addSubview:newTopicTextField];
    } else {
        TopicsStore *sharedStore = [TopicsStore sharedStore];
        Topic *topic = [[sharedStore allTopics] objectAtIndex:(indexPath.row-self.addingTopic)];
        newCell.textLabel.text = topic.name;
    }
    
    return newCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TopicsStore *sharedStore = [TopicsStore sharedStore];
    return [[sharedStore allTopics] count]+self.addingTopic;
}

#pragma mark UITextField delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    //process new topic here
    if ([textField.text length] > 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[TopicsStore sharedStore] createTopicWithName:textField.text withBlock:^{
            self.addingTopic = NO;
            [[TopicsStore sharedStore] cacheTopicsWithBlock:^{
                [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        }];
    }
    return NO;
}

@end
