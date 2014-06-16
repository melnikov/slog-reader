//
//  BookContentViewController.m
//  NewspaperWorld
//
#import "BookContentViewController.h"
#import "BookmarkCell.h"
#import "ContentItemCell.h"
#import "Utils.h"
#import "NWBookContentItem.h"
#import <QuartzCore/QuartzCore.h>

#define ROW_COUNT 5

@interface BookContentViewController ()

- (void)deinitializeControls;

- (void)initializeNavigationBar;

- (IBAction)backButtonTouched:(id)sender;

@end

@implementation BookContentViewController

@synthesize parentPopover = _parentPopover;
@synthesize delegate = _delegate;

#pragma mark Memory management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];  
    if (self)
    {
        _table          = nil;
        _bookTitleView  = nil; 
        _cacheItem      = nil;
        _parentPopover  = nil;
        _delegate = nil;
        self.isDetailViewController = NO;
    }
    return self;
}

- (void)dealloc
{
    [self deinitializeControls];
    
    [_parentPopover release];   _parentPopover = nil;
    [_delegate release];
    [_cacheItem release];

    [super dealloc];
}


#pragma mark View life-cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self initializeNavigationBar];   
    if (_cacheItem)
    {
        _bookTitleView.bookTitle  = _cacheItem.bookCard.title;
        _bookTitleView.bookAuthor = _cacheItem.bookCard.authors;
    }
    [_table setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self deinitializeControls];
}

#pragma mark Public methods

+ (BookContentViewController*)createViewController
{
    return [[[BookContentViewController alloc] initWithNibName:@"BookContentViewController" bundle:nil] autorelease];
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
    self.navigationBarTitle = NSLocalizedString(@"IDS_CONTENT", @"");
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

#pragma mark TableViewDataSource Protocol

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContentItemCell* cell = [tableView dequeueReusableCellWithIdentifier:[ContentItemCell reuseIdentifier]];
    if (!cell)
    {
        cell = (ContentItemCell*)[Utils loadViewOfClass:[ContentItemCell class] FromNibNamed:[ContentItemCell nibName]];
    }
    if (cell)
    {
        NWBookContentItem* item = [_cacheItem.bookContent contentItemAtIndex:indexPath.row];
        if (item)
        {
            cell.title          = item.title;
            cell.isChapter = (item.depth == SectionDepthMainChapter);
            cell.relativeOffset = item.positionInBook;
            cell.bookmarksCount = item.bookmarksCount;
        }
        cell.isGrayBackground = (indexPath.row % 2 != 0);
        
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_cacheItem)  return 0;
    
    return _cacheItem.bookContent.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark Table implementation

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{     
    return [ContentItemCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    NWBookContentItem* chapter = [_cacheItem.bookContent contentItemAtIndex:indexPath.row];
    if (chapter)
    {
        if ([_delegate respondsToSelector:@selector(contentItemSelected:)])
            [_delegate contentItemSelected:chapter];
        
        [self backButtonTouched:nil];
    }
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
