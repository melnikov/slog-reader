//
//  FB2Annotation.m
//  NewspaperWorld
//

#import "FB2Annotation.h"
#import "FB2Constants.h"
#import "FB2EpigraphTextStyle.h"
#import "FB2AnnotationGenerator.h"

@implementation FB2Annotation

@synthesize text;

+ (FB2Annotation*)itemFromXMLElement:(GDataXMLElement *)element
{
    FB2Annotation* item = [[[FB2Annotation alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.generator = [[[FB2AnnotationGenerator alloc] init] autorelease];
    }
    return self;
}
- (void)dealloc
{
    [text release];
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
    if (!element || ![element.name isEqualToString:FB2ElementAnnotation])
        return NO;


    [text release];
    text = [[FB2TextItem itemFromXMLElement:element] retain];

    GDataXMLNode* idAttr = [element attributeForName:FB2ElementID];
    if (idAttr)
    {
        [_ID release];
        _ID = [[idAttr stringValue] retain];
    }
    return YES;
}

- (BOOL)containsItemWithID:(int)ID
{
    BOOL result = [super containsItemWithID:ID];
    if (result) return result;
    
    result |= [text containsItemWithID:ID];
    if (result) return result;
    
    return result;
}
@end
