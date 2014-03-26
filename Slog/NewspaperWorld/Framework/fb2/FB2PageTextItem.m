//
//  FB2PageTextItem.m
//  NewspaperWorld
//


#import "FB2PageTextItem.h"
#import "NWSettings.h"

@implementation FB2PageTextItem

@synthesize textStyle    = _textStyle;

+ (FB2PageDataItem*)itemWithData:(id)data
                       frameRect:(CGRect)frame
                       fb2ItemID:(int)ID
                       textStyle:(FB2TextStyle*)textStyle
{
    return [[[FB2PageTextItem alloc] initWithData:data
                                       frameRect:frame
                                       fb2ItemID:ID
                                       textStyle:textStyle] autorelease];
}

- (id)initWithData:(id)aData
         frameRect:(CGRect)aFrame
         fb2ItemID:(int)ID
         textStyle:(FB2TextStyle*)textStyle
{
    self = [super initWithData:aData frameRect:aFrame fb2ItemID:ID];
    if (self)
    {
        _textStyle = [textStyle retain];
    }
    return self;
}


- (void)dealloc
{
    [_textStyle release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    FB2PageTextItem* newItem = [[FB2PageTextItem allocWithZone:zone] init];
    newItem->_frame = self.frame;

    [newItem->_data release];
    newItem->_data = [self.data copy];

    newItem->_fb2ItemID = self.fb2ItemID;

    [newItem->_textStyle release];
    newItem->_textStyle = [self.textStyle copy];
    
    return newItem;
}
@end
