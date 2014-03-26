//
//  NWBooksCache.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "NWBookCacheItem.h"

@class NWBooksList;

@interface NWBooksCache : NSObject
{
    NSMutableArray* _cacheItems;   
    
    NSString* _fileName;
}

- (id)initWithFileName:(NSString*)fileName;

- (BOOL)save;

- (void)load;

- (void)addCacheItemForBookCard:(NWBookCard*)bookCard localFileName:(NSString*)fileName;

- (void)removeCacheItemWithID:(int)ID;

- (NWBookCacheItem*)cacheItemAtIndex:(int)index;

- (NWBookCacheItem*)cacheItemWithID:(int)ID;

- (void)synchronizeWithBookList:(NWBooksList*)books;

- (NWBooksCache*)sortedBooksCacheUsingComparator:(NSComparator)comparator;

@property (nonatomic, readonly) int count;

@end
