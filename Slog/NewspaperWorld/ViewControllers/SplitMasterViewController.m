//
//  SplitMasterViewController.m
//  NewspaperWorld
//

#import "SplitMasterViewController.h"
#import "UIStylemanager.h"
#import "Constants.h"
#import "Utils.h"
#import "NWDataModel.h"
#import "ReadBookViewController.h"
#import "MyBooksSectionCell.h"
#import "NWApiClient.h"
#import "SVProgressHUD.h"

#define LACK_OF_STORE_BGVIEW  -20
#define LACK_OF_MYBOOK_BGVIEW  18

const static int myBooksHeight      = 200;
const static int lastBookCellRow    = 0;
const static int fragmentsCellRow   = 1;
const static int myBooksCellRow     = 2;

@interface SplitMasterViewController (Private)

- (CGFloat)calculateStoreSectionViewHeight;
- (void)updateSectionsGeometry;
- (void)deselectRowIfSelectedAtIndexPath:(NSIndexPath*)indexPath inTable:(UITableView*)tableView;

@end

@implementation SplitMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    { 
        _myBooksSectionTitles = [[NSArray alloc] initWithObjects:NSLocalizedString(@"IDS_READ_LAST", @""),
                                                                 NSLocalizedString(@"IDS_FRAGMENTS", @""),
                                                                 NSLocalizedString(@"IDS_MY_BOOKS_LIST", @""), nil];
        _myBooksSectionImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"last_book"],
                                                                 [UIImage imageNamed:@"demo_books"],
                                                                 [UIImage imageNamed:@"purchased_books"],nil];
         self.isDetailViewController = NO;
    }
    return self;
}

- (void)dealloc
{
    [_myBooksSectionImages release];
    [_myBooksSectionTitles release];
    [_myBooksLastSelectedIndex release];
    [_storeLastSelectedIndex release];
    [_bottomView release];           _bottomView = nil;
    [_myBooksTable release];         _myBooksTable = nil;
    [_storeBackgroundView release];  _storeBackgroundView = nil;
    [_myBooksBackgroundView release]; _myBooksBackgroundView = nil;

	[searchView release];
	[searchTextField release];
    [super dealloc];
}

- (void)defaultInitializeCategories
{
    if (!_categories)
    {
        _needShowSections = NO;
        [self initializeWithCategories:[NWDataModel sharedModel].categories title:nil/*NSLocalizedString(@"IDS_BOOKSTORE_TAB_TITLE", @"")*/];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.needShowSections = NO;
   
    _myBooksTable.separatorColor = [UIColor clearColor];
    
    _storeBackgroundView.delegate = self;
    [_storeBackgroundView setButtonTitle:NSLocalizedString(@"IDS_BOOKSTORE_TAB_TITLE", @"")];
    _storeBackgroundView.expandIndicatorImage = [UIImage imageNamed:@"arrow_right"];
    _storeBackgroundView.rollupIndicatorImage = [UIImage imageNamed:@"arrow_down"];
    NSLog(@"left height %f:", self.view.bounds.size.height);
    _storeBackgroundView.expandHeight = [self calculateStoreSectionViewHeight] - _storeBackgroundView.expandButtonHeight;
    
    _myBooksBackgroundView.expandHeight = _myBooksTable.rowHeight*3;
    _myBooksBackgroundView.delegate = self;
    [_myBooksBackgroundView setButtonTitle:NSLocalizedString(@"IDS_MY_BOOKS_TITLE", @"")];    
    _myBooksBackgroundView.expandIndicatorImage = [UIImage imageNamed:@"arrow_right"];
    _myBooksBackgroundView.rollupIndicatorImage = [UIImage imageNamed:@"arrow_down"];
    
    UIImage* logoImage = [UIImage imageNamed:@"logo"];
    UIImageView* logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    self.navigationItem.titleView = nil;
	
	//self.navigationItem.titleView.frame = CGRectMake(0, 0, 309, 200);
    [logoImageView release];
    
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 300.0);
    
    
//    CGRect frame = _storeBackgroundView.frame;
//    _storeBackgroundView.frame = CGRectMake(frame.origin.x, frame.origin.y+40, frame.size.width, frame.size.height);
//    
//    frame = _myBooksBackgroundView.frame;
//    _myBooksBackgroundView.frame = CGRectMake(frame.origin.x, frame.origin.y+40, frame.size.width, frame.size.height);
    
    _yOrigin = _storeBackgroundView.frame.origin.y;
	
	background.image = [UIImage imageNamed:@"background_menu.jpg"];
}

- (void)viewDidUnload
{
	[searchView release];
	searchView = nil;
	[searchTextField release];
	searchTextField = nil;
    [super viewDidUnload];
    [_bottomView release];           _bottomView = nil;
    [_myBooksTable release];         _myBooksTable = nil;
    [_storeBackgroundView release];  _storeBackgroundView = nil;
    [_myBooksBackgroundView release]; _myBooksBackgroundView = nil;
	
	
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateSectionsGeometry];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //extra check and correction lack of navigation bar shift after splash screen rotation
    if (self.navigationController.navigationBar.frame.origin.y > 0)
    {
        if ([Utils isiOS7]){
            //CGRect navFrame = self.navigationController.navigationBar.frame;
            //self.navigationController.navigationBar.frame = CGRectMake(navFrame.origin.x,0.0f, navFrame.size.width,navFrame.size.height);
        }else{
            CGRect navFrame = self.navigationController.navigationBar.frame;
            self.navigationController.navigationBar.frame = CGRectMake(navFrame.origin.x,0.0f, navFrame.size.width,navFrame.size.height);
            CGRect frame =  _storeBackgroundView.frame;
            _storeBackgroundView.frame = CGRectMake(frame.origin.x,LACK_OF_STORE_BGVIEW, frame.size.width, frame.size.height);
            _myBooksBackgroundView.frame = CGRectMake(frame.origin.x,LACK_OF_MYBOOK_BGVIEW, frame.size.width, frame.size.height);
        }
    }
    else
    {
      [self updateSectionsGeometry];
    }
}

#pragma mark Public implementation

- (IBAction)searchButtonTouched:(id)sender
{
	[self shouldOpenSearch:YES];
	
    [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_SHOULDSHOW_NOTIFICATION object:self];
}

-(void)shouldOpenSearch:(BOOL)shouldOpen
{
	CGRect searchRect = searchView.frame;
	
	CGRect storeRect = _storeBackgroundView.frame;
	
	if(searchRect.size.height == 0 && shouldOpen)
	{
		//rect.origin.y += 140 - 69;
		
		storeRect.origin.y += 76;
		
		searchRect.size.height = 76;
	}
	else if(searchRect.size.height == 76 && !shouldOpen)
	{
		//rect.origin.y -= 140 - 69;
		
		storeRect.origin.y -= 76;
		
		searchRect.size.height = 0;
	}
	
	(shouldOpen ? [searchTextField becomeFirstResponder] : [searchTextField resignFirstResponder]);
	
	[UIView beginAnimations:@"ExpandSearchAnimation" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelay:0.001];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	searchView.frame = searchRect;
	
	_storeBackgroundView.frame = storeRect;
	
	[self updateSectionsGeometry];
	
	[UIView commitAnimations];
}

- (IBAction)helpButtonTouched:(id)sender
{
	if(searchView.frame.size.height > 0)
	{
		[self shouldOpenSearch:NO];
	}
	
    [[NSNotificationCenter defaultCenter] postNotificationName:HELP_SHOULDSHOW_NOTIFICATION object:self];
}

+ (SplitMasterViewController*)createViewController
{
    SplitMasterViewController* bookStore = [[[SplitMasterViewController alloc] initWithNibName:@"SplitMasterViewController"
                                                                                       bundle:nil] autorelease];    
    return bookStore;
}

#pragma mark TableViewDataSource Protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _myBooksTable)
        return [_myBooksSectionTitles count];
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _myBooksTable)
    {
		BookCategoryCell* cell = [tableView dequeueReusableCellWithIdentifier:[BookCategoryCell reuseIdentifier]];
		if (!cell)
			cell = (BookCategoryCell*)[Utils loadViewOfClass:[BookCategoryCell class] FromNibNamed:[BookCategoryCell nibName]];
		
//        MyBooksSectionCell* cell = [tableView dequeueReusableCellWithIdentifier:MyBooksSectionCellID];
//        if (!cell)
//        {
//            cell = (MyBooksSectionCell*)[Utils loadViewOfClass:[MyBooksSectionCell class] FromNibNamed:@"MyBooksSectionCell"];
//        }        
//
        cell.showBottomSeparator = (indexPath.row == [_myBooksSectionTitles count] - 1);        
        cell.title               = [_myBooksSectionTitles objectAtIndex:indexPath.row];
//        cell.icon                = [_myBooksSectionImages objectAtIndex:indexPath.row];
		
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _myBooksTable)
        return 1;
    return [super numberOfSectionsInTableView:tableView];
}

#pragma mark TableView delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.backgroundColor = [UIColor clearColor];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _myBooksTable)
        return nil;
    return [super tableView:tableView viewForHeaderInSection:section];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _myBooksTable)
        return 0;
    return [super tableView:tableView heightForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(searchView.frame.size.height > 0)
	{
		[self shouldOpenSearch:NO];
	}
	
    [self deselectRowIfSelectedAtIndexPath:indexPath inTable:tableView];
    
    if (tableView == _myBooksTable)
    {
        NSString* notificationID = nil;     
        switch (indexPath.row)
        {
            case lastBookCellRow:
            {
                if ([NWDataModel sharedModel].lastReadedBook)
                {
                    NWBookCacheItem* item = [NWDataModel sharedModel].lastReadedBook;
                    [ReadBookViewController readBookCacheItem:item parent:self];
                }
                
            }
            break;
            case fragmentsCellRow:  notificationID = FRAGMENTS_SHOULDSHOW_NOTIFICATION;     break;
            case myBooksCellRow:    notificationID = MY_BOOKS_SHOULDSHOW_NOTIFICATION;      break;
        }
        if (notificationID)
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationID object:self];
    }
    else
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark Expandablу view delegate 

- (BOOL)expandableViewShouldExpand:(ExpandableView *)view
{
    if (view == _storeBackgroundView)
    {
        if (_categories.count == 0 && !_loadingData)
        {
            _loadingData = YES;
            _storeBackgroundView.expandHeight = 0;
            
            if ([NWApiClient sharedClient].applicationAuthorized == NO)
            {
                [[NWApiClient sharedClient] authorizeApplicationWithUID:[UIDevice currentDevice].uniqueDeviceIdentifier delegate:self];
            }
            else
            {
                [[NWApiClient sharedClient] getCategoriesWithDelegate:self];
            }
            return YES;
        }
        else
        {
            return YES;
        }
    }
    
    return YES;
}

- (void)expandButtonTouched:(ExpandableView *)sender
{
	if(sender == _storeBackgroundView)
	{
		if(_myBooksBackgroundView.isExpanded)
		{
			[_myBooksBackgroundView expand:NO];
		}
	}
	else
	{
		if(_storeBackgroundView.isExpanded)
		{
			[_storeBackgroundView expand:NO];
		}
	}
	
    if (!_loadingData)
        [self updateSectionsGeometry];
}

#pragma mark Private methods
- (CGFloat)calculateStoreSectionViewHeight
{
    int marginiOS7 = 0;
    if ([Utils isiOS7]){
        //marginiOS7 = 60;
		marginiOS7 = 0;
    }
    
    CGFloat superViewHeight = _storeBackgroundView.superview.bounds.size.height - _storeBackgroundView.frame.origin.y;
    CGFloat bottomViewHeight = _bottomView.bounds.size.height;
    CGFloat currentMyBooksViewHeight = (_myBooksBackgroundView.isExpanded) ? _myBooksBackgroundView.expandButtonHeight + _myBooksBackgroundView.expandHeight
                                                                           : _myBooksBackgroundView.expandButtonHeight;
    
    CGFloat newHeight = (_storeBackgroundView.isExpanded && _categories.count > 0) ? superViewHeight - bottomViewHeight - currentMyBooksViewHeight - marginiOS7
                                                          : _storeBackgroundView.expandButtonHeight;
    
	newHeight += _storeBackgroundView.frame.origin.y;
	
    return newHeight;
}

- (void)updateSectionsGeometry;
{
    int marginiOS7 = 0;
    
    CGFloat newStoreSectionHeight = [self calculateStoreSectionViewHeight];
    CGFloat newMyBooksSectionY = newStoreSectionHeight + marginiOS7;
    
    CGRect newFrame = _myBooksBackgroundView.frame;
    newFrame.origin.y = newMyBooksSectionY;
    _myBooksBackgroundView.frame = newFrame;
	
	if ([Utils isiOS7]){
        marginiOS7 = 60;
    }
    
    _storeBackgroundView.expandHeight = newStoreSectionHeight - _storeBackgroundView.expandButtonHeight - _storeBackgroundView.frame.origin.y;
}

- (void)deselectRowIfSelectedAtIndexPath:(NSIndexPath*)indexPath inTable:(UITableView*)tableView
{
    if (_myBooksTable == tableView)
    {
        if (_storeLastSelectedIndex != nil)
        {
            [_tableView deselectRowAtIndexPath:_storeLastSelectedIndex animated:YES];
            [_storeLastSelectedIndex release];
            _storeLastSelectedIndex = nil;
        }
        
        [_myBooksLastSelectedIndex release];
        _myBooksLastSelectedIndex = [indexPath retain];
    }
    else
    {
        if (_myBooksLastSelectedIndex != nil)
        {
            [_myBooksTable deselectRowAtIndexPath:_myBooksLastSelectedIndex animated:YES];
            [_myBooksLastSelectedIndex release];
            _myBooksLastSelectedIndex = nil;
        }
        
        [_storeLastSelectedIndex release];
        _storeLastSelectedIndex = [indexPath retain];
    }
}

- (void)performGetCategoriesRequest
{
    _emptyListLabel.hidden = YES;
}

- (void)apiClientReceivedCategories:(NWCategories *)categories
{
    [NWDataModel sharedModel].categories = categories;
    
    [self defaultInitializeCategories];
    
    [[NWApiClient sharedClient] getPurchasedBooksWithDelegate:self];
}

- (void)apiClientReceivedPurchasedBooks:(NWBooksList *)books
{
    [[NWDataModel sharedModel].purchasedBooksCache synchronizeWithBookList:books];
    _loadingData = NO;
    [_storeBackgroundView expand:YES];
}

- (void)apiClientDidFailedExecuteMethod:(NSString*)methodName error:(NSError*)error
{
    if (_loadingData)
    {
        _loadingData = NO;
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"IDS_ERROR", nil)
                                                        message:NSLocalizedString(@"IDS_NETWORK_ERROR_OCCURED", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else
    {
        [SVProgressHUD dismiss];
    }
}

#pragma mark TextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	[[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_SHOULDSHOW_NOTIFICATION object:self];
	
	return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_SHOULDSHOW_NOTIFICATION object:self];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SEARCH_TEXT_DID_CHANGE" object:searchTextField.text];
	
	return YES;
}

@end
