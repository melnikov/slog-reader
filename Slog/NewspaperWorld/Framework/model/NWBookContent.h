//
//  NWBookContent.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "FB2File.h"
#import "NWBookContentItem.h"

@interface NWBookContent : NSObject
{
    FB2File*    _fb2File;
    
    NSMutableArray* _items;
}

- (void)loadFromFB2File:(FB2File*)file;

- (NWBookContentItem*)contentItemAtIndex:(int)index;

- (NWBookContentItem*)contentItemWithID:(int)ID;

@property (nonatomic, readonly) int count;

@property (nonatomic, readonly)  NSArray* contentTitles;

@end
