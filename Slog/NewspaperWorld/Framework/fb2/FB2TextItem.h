//
//  FB2FormattedTextItem.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "FB2Item.h"
#import "FB2TextStyle.h"

@interface FB2TextItem : FB2Item
{
@protected
    NSMutableArray* _subItems;    
    NSString*       _plainText;
    FB2TextStyle*   _textStyle;
}

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element;
+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element startChildIndex:(int)index;

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element;

- (void)setTextStyle:(FB2TextStyle*)style;

- (void)initTextStyle;

@property (nonatomic, readonly) NSArray*  subItems;
@property (nonatomic, readonly) NSString* plainText;
@property (nonatomic, readonly) FB2TextStyle* textStyle;
@property (nonatomic, readonly) int     lastItemID;

@end
