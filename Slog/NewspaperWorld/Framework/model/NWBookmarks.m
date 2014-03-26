//
//  NWBookmarks.m
//  NewspaperWorld
//

#import "NWBookmarks.h"

@implementation NWBookmarks

- (id)init
{
    self = [super init];
    if (self) {
        _bookmarks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_bookmarks release];
    
    [super dealloc];
}

#pragma mark Public methods

- (void)addBookmark:(NWBookmarkItem*)bookmark
{
    if (!bookmark)
        return;
      
    [_bookmarks addObject:bookmark];
}

- (void)removeBookmarkAtIndex:(int)index
{
    if (index < 0 || index >= _bookmarks.count)
        return;
    
    [_bookmarks removeObjectAtIndex:index];
}

- (void)removeBookmarkWithFB2ItemID:(int)ID
{
    NWBookmarkItem* bookmarkToRemove = [self bookmarkWithFB2ItemID:ID];
    
    if (bookmarkToRemove != nil)
        [_bookmarks removeObject:bookmarkToRemove];
}

- (void)removeAllBookmarks
{
    [_bookmarks removeAllObjects];
}

- (NWBookmarkItem*)bookmarkAtIndex:(int)index
{
    if (index < 0 || index >= _bookmarks.count)
        return  nil;
    
    return [_bookmarks objectAtIndex:index];
}

- (NWBookmarkItem*)bookmarkWithFB2ItemID:(int)ID
{
    for (NWBookmarkItem* item in _bookmarks)
    {
        if (item.fb2ItemID == ID)
            return item;
    }
    return nil;
}

- (NWBookmarkItem*)bookmarkWithFB2ItemID:(int)ID offset:(int)offset
{
    for (NWBookmarkItem* item in _bookmarks)
    {
        if ((item.fb2ItemID == ID) && (item.offset == offset))
            return item;
    }
    return nil;
}

- (BOOL)loadFromArray:(NSArray*)array
{
    if (!array || array.count == 0)
        return NO;
    
    [_bookmarks removeAllObjects];
    
    for (NSDictionary* dict in array)
    {
        NWBookmarkItem* item = [NWBookmarkItem itemFromDictionary:dict];
        if (item)
            [_bookmarks addObject:item];
    }    
    return YES;
}

- (NSArray*)saveToArray
{
    NSMutableArray* result = [[[NSMutableArray alloc] init] autorelease];
    
    for (NWBookmarkItem* item in _bookmarks)
        [result addObject:[item dictionary]];
    
    return result;
}

#pragma mark Property accessors

- (int)count
{
    return _bookmarks.count;
}

#pragma mark Private methods

@end
