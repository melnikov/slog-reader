//
//  DemoFragmentsViewController.m
//  NewspaperWorld
//

#import "DemoFragmentsViewController.h"
#import "NWDataModel.h"
#import "BookItemCell.h"
#import "Utils.h"

@interface DemoFragmentsViewController (Private)

- (void)deinitialize;

- (void)createEditBarButton;

- (void)editButtonPressed:(id)sender;

@end

@implementation DemoFragmentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _editModeEnabled = NO;
        _bookIDToDelete = 0;
        _indexToDelete = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([Utils isDeviceiPad])
        [self createEditBarButton];
    
    self.navigationBarTitle = NSLocalizedString(@"IDS_FRAGMENTS", @"");
	
	background.image = [UIImage imageNamed:@"background_vert.jpg"];
}

- (void)viewWillAppear:(BOOL)animated
{    
    [self initializeWithCache:[NWDataModel sharedModel].demoFragmentsCache];
    [super viewWillAppear:animated];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookItemCell* cell = (BookItemCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.item1.showsDeleteButton = _editModeEnabled;
    cell.item2.showsDeleteButton = _editModeEnabled;
    cell.item3.showsDeleteButton = _editModeEnabled;
    
    return (UITableViewCell*)cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![Utils isDeviceiPad])
        return UITableViewCellEditingStyleDelete;
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NWBookCacheItem* item = [_sortedCache cacheItemAtIndex:(int)indexPath.row];
        _indexToDelete = [indexPath retain];
        [self deleteButtonOnBookItemTouchedWithBookID:item.bookCard.ID];
    }
}

- (void)deleteButtonOnBookItemTouchedWithBookID:(int)bookID
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"IDS_INFORMATION", nil) message:NSLocalizedString(@"IDS_DELETE_BOOK_ITEM_QUESTION", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"IDS_NO", nil) otherButtonTitles:NSLocalizedString(@"IDS_YES", nil), nil];
    [alert show];
    [alert release];
    
    _bookIDToDelete = bookID;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [_cache removeCacheItemWithID:_bookIDToDelete];
        [_sortedCache removeCacheItemWithID:_bookIDToDelete];
        
        if ([NWDataModel sharedModel].lastReadedBook.bookCard.ID == _bookIDToDelete)
        {
            [NWDataModel sharedModel].lastReadedBookID = UndefinedBookID;
        }
        
        [_cache save];
        
        _bookIDToDelete = 0;
        
        if ([Utils isDeviceiPad])
        {
            [_tableView reloadData];
        }
        else
        {
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_indexToDelete] withRowAnimation:UITableViewRowAnimationFade];
            [_indexToDelete release];
            _indexToDelete = nil;
        }
        
        _emptyListLabel.hidden = _cache.count > 0;
    }
}

#pragma mark Private methods

- (void)deinitialize
{
    [_editButton release];
}

- (void)createEditBarButton
{
    _editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"IDS_EDIT", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonPressed:)];
    self.navigationItem.rightBarButtonItem = _editButton;
}

- (void)editButtonPressed:(id)sender
{
    _editModeEnabled = !_editModeEnabled;
    
    if (_editModeEnabled)
    {
        [_editButton setTitle:NSLocalizedString(@"IDS_DONE", nil)];
    }
    else
    {
        [_editButton setTitle:NSLocalizedString(@"IDS_EDIT", nil)];
    }
    
    [_tableView reloadData];
}

#pragma mark Public methods

+ (DemoFragmentsViewController*)createViewController
{
    return [[[DemoFragmentsViewController alloc] initWithNibName:@"DemoFragmentsViewController" bundle:nil] autorelease];
}
@end
