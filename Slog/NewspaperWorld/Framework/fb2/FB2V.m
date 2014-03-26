//
//  FB2V.m
//  NewspaperWorld
//

#import "FB2V.h"
#import "FB2Constants.h"
#import "FB2BlockGenerator.h"

@implementation FB2V

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementV])
        return NO;
    
    return [super loadFromXMLElement:element];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.generator = [[[FB2BlockGenerator alloc] init] autorelease];
    }
    return self;
}

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2V* item = [[[FB2V alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

- (NSString*)plainText
{
    NSString* result = [super plainText];
    result = [NSString stringWithFormat:@"%@\n", result];
    return result;
}

@end
