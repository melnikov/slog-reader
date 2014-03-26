//
//  NWBookContentItem.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "NWBookmarkItem.h"

static const int SectionDepthMainChapter = 0;

@interface NWBookContentItem : NWBookmarkItem
{
    int _depth;
    
    int _bookmarksCount;
    
    int _titleID;
}

+ (NWBookContentItem*)itemWithTitle:(NSString*)title fb2ItemID:(int)itemID depth:(int)depth titleID:(int)titleID;

@property (nonatomic, readonly) int depth;

@property (nonatomic, assign) int bookmarksCount;

@property (nonatomic, assign) int titleID;

@end
