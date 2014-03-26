//
//  FB2Binary.m
//  NewspaperWorld
//

#import "FB2Binary.h"
#import "FB2Constants.h"
#import "GDataXMLNode.h"
#import "NSData+Base64.h"

@implementation FB2Binary

@synthesize ID;

@synthesize decodedData;

@synthesize type;

- (id)init
{
    self = [super init];
    if (self) {
        ID = nil;
        decodedData = nil;
        type = FB2BinaryTypeUndefined;
    }
    return self;
}

- (void)dealloc
{
    [ID release];
    [decodedData release];
    [type release];
    
    [super dealloc];
}

- (void)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementBinary])
        return;
    
    GDataXMLNode* typeAttr = [element attributeForName:FB2AttributeContentType];
    if (typeAttr)
    {
        [type release];
        type = [[typeAttr stringValue] copy];
    }
    GDataXMLNode* idAttr = [element attributeForName:FB2AttributeID];
    if (idAttr)
    {
        [ID release];
        ID = [[idAttr stringValue] copy];
    }
    NSString* stringBinary = [element stringValue];
    if (stringBinary)
    {
        [decodedData release];
        decodedData = [[NSData dataFromBase64String:stringBinary] retain];
    }
}

@end
