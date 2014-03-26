//
//  FB2BoldTextItem.m
//  NewspaperWorld
//

#import "FB2BoldTextItem.h"
#import "FB2Constants.h"
#import "FB2BoldTextStyle.h"

@implementation FB2BoldTextItem

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementStrong])
        return NO;
     
    return [super loadFromXMLElement:element];
}

- (void)initTextStyle
{
    [_textStyle release];
    _textStyle = [[FB2BoldTextStyle alloc] init];
}

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2BoldTextItem* item = [[[FB2BoldTextItem alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}
@end
