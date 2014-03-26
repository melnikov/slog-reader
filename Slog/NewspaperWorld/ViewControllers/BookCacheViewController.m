//
//  BookCacheViewController.m
//  NewspaperWorld
//


#import "BookCacheViewController.h"
#import "BookCacheViewControllerDescription.h"
#import "BookCardViewController.h"
#import "BookItemCell.h"
#import "UIStyleManager.h"
#import "Utils.h"
#import "Constants.h"
#import "NWBookCard.h"

typedef enum {
    BookCacheSortTypeTitle = 0,
    BookCacheSortTypeAuthor
} BookCacheSortType;

@interface BookCacheViewController (Private)

- (void)initializeDefaults;

- (void)fillCell:(BookItemCell*)cell WithData:(id)data AtIndexPath:(NSIndexPath*)indexPath;

- (void)handleNotification:(NSNotification*)notification;

- (void)showBookCard:(NWBookCard*)bookCard;

- (void)createSortSwitch;

- (void)sortSwitchStateChanged:(UISegmentedControl*)sender;

- (void)sortCacheWithSortType:(BookCacheSortType)sortType;

@end

@implementation BookCacheViewController

#pragma mark Memory management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initializeDefaults];
    }
    return self;
}

- (void)dealloc
{
    [_cache release]; _cache = nil;
    [_sortedCache release]; _sortedCache = nil;
    [super dealloc];
}

#pragma mark View life-cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createSortSwitch];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark Public methods

- (void)initializeWithCache:(NWBooksCache*)cache
{  
    [_cache release];
    _cache = [cache retain];
    
    [self sortCacheWithSortType:BookCacheSortTypeTitle];
    [_emptyListLabel setHidden:[self booksCount] > 0];
    
    [self reloadTable];
}

#pragma mark Private methods

- (NWBookCard*)bookAtIndex:(int)index
{
    return [_sortedCache cacheItemAtIndex:index].bookCard;
}

- (NWBookCard*)bookWithID:(int)ID
{
    return [_sortedCache cacheItemWithID:ID].bookCard;
}

- (int)booksCount
{
    return [_sortedCache count];
}

- (void)initializeWithClassDescription:(NSObject*)classInfo
{
    if (![classInfo isKindOfClass:[BookCacheViewControllerDescription class]])
        return;
    
    BookCacheViewControllerDescription* description = (BookCacheViewControllerDescription*)classInfo;
    
    [self initializeWithCache:description.cache];
}

- (void)initializeDefaults
{
    _cache = nil;
    _sortedCache = nil;
}

- (void)createSortSwitch
{
    UISegmentedControl* sortSwitch = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"IDS_TITLE", nil),
                                                                                                          NSLocalizedString(@"IDS_AUTHOR", nil), nil]] autorelease];
    sortSwitch.segmentedControlStyle = UISegmentedControlStyleBar;
    sortSwitch.selectedSegmentIndex = 0;
    [sortSwitch addTarget:self action:@selector(sortSwitchStateChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = sortSwitch;
}

- (void)sortSwitchStateChanged:(UISegmentedControl*)sender
{
    [self sortCacheWithSortType:sender.selectedSegmentIndex];
    [_tableView reloadData];
}

- (void)sortCacheWithSortType:(BookCacheSortType)sortType
{
    [_sortedCache release];
    _sortedCache = [[_cache sortedBooksCacheUsingComparator:^NSComparisonResult(id obj1, id obj2)
                                                            {
                                                                NWBookCacheItem* book1 = obj1;
                                                                NWBookCacheItem* book2 = obj2;
                                                                
                                                                NSComparisonResult result = NSOrderedSame;
                                                                switch (sortType) {
                                                                    case BookCacheSortTypeAuthor:
                                                                        result = [book1.bookCard.authors compare:book2.bookCard.authors];
                                                                        break;
                                                                    case BookCacheSortTypeTitle:
                                                                        result = [book1.bookCard.title compare:book2.bookCard.title];
                                                                        break;
                                                                    default:
                                                                        break;
                                                                }
                                                                
                                                                return result;
                                                            }] retain];
}

@end
