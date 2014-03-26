//
//  FB2EmptyLine.m
//  NewspaperWorld
//

#import "FB2EmptyLine.h"
#import "FB2Constants.h"
#import "FB2EmptyLineGenerator.h"

@implementation FB2EmptyLine

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2EmptyLine* item = [[[FB2EmptyLine alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.generator = [[[FB2EmptyLineGenerator alloc] init] autorelease];
    }
    return self;
}
- (NSString*)plainText
{
    return @"\n";
}
- (BOOL)loadFromXMLElement:(GDataXMLElement *)element
{
    if (!element || ![element.name isEqualToString:FB2ElementEmptyLine])
        return NO;

    return YES;
}

@end
