//
//  NWDataModel.m
//  NewspaperWorld
//

#import "NWDataModel.h"
#import "NWCategories.h"
#import "NWCategory.h"
#import "Constants.h"
#import "NWBooksCache.h"

#define LAST_BOOK_FILE_NAME @"lastReadBook"

static NWDataModel* _instance = nil;

/*
 Function removes static instance of class
 */
static void singleton_remover()
{
    [_instance release]; _instance = nil;
}

@implementation NWDataModel

@synthesize categories  = _categories;

@synthesize demoFragmentsCache = _demoFragmentsCache;

@synthesize purchasedBooksCache = _purchasedBooksCache;

@synthesize lastReadedBookID = _lastReadedBookID;

#pragma mark Memory management

- (id)init
{
    self = [super init];
    if (self)
    {
        _categories             = nil;
        _demoFragmentsCache     = [[NWBooksCache alloc] initWithFileName:@"demo_fragments_cache.plist"];
        _purchasedBooksCache    = [[NWBooksCache alloc] initWithFileName:@"purchased_books_cache.plist"];
        _lastReadedBookID = UndefinedBookID;
    }
    return self;
}

- (void)dealloc
{
    [_categories release];
    [_demoFragmentsCache release];
    [_purchasedBooksCache release];
    [super dealloc];
}

#pragma mark Public methods

+ (NWDataModel*)sharedModel
{
    if (!_instance)
    {
        _instance = [[NWDataModel alloc] init];
        atexit(singleton_remover);
    }
    return _instance;
}


#pragma mark Property accessors

- (void)setCategories:(NWCategories*)newCategories
{
    if (newCategories == _categories)
        return;
    
    [_categories release];
    _categories = [newCategories retain];
}

-(void)loadState
{    
    [_demoFragmentsCache load];
    [_purchasedBooksCache load];
    
    int lastReadedID =  [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_BOOK_FILE_NAME] intValue];
    [NWDataModel sharedModel].lastReadedBookID = lastReadedID;
}

- (void)saveLastBook
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_lastReadedBookID] forKey:LAST_BOOK_FILE_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NWBookCacheItem*)cacheItemWithBookID:(int)bookID
{
    NWBookCacheItem* result = [_purchasedBooksCache cacheItemWithID:bookID];
    if (!result)
    {
        result = [_demoFragmentsCache cacheItemWithID:bookID];
    }
    return result;
}

- (NWBookCacheItem*)lastReadedBook
{
    if (_lastReadedBookID == UndefinedBookID)
        return nil;
    return [self cacheItemWithBookID:_lastReadedBookID];
}
#pragma mark Private methods


@end
