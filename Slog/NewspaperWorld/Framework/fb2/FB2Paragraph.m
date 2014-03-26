//
//  FB2Paragraph.m
//  NewspaperWorld
//


#import "FB2Paragraph.h"
#import "FB2Constants.h"
#import "FB2ParagraphGenerator.h"

@implementation FB2Paragraph

#pragma mark Public methods

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2Paragraph* item = [[[FB2Paragraph alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.generator = [[[FB2ParagraphGenerator alloc] init] autorelease];
    }
    return self;
}
- (NSString*)plainText
{
    NSString* result = [super plainText];
    result = [NSString stringWithFormat:@"%@%@\n",FB2FormattingTAB, result];
    return result;
}

- (BOOL)loadFromXMLElement:(GDataXMLElement *)element
{
    if (!element || ![element.name isEqualToString:FB2ElementParagraph])
        return NO;

    GDataXMLNode* idAttr = [element attributeForName:FB2ElementID];
    if (idAttr)
    {
        [_ID release];
        _ID = [[idAttr stringValue] retain];
    }
    
    return [super loadFromXMLElement:element];
}

@end
