//
//  FB2PageDataItem.m
//  NewspaperWorld
//

#import "FB2PageDataItem.h"
#import "NWSettings.h"

@implementation FB2PageDataItem

@synthesize frame       = _frame;
@synthesize data        = _data;
@synthesize fb2ItemID   = _fb2ItemID;

+ (FB2PageDataItem*)itemWithData:(id)data frameRect:(CGRect)frame fb2ItemID:(int)ID
{
    return [[[FB2PageDataItem alloc] initWithData:data
                                        frameRect:frame
                                        fb2ItemID:ID] autorelease];
}

- (id)initWithData:(id)aData
         frameRect:(CGRect)aFrame
         fb2ItemID:(int)ID
{
    self = [super init];
    if (self)
    {
        _frame = aFrame;
        _data = [aData retain];
        _fb2ItemID = ID;
    }
    return self;
}

- (void)dealloc
{
    [_data release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    FB2PageDataItem* newItem = [[FB2PageDataItem allocWithZone:zone] init];
    newItem->_frame = self.frame;

    [newItem->_data release];
    newItem->_data = [self.data copy];
    
    newItem->_fb2ItemID = self.fb2ItemID;

    return newItem;
}
@end
