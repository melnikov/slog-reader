//
//  NWBooksCache.m
//  NewspaperWorld
//

#import "NWBooksCache.h"
#import "AFJSONUtilities.h"
#import "Utils.h"
#import "NWBooksList.h"

@interface NWBooksCache ()

- (int)indexOfItemWithID:(int)ID;

- (id)initWithBookCache:(NWBooksCache*)bookCache;

@end

@implementation NWBooksCache

@synthesize count;

#pragma Memory management

- (id)init
{
    self = [super init];
    if (self)
    {
        _fileName = @"default_cacheItems_cache.plist";
        _cacheItems    = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithFileName:(NSString*)fileName
{
    self = [self init];
    if (self)
    {
        [_fileName release];
        _fileName = [[NSString alloc] initWithString:fileName];
    }
    return self;
}

- (void)dealloc
{
    [_fileName release];
    [_cacheItems release];
    [super dealloc];
}

#pragma mark Private methods

- (int)indexOfItemWithID:(int)ID
{
    int result = -1;

    for (int i = 0; i < [_cacheItems count]; i++)
    {
        NWBookCacheItem* book = [self cacheItemAtIndex:i];
        if (book.bookCard.ID == ID)
        {
            result =  i;
            break;
        }
    }
    return result;
}

- (id)initWithBookCache:(NWBooksCache*)bookCache
{
    self = [self initWithFileName:bookCache->_fileName];
    if (self)
    {
        [_cacheItems addObjectsFromArray:bookCache->_cacheItems];
    }
    return self;
}

#pragma Public methods

- (BOOL)save
{
    NSString* cacheFile = [[Utils cacheDirectoryPath] stringByAppendingPathComponent:_fileName];
    NSMutableArray* serializedBooks = [NSMutableArray array];
    for (NWBookCacheItem* item in _cacheItems)
    {
        [serializedBooks addObject:[item saveToDictionary]];
    }
    
    return [serializedBooks writeToFile:cacheFile atomically:YES];
}

- (void)load
{
    NSString* cacheFile = [[Utils cacheDirectoryPath] stringByAppendingPathComponent:_fileName];
    NSArray* cacheItemsArray = [NSArray arrayWithContentsOfFile:cacheFile];

    [_cacheItems removeAllObjects];
    for (NSDictionary* serializedCacheItem in cacheItemsArray)
    {
        NWBookCacheItem* item = [NWBookCacheItem cacheItemFromDictionary:serializedCacheItem];
        if (item)
            [_cacheItems addObject:item];
    }
}

- (void)addCacheItemForBookCard:(NWBookCard*)bookCard localFileName:(NSString*)fileName;
{
    if (!bookCard)
        return;

    NWBookCacheItem* item = [self cacheItemWithID:bookCard.ID];
    if (!item)
    {
        item = [NWBookCacheItem cacheItemWithBookCard:bookCard localFileName:fileName];
        [_cacheItems addObject:item];
    }
    else
    {
        int index = [self indexOfItemWithID:bookCard.ID];
        if (index != -1)
        {
            NWBookCacheItem* oldCard = [self cacheItemAtIndex:index];

            NSString*   newPath = oldCard.localPath;
            NWBookCard* newCard = oldCard.bookCard;
            NSFileManager* manager = [NSFileManager defaultManager];

            if ((oldCard.localPath == nil) || (newPath.length == 0) || (![manager fileExistsAtPath:newPath]))
                newPath = fileName;
            if (![oldCard.bookCard.title isEqualToString:bookCard.title])
                newCard = bookCard;

            NWBookCacheItem* newItem = [NWBookCacheItem cacheItemWithBookCard:newCard localFileName:newPath];
            [_cacheItems replaceObjectAtIndex:index withObject:newItem];
        }
    }
}

- (void)removeCacheItemWithID:(int)ID
{
    int index = [self indexOfItemWithID:ID];
    if (index != -1)
    {
        NWBookCacheItem* item = [self cacheItemAtIndex:index];

        // remove cover image for this book
        if (item) {
            [item clearCoverImageFile];
        }
        
        // remove local file with this book
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        
        if ((fileMgr) && ([fileMgr fileExistsAtPath:item.localPath])) {
            NSError* err = nil;
            BOOL res = [fileMgr removeItemAtPath:item.localPath error:&err];
            if (!res) NSLog(@"file deleting status: %@", err.localizedDescription);
        }
        
        // try to delete cached pdf file
        if ((fileMgr) && ([item.bookCard.fileType isEqualToString:@"pdf"]) && ([fileMgr fileExistsAtPath:[item.localPath stringByAppendingString:@".pdf"]])) {
            NSError* err = nil;
            BOOL res = [fileMgr removeItemAtPath:[item.localPath stringByAppendingString:@".pdf"] error:&err];
            if (!res) NSLog(@"file deleting status: %@", err.localizedDescription);
        }

        [_cacheItems removeObjectAtIndex:index];
    }
}


- (NWBookCacheItem*)cacheItemAtIndex:(int)index
{
    if (_cacheItems && index >= 0 && index < [_cacheItems count])
    {
        return (NWBookCacheItem*)[_cacheItems objectAtIndex:index];
    }
    return nil;
}

- (NWBookCacheItem*)cacheItemWithID:(int)ID
{
    NWBookCacheItem* result = nil;

    int index = [self indexOfItemWithID:ID];
    if (index != -1)
    {
        result = [self cacheItemAtIndex:index];
    }
    return result;
}

- (void)synchronizeWithBookList:(NWBooksList*)books
{ 
    for (int i = 0; i < [books count]; i++)
    {
        NWBookCard* book = [books bookAtIndex:i];
        [self addCacheItemForBookCard:book localFileName:nil];
    }
}

- (NWBooksCache*)sortedBooksCacheUsingComparator:(NSComparator)comparator
{
    NWBooksCache* sorted = [[[NWBooksCache alloc] initWithBookCache:self] autorelease];
    [sorted->_cacheItems sortUsingComparator:comparator];
    return sorted;
}

#pragma mark Property accessors

- (int)count
{
    return (int)[_cacheItems count];
}

@end
