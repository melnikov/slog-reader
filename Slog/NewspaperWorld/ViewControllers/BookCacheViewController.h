//
//  BookCacheViewController.h
//  NewspaperWorld
//


#import <UIKit/UIKit.h>
#import "BooksListViewController.h"
#import "NWBooksCache.h"

@interface BookCacheViewController : BooksListViewController
{
    NWBooksCache*            _cache;
    NWBooksCache*            _sortedCache;
}

- (void)initializeWithCache:(NWBooksCache*)cache;

@end
