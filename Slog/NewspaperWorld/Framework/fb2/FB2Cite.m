//
//  FB2Cite.m
//  NewspaperWorld
//

#import "FB2Cite.h"
#import "FB2Constants.h"
#import "GDataXMLElement+Utils.h"
#import "FB2EpigraphTextStyle.h"

@implementation FB2Cite


+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2Cite* item = [[[FB2Cite alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

- (void)dealloc
{
    [_textAuthor release];
    [super dealloc];
}

- (void)initTextStyle
{
    [_textStyle release];
    _textStyle = [[FB2EpigraphTextStyle alloc] init];
}

- (BOOL)loadFromXMLElement:(GDataXMLElement *)element
{
    if (!element || ![element.name isEqualToString:FB2ElementCite])
        return NO;
    
    GDataXMLElement* textAuthorElement = [element firstChildElementWithName:FB2ElementTextAuthor];
    if (textAuthorElement)
    {
        [_textAuthor release];
        _textAuthor = [[FB2TextItem itemFromXMLElement:textAuthorElement] retain];
    }
    GDataXMLNode* idAttr = [element attributeForName:FB2ElementID];
    if (idAttr)
    {
        [_ID release];
        _ID = [[idAttr stringValue] retain];
    }
    return [super loadFromXMLElement:element];
}

- (BOOL)containsItemWithID:(int)ID
{
    BOOL result = [super containsItemWithID:ID];
    if (result) return result;
    result |= [_textAuthor containsItemWithID:ID];
    if (result) return result;

    return result;
}
@end
