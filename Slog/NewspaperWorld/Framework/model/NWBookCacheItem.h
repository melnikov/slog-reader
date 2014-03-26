//
//  NWBookCacheItem.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "NWBookCard.h"
#import "NWBookContent.h"
#import "NWBookmarks.h"

@interface NWBookCacheItem : NSObject
{
    NWBookCard* _bookCard;

    NWBookContent*  _bookContent;

    NWBookmarks*  _bookmarks;

    NSString*   _localPath;

    NSString* _coverImagePath;

    UIImage*     _coverImage;
}

+ (NWBookCacheItem*)cacheItemWithBookCard:(NWBookCard*)bookCard localFileName:(NSString*)fileName;

+ (NWBookCacheItem*)cacheItemFromDictionary:(NSDictionary*)dictionary;

- (id)initWithBookCard:(NWBookCard*)bookCard localFileName:(NSString*)fileName;

- (BOOL)loadFromDictionary:(NSDictionary*)dictionary;

- (NSDictionary*)saveToDictionary;

- (void)clearCoverImageFile;

@property (nonatomic, readonly) NWBookCard* bookCard;

@property (nonatomic, readonly) NSString* localPath;

@property (nonatomic, readonly) NSString* coverImagePath;

@property (nonatomic, readonly) NWBookContent* bookContent;

@property (nonatomic, readonly) NWBookmarks* bookmarks;

@property (nonatomic, retain) NWBookmarkItem* positionBookmark;

@property (nonatomic, retain) UIImage* image;

@end
