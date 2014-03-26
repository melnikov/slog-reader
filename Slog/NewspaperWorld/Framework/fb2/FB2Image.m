//
//  FB2Image.m
//  NewspaperWorld
//

#import "FB2Image.h"
#import "FB2Constants.h"
#import "GDataXMLElement+Utils.h"
#import "FB2ImageGenerator.h"

@implementation FB2Image

@synthesize href;
@synthesize binaryID;
@synthesize align;
@synthesize minHorizontalMargin;
@synthesize maxWidthRelativeToPage;
@synthesize maxHeightRelativeToPage;

#pragma mark Memory management

- (id)init
{
    self = [super init];
    if (self)
    {
        self.generator = [[[FB2ImageGenerator alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc
{
    [href release];
    [align release];
    [super dealloc];
}

#pragma mark Public methods

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementImage])
        return NO;
    
    GDataXMLNode* attrValue = [element attributeForName:FB2AttributeHref];
    if (attrValue)
    {
        [href release];
        href = [[attrValue stringValue] copy];
    }
    attrValue = [element attributeForName:FB2AttributeImageAlign];
    if (attrValue)
    {
        [align release];
        align = [[attrValue stringValue] copy];
    }
    attrValue = [element attributeForName:FB2AttributeImageMinHorizontalMargin];
    if (attrValue)
    {
        minHorizontalMargin = [[attrValue stringValue] intValue];
    }
    attrValue = [element attributeForName:FB2AttributeMaxWidthRelativeToPage];
    if (attrValue)
    {
        maxWidthRelativeToPage = [[attrValue stringValue] floatValue];
    }
    attrValue = [element attributeForName:FB2AttributeMaxHeightRelativeToPage];
    if (attrValue)
    {
        maxHeightRelativeToPage = [[attrValue stringValue] floatValue];
    }
    return (href !=  nil);
}

+ (FB2Image*)imageFromXMLElement:(GDataXMLElement*)element
{
    FB2Image* image = [[[FB2Image alloc] init] autorelease];
    if ([image loadFromXMLElement:element])
        return image;
    return nil;
}

- (BOOL)containsItemWithID:(int)ID
{
    BOOL result = [super containsItemWithID:ID];
    if (result) return result;
    
    return result;
}
#pragma mark Property accessors

- (NSString*)binaryID
{
    return [href stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
}

@end
