//
//  FB2Style.m
//  NewspaperWorld
//

#import "FB2Style.h"
#import "FB2Constants.h"

@implementation FB2Style

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementStyle])
        return NO;
    
    return [super loadFromXMLElement:element];
}

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2Style* item = [[[FB2Style alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

@end
