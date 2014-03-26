//
//  NWCategory.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>

enum NWSpecialCategories {
    NWSpecialCategoryUndefined = -1,
};

@class NWCategories;

@interface NWCategory : NSObject
{
    int         _ID;
    
    NSString*   _title;
    
    NWCategories* _subcategories;
    
    BOOL          _isSpecial;
}

+ (NWCategory*)categoryFromResponseData:(NSObject*)data;

- (BOOL)loadFromResponseData:(NSObject*)data;

@property (nonatomic, readonly) int ID;

@property (nonatomic, readonly) NSString* title;

@property (nonatomic, readonly) NWCategories* subcategories;

@property (nonatomic, readonly) BOOL isSpecial;

@end
