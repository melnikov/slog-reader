//
//  NWDataModel.h
//  NewspaperWorld
//


#import <UIKit/UIKit.h>
#import "NWCategories.h"
#import "NWBooksCache.h"

#define UndefinedBookID  -324324234

@interface NWDataModel : NSObject
{
    NWCategories* _categories;
    
    NWBooksCache* _demoFragmentsCache;
    
    NWBooksCache* _purchasedBooksCache;
}

+ (NWDataModel*)sharedModel;

- (void)loadState;

- (void)saveLastBook;

- (NWBookCacheItem*)cacheItemWithBookID:(int)bookID;

@property (nonatomic, retain) NWCategories* categories;

@property (nonatomic, readonly) NWBooksCache* demoFragmentsCache;

@property (nonatomic, readonly) NWBooksCache* purchasedBooksCache;

@property (nonatomic, assign) int lastReadedBookID;

@property (nonatomic, readonly) NWBookCacheItem* lastReadedBook;

@end
