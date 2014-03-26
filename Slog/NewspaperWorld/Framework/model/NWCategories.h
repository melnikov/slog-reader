//
//  NWCategories.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>

@class NWCategory;

@interface NWCategories : NSObject
{
    NSMutableArray* _categories;
}

+ (NWCategories*)categoriesFromResponseData:(NSObject*)data;

+ (NWCategories*)categoriesFromCategoriesArray:(NSArray*)categoriesArray;

- (BOOL)loadFromResponseData:(NSObject*)data;

- (BOOL)loadFromCategoriesArray:(NSArray*)categoriesArray;

- (NWCategory*)categoryAtIndex:(int)index;

- (NWCategory*)categoryWithID:(int)ID recursive:(BOOL)recursive;

@property (nonatomic, readonly) int count;

@end
