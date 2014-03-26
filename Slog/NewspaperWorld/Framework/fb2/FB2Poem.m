//
//  FB2Poem.m
//  NewspaperWorld
//

#import "FB2Poem.h"
#import "FB2Constants.h"
#import "GDataXMLElement+Utils.h"
#import "FB2EpigraphTextStyle.h"
#import "FB2PoemGenerator.h"

@implementation FB2Poem

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2Poem* item = [[[FB2Poem alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}
- (id)init
{
    self = [super init];
    if (self) {
        self.generator = [[[FB2PoemGenerator alloc] init] autorelease];
    }
    return self;
}
- (void)dealloc
{
    [_textAuthor release];
    [_date release];
    
    [super dealloc];
}

- (void)initTextStyle
{
    [_textStyle release];
    _textStyle = [[FB2EpigraphTextStyle alloc] init];
}

- (BOOL)loadFromXMLElement:(GDataXMLElement *)element
{
    if (!element || ![element.name isEqualToString:FB2ElementPoem])
        return NO;
    
    GDataXMLElement* textAuthorElement = [element firstChildElementWithName:FB2ElementTextAuthor];
    if (textAuthorElement)
    {
        [_textAuthor release];
        _textAuthor = [[FB2TextAuthor itemFromXMLElement:textAuthorElement] retain];
    }
    GDataXMLElement* dateElement = [element firstChildElementWithName:FB2ElementDate];
    if (dateElement)
    {
        [_date release];
        _date = [[FB2Date itemFromXMLElement:dateElement] retain];
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
    result |= [_date containsItemWithID:ID];
    if (result) return result;

    return result;
}
@end
