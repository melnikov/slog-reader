//
//  NWBookContentItem.m
//  NewspaperWorld
//

#import "NWBookContentItem.h"

@implementation NWBookContentItem

@synthesize depth = _depth;
@synthesize bookmarksCount = _bookmarksCount;
@synthesize titleID = _titleID;

#pragma mark Memory management

- (id)initWithTitle:(NSString*)aTitle  fb2ItemID:(int)itemID  depth:(int)aDepth titleID:(int)titleID
{
    self = [super initWithTitle:aTitle fb2ItemID:itemID];
    if (self)
    {
        _depth = aDepth;
        _bookmarksCount = 0;
        _titleID = titleID;
    }
    return self;
}

- (void)dealloc
{  
    [super dealloc];
}

#pragma mark Public methods

+ (NWBookContentItem*)itemWithTitle:(NSString*)title  fb2ItemID:(int)itemID  depth:(int)depth titleID:(int)titleID
{
    return [[[NWBookContentItem alloc] initWithTitle:title fb2ItemID:itemID depth:depth titleID:titleID] autorelease];
}

@end
