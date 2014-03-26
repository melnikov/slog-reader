//
//  FB2StrikeThrough.m
//  NewspaperWorld
//


#import "FB2StrikeThrough.h"
#import "FB2Constants.h"
#import "FB2StrikeThroughtTextStyle.h"

@implementation FB2StrikeThrough

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementStrikeThrough])
        return NO;
    
    return [super loadFromXMLElement:element];
}

- (void)initTextStyle
{
    [_textStyle release];
    _textStyle = [[FB2StrikeThroughtTextStyle alloc] init];
    _textStyle.isStrikeThrough = YES;
}

+ (FB2StrikeThrough*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2StrikeThrough* item = [[[FB2StrikeThrough alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

@end
