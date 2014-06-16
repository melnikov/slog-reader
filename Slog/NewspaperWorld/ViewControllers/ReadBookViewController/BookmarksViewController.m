//
//  BookmarksViewController.m
//  NewspaperWorld
//

#import "BookmarksViewController.h"
#import "BookmarkCell.h"
#import "ContentItemCell.h"
#import "Utils.h"
#import "NWBookCard.h"
#import "NWBookmarks.h"
#import "NWDataModel.h"

@interface BookmarksViewController ()

- (void)deinitializeControls;

- (void)initializeNavigationBar;

- (IBAction)backButtonTouched:(id)sender;

@end

@implementation BookmarksViewController

@synthesize parentPopover = _parentPopover;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _parentPopover = nil;
        _cacheItem = nil;
        _bookTitleView = nil;
        _table = nil;
          _delegate = nil;
        self.isDetailViewController = NO;
    }
    return self;
}

- (void)dealloc
{
    [_cacheItem release];       _cacheItem = nil;
    [_parentPopover release];   _parentPopover = nil;
    [_delegate release];        _delegate = nil;
    
    [self deinitializeControls];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeNavigationBar];   
    if (_cacheItem)
    {
        _bookTitleView.bookTitle =  _cacheItem.bookCard.title;
        _bookTitleView.bookAuthor = _cacheItem.bookCard.authors;
    }
    [_table setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self deinitializeControls];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cacheItem.bookmarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookmarkCell* cell = [tableView dequeueReusableCellWithIdentifier:[BookmarkCell reuseIdentifier]];
    if (!cell)
    {
        cell = (BookmarkCell*)[Utils loadViewOfClass:[BookmarkCell class] FromNibNamed:[BookmarkCell nibName]];
    }
    if (cell)
    {
        NWBookmarkItem* item = [_cacheItem.bookmarks bookmarkAtIndex:indexPath.row];
        if (item)
        {
            cell.title          = item.title;
            cell.relativeOffset = item.positionInBook;
        }
        cell.isGrayBackground = (indexPath.row % 2 != 0);        
    }
    return cell;

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_cacheItem.bookmarks removeBookmarkAtIndex:(int)indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [[NWDataModel sharedModel].purchasedBooksCache save];
        [[NWDataModel sharedModel].demoFragmentsCache save];
      
        if ([_delegate respondsToSelector:@selector(bookmarkItemDeleted)])
            [_delegate bookmarkItemDeleted];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NWBookmarkItem* bookmark = [_cacheItem.bookmarks bookmarkAtIndex:(int)indexPath.row];
    if (bookmark)
    {
        if ([_delegate respondsToSelector:@selector(bookmarkItemSelected:)])
            [_delegate bookmarkItemSelected:bookmark];
        
        [self backButtonTouched:nil];
    }
}


#pragma mark Public methods

+ (BookmarksViewController*)createViewController
{
    return [[[BookmarksViewController alloc] initWithNibName:@"BookmarksViewController" bundle:nil] autorelease];
}

- (void)initializeWithBookCacheItem:(NWBookCacheItem*)item;
{
    [_cacheItem release]; _cacheItem = nil;
    _cacheItem = [item retain];
}

#pragma mark Private methods

- (void)deinitializeControls
{
    [_table release];           _table = nil;
    [_bookTitleView release];   _bookTitleView = nil;
    
}

- (void)initializeNavigationBar
{
    self.navigationBarTitle = NSLocalizedString(@"IDS_BOOKMARKS", @"");

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"IDS_BACK", @"")
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(backButtonTouched:)] autorelease];
	
	if(!IS_OS_7_OR_LATER && ![Utils isDeviceiPad])
		self.navigationController.navigationBar.backgroundColor = RGB(242, 242, 242);
}

- (IBAction)backButtonTouched:(id)sender
{
    if ([Utils isDeviceiPad])
    {    
        if (self.parentPopover)
            [self.parentPopover dismissPopoverAnimated:YES];
    }
    else
        [self dismissModalViewControllerAnimated:YES];
}


#pragma mark Popover delegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    
}
@end
