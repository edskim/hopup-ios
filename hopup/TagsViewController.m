//
//  TagsViewController.m
//  hopup
//
//  Created by Edward Kim on 9/10/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "MBProgressHUD.h"
#import "NewTagViewController.h"
#import "SessionStore.h"
#import "TagCell.h"
#import "TagsStore.h"
#import "TagsViewController.h"
#import "TopicsStore.h"

@interface TagsViewController () <UITableViewDataSource,UITableViewDelegate> {
    BOOL editable;
}
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
    
    NSArray* myTopics = [[TopicsStore sharedStore] topicsWithUserId:[[SessionStore sharedStore] currentUser].userId];
    editable = [myTopics containsObject:[[[TopicsStore sharedStore] topicsByTopicId] objectForKey:@(self.topicId)]];

    if (editable) {
        UIBarButtonItem *addTopicButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTag:)];
        self.navigationItem.rightBarButtonItem = addTopicButton;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[TagsStore sharedStore] cacheTagsForTopicId:self.topicId withBlock:^(BOOL successful){
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

- (void)addTag:(UIBarButtonItem*)button {
    NewTagViewController *newTagViewController = [NewTagViewController new];
    newTagViewController.topicId = self.topicId;
    newTagViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    newTagViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    newTagViewController.completionBlock = ^{
        [self dismissModalViewControllerAnimated:YES];
    };
    [self presentViewController:newTagViewController animated:YES completion:NULL];
}

#pragma mark Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark Data Source methods
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TagCell *tagCell = (TagCell *)[self.tableView dequeueReusableCellWithIdentifier:@"TagCell"];
    if (tagCell == nil) {
        tagCell = [TagCell new];
    }
    
    Tag *tag = [[[TagsStore sharedStore] tagsForTopicId:self.topicId] objectAtIndex:indexPath.row];
    tagCell.cellTag = tag;
    return tagCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[TagsStore sharedStore] tagsForTopicId:self.topicId] count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return editable;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        TagCell *cellToDelete = (TagCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [[TagsStore sharedStore] deleteTagWithId:cellToDelete.cellTag.tagId withBlock:^(BOOL successful) {
            if (successful) {
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
}

@end
