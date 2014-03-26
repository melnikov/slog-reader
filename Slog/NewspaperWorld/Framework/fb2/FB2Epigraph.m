//
//  FB2Epigraph.m
//  NewspaperWorld
//

#import "FB2Epigraph.h"
#import "FB2Constants.h"
#import "GDataXMLElement+Utils.h"
#import "FB2EpigraphTextStyle.h"
#import "FB2EpigraphGenerator.h"

@implementation FB2Epigraph

@synthesize text;
@synthesize textAuthor;

+ (FB2Epigraph*)itemFromXMLElement:(GDataXMLElement *)element
{
    FB2Epigraph* item = [[[FB2Epigraph alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.generator = [[[FB2EpigraphGenerator alloc] init] autorelease];
    }
    return self;
}
- (void)dealloc
{
    [text release];
    [textAuthor release];
    [_ID release];
    [super dealloc];
}

- (void)initTextStyle
{
    [_textStyle release];
    _textStyle = [[FB2EpigraphTextStyle alloc] init];
}

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementEpigraph])
        return NO;

    [super loadFromXMLElement:element];
    
    GDataXMLNode* idAttr = [element attributeForName:FB2ElementID];
    if (idAttr)
    {
        [_ID release];
        _ID = [[idAttr stringValue] retain];
    }
    
    GDataXMLElement* textAuthorElement = [element firstChildElementWithName:FB2ElementTextAuthor];
    if (textAuthorElement)
    {
        [textAuthor release];
        textAuthor = [[FB2TextAuthor itemFromXMLElement:textAuthorElement] retain];
    }  
    [text release];
    text = [[FB2TextItem itemFromXMLElement:element] retain];

    return YES;
}

- (BOOL)containsItemWithID:(int)ID
{
    BOOL result = [super containsItemWithID:ID];
    if (result) return result;
    
    result |= [textAuthor containsItemWithID:ID];
    if (result) return result;
    
    result |= [text containsItemWithID:ID];
    if (result) return result;
    
    return result;
}
@end
