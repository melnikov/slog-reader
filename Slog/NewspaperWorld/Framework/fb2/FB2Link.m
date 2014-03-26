//
//  FB2Link.m
//  NewspaperWorld
//

#import "FB2Link.h"
#import "FB2Constants.h"
#import "FB2LinkTextStyle.h"
#import "FB2LinkGenerator.h"

@interface FB2Link()

@property (copy, readonly) NSString* rawHref;

@end

@implementation FB2Link

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2Link* item = [[[FB2Link alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.generator = [[[FB2LinkGenerator alloc] init] autorelease];
    }
    return self;
}
- (void)dealloc
{
    [_rawHref release];
    [_type release];
    [super dealloc];
}


- (void)initTextStyle
{
    [_textStyle release];
    _textStyle = [[FB2LinkTextStyle alloc] init];
}

- (BOOL)loadFromXMLElement:(GDataXMLElement *)element
{
    if (!element || ![element.name isEqualToString:FB2ElementLink])
        return NO;
    
    GDataXMLNode* attribute = [element attributeForName:FB2AttributeHref];
    if (attribute)
    {
        [_rawHref release];
        _rawHref = [[attribute stringValue] copy];
    }
    attribute = [element attributeForName:FB2AttributeType];
    if (attribute)
    {
        [_type release];
        _type = [[attribute stringValue] copy];
    }
    return  [super loadFromXMLElement:element];
}


#pragma mark Property accessors

- (BOOL)isLocal
{
    if (_rawHref.length > 0)
    {
        unichar firstChar = [_rawHref characterAtIndex:0];
        if (firstChar == '#')
            return YES;
    }
    return NO;
}

- (NSString*)href
{
    if (self.isLocal && _rawHref.length > 0)
    {
        return [_rawHref substringFromIndex:1];
    }
    return _rawHref;
}

@end
