//
//  FB2Date.m
//  NewspaperWorld
//

#import "FB2Date.h"
#import "FB2Constants.h"
#import "GDataXMLElement+Utils.h"

@implementation FB2Date

@synthesize dateString;

- (void)dealloc
{
    [dateString release];
    [super dealloc];
}

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementDate])
        return NO;
    
    GDataXMLNode* dateAttribute = [element attributeForName:FB2AttributeValue];
    if (dateAttribute)
    {
        [dateString release];
        dateString = [[dateAttribute stringValue] retain];
    }
    return [super loadFromXMLElement:element];
}

+ (FB2Date*)itemFromXMLElement:(GDataXMLElement *)element
{
    FB2Date* item = [[[FB2Date alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

- (BOOL)containsItemWithID:(int)ID
{
    BOOL result = [super containsItemWithID:ID];
    if (result) return result;
    
    return result;
}
@end
