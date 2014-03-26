//
//  FB2PageTextItem.h
//  NewspaperWorld
//

#import "FB2PageDataItem.h"
#import "FB2TextStyle.h"

@interface FB2PageTextItem : FB2PageDataItem
{
    FB2TextStyle* _textStyle;
}

@property (nonatomic, readonly) FB2TextStyle* textStyle;

+ (FB2PageDataItem*)itemWithData:(id)data
                       frameRect:(CGRect)frame
                       fb2ItemID:(int)ID
                       textStyle:(FB2TextStyle*)textStyle;

@end
