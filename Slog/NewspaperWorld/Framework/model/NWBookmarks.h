//
//  NWBookmarks.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "NWBookmarkItem.h"

@interface NWBookmarks : NSObject
{
    NSMutableArray* _bookmarks;
}

@property (nonatomic, readonly) int count;

- (void)addBookmark:(NWBookmarkItem*)bookmark;

- (void)removeBookmarkAtIndex:(int)index;

- (void)removeBookmarkWithFB2ItemID:(int)ID;

- (void)removeAllBookmarks;

- (NWBookmarkItem*)bookmarkAtIndex:(int)index;

- (NWBookmarkItem*)bookmarkWithFB2ItemID:(int)ID;

- (NWBookmarkItem*)bookmarkWithFB2ItemID:(int)ID offset:(int)offset;

- (BOOL)loadFromArray:(NSArray*)array;

- (NSArray*)saveToArray;

@end
