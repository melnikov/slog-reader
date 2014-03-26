//
//  FB2TextAuthor.m
//  NewspaperWorld
//

#import "FB2TextAuthor.h"
#import "FB2Constants.h"
#import "FB2AuthorTextStyle.h"

@implementation FB2TextAuthor

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementTextAuthor])
        return NO;

    return [super loadFromXMLElement:element];
}

- (void)initTextStyle
{
    [_textStyle release];
    _textStyle = [[FB2AuthorTextStyle alloc] init];
}

+ (FB2TextAuthor*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2TextAuthor* item = [[[FB2TextAuthor alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

@end
