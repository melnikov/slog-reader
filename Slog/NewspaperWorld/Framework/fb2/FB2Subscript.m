//
//  FB2Subscript.m
//  NewspaperWorld
//

#import "FB2Subscript.h"
#import "FB2Constants.h"
#import "FB2SubscriptTextStyle.h"

@implementation FB2Subscript

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementSubscript])
        return NO;
    
    return [super loadFromXMLElement:element];
}

- (void)initTextStyle
{
    [_textStyle release];
    _textStyle = [[FB2SubscriptTextStyle alloc] init];
}

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2Subscript* item = [[[FB2Subscript alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

@end
