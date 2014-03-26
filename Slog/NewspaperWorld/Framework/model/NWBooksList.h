//
//  NWBooksList.h
//  NewspaperWorld
//


#import <UIKit/UIKit.h>


@class NWBookCard;

@interface NWBooksList : NSObject
{
    NSMutableArray* _books;
}

+ (NWBooksList*)booksFromResponseData:(NSObject*)data;

- (BOOL)loadFromResponseData:(NSObject*)data;

- (NWBookCard*)bookAtIndex:(int)index;

- (NWBookCard*)bookWithID:(int)ID;

@property (nonatomic, readonly) int count;

@end