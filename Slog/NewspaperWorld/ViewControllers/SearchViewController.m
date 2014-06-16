//
//  SearchViewController.m
//  NewspaperWorld
//


#import "SearchViewController.h"
#import "Utils.h"
#import "NWApiClient.h"
#import "SVProgressHUD.h"
#import "Constants.h"
#import "NWApiConstants.h"

#define CHARACTER_MIN_LENGHT 4


@interface SearchViewController ()

- (void)deinitiliaze; // general deinitilize function

- (void)addCancelButton;

- (void)removeCancelButton;

- (void)cancelBarButtonPressed:(UIBarButtonItem*)sender;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController.tabBarItem)
    {
        self.navigationController.tabBarItem.title = NSLocalizedString(@"IDS_SEARCH_TAB_TITLE", @"");
		
		self.title = NSLocalizedString(@"IDS_SEARCH_TAB_TITLE", @"");
    }
    
    self.emptyListText = NSLocalizedString(@"IDS_EMPTY_LIST",@"");
    
    _searchBar.placeholder = NSLocalizedString(@"IDS_TOUCH_FOR_SEARCH", @"");
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidChange:) name:@"SEARCH_TEXT_DID_CHANGE" object:nil];
}

- (void)deinitiliaze
{
    [_searchBar release];
    _searchBar = nil;
    [_searchToolbar release];
    _searchToolbar = nil;
    [_searchItem release];
    _searchItem = nil;
}
- (void)dealloc
{
    [self deinitiliaze];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self deinitiliaze];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        NSMutableArray* searchBarItems = [NSMutableArray arrayWithArray:_searchToolbar.items];
        
        if (searchBarItems.count > 0)
        {
            UIBarButtonItem* item = [searchBarItems objectAtIndex:0];
            
            // this condition check baritem to UIBarButtonSystemItemFlexibleSpace type
            if ((item.title) && (item.title.length > 0)) {
                [searchBarItems removeObjectAtIndex:0];
            }
        }
        
        [_searchToolbar setItems:searchBarItems animated:YES];
    }
	
	
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	//[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SEARCH_TEXT_DID_CHANGE" object:nil];
}

-(void)searchTextDidChange:(NSNotification*)notif
{
	_searchBar.text = notif.object;
	
	[self searchBarSearchButtonClicked:_searchBar];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
    NSMutableArray* searchBarItems = [NSMutableArray arrayWithArray:_searchToolbar.items];
    if ([self isKindOfClass:[SearchViewController class]]) {
        [_searchToolbar setItems:searchBarItems animated:YES];
    }
}

#pragma mark SearchBar protocol

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self addCancelButton];
    [self hideMasterView];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self removeCancelButton];
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text.length >=  CHARACTER_MIN_LENGHT)
    {
        [searchBar resignFirstResponder];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"IDS_PERFORMING_SEARCH", @"")];

        NSArray* languages = NWSupportedBookLanguages;
        [[NWApiClient sharedClient] findBooksWithKeyWords:searchBar.text delegate:self languages:languages fileTypes:NWSupportedBookFileTypes];
    }
    else
    {
         [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_SHORT_REQUEST", nil)];
    }
}

#pragma mark Public methods

+ (SearchViewController*)createViewController
{
    return [[[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil] autorelease];
}

#pragma mark Private methods

- (void)addCancelButton
{
    UIBarButtonItem* cancelButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"IDS_CANCEL", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelBarButtonPressed:)] autorelease];
    
    if ([Utils isDeviceiPad])
    {
        NSArray* items = [_searchToolbar.items arrayByAddingObject:cancelButton];
        [_searchToolbar setItems:items animated:YES];
    }
    else
    {
        [_searchItem setRightBarButtonItem:cancelButton animated:YES];
    }
}

- (void)removeCancelButton;
{
    if ([Utils isDeviceiPad])
    {
        NSMutableArray* items = [NSMutableArray arrayWithArray:_searchToolbar.items];
        [items removeLastObject];
        [_searchToolbar setItems:items animated:YES];
    }
    else
    {
        [_searchItem setRightBarButtonItem:nil animated:NO];
        [_searchBar sizeToFit];
    }
}

- (void)cancelBarButtonPressed:(UIBarButtonItem*)sender
{
    [_searchBar resignFirstResponder];
}

#pragma mark UISplitView delegate methods

- (void)addMasterButton
{
    if (![Utils isDeviceiPad] || !self.isDetailViewController)
        return;
     
    NSMutableArray* searchBarItems = [NSMutableArray arrayWithArray:_searchToolbar.items];
    if (self.masterButton != nil && [searchBarItems indexOfObject:self.masterButton] == NSNotFound)
    {
        [searchBarItems insertObject:self.masterButton atIndex:0];
    }
    [_searchToolbar setItems:searchBarItems animated:YES];
}

- (void)removeMasterButton
{
    if (![Utils isDeviceiPad] || !self.isDetailViewController)
        return;
    
    NSMutableArray* searchBarItems = [NSMutableArray arrayWithArray:_searchToolbar.items];
    if ([searchBarItems indexOfObject:self.masterButton] != NSNotFound)
    {
        [searchBarItems removeObjectAtIndex:0];
    }
    [_searchToolbar setItems:searchBarItems animated:YES];
}

#pragma mark NWApiClientDelegate

- (void)apiClientReceivedSearchResult:(NWBooksList*)books
{
    [self initializeWithBooksList:books title:NSLocalizedString(@"IDS_SEARCH_TAB_TITLE", @"")];
    [SVProgressHUD dismiss];
}

- (void)apiClientDidFailedExecuteMethod:(NSString*)methodName error:(NSError*)error
{
    [SVProgressHUD dismiss];
}
@end
