//
//  FB2SuperScript.m
//  NewspaperWorld
//

#import "FB2SuperScript.h"
#import "FB2Constants.h"
#import "FB2SuperScriptTextStyle.h"

@implementation FB2SuperScript

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementSuperScript])
        return NO;
    
    return [super loadFromXMLElement:element];
}

- (void)initTextStyle
{
    [_textStyle release];
    _textStyle = [[FB2SuperScriptTextStyle alloc] init];
}

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2SuperScript* item = [[[FB2SuperScript alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

@end
