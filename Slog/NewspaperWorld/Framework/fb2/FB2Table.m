//
//  FB2Table.m
//  NewspaperWorld
//

#import "FB2Table.h"
#import "FB2Constants.h"
#import "FB2BlockGenerator.h"

@implementation FB2Table

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2Table* item = [[[FB2Table alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.generator = [[[FB2BlockGenerator alloc] init] autorelease];
    }
    return self;
}
- (NSString*)plainText
{
    NSString* result = [super plainText];
    return [NSString stringWithFormat:@"%@\n", result];
}

- (BOOL)loadFromXMLElement:(GDataXMLElement *)element
{
    if (!element || ![element.name isEqualToString:FB2ElementTable])
        return NO;
    
    return [super loadFromXMLElement:element];
}

@end
