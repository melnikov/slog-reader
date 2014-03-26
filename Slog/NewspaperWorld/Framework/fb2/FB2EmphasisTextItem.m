//
//  FBEmphasisTextItem.m
//  NewspaperWorld
//

#import "FB2EmphasisTextItem.h"
#import "FB2Constants.h"
#import "FB2EmphasisTextStyle.h"

@implementation FB2EmphasisTextItem


- (BOOL)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementEmphasis])
        return NO;    
    return [super loadFromXMLElement:element];
}

- (void)initTextStyle
{
    [_textStyle release];
    _textStyle = [[FB2EmphasisTextStyle alloc] init];
}

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2EmphasisTextItem* item = [[[FB2EmphasisTextItem alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return  nil;
}
@end
