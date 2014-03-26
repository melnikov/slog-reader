//
//  FB2Subtitle.m
//  NewspaperWorld
//

#import "FB2Subtitle.h"
#import "FB2Constants.h"
#import "FB2SubtitleTextStyle.h"
#import "FB2BlockGenerator.h"

@implementation FB2Subtitle

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2Subtitle* item = [[[FB2Subtitle alloc] init] autorelease];
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

- (void)initTextStyle
{
    [_textStyle release];
    _textStyle = [[FB2SubtitleTextStyle alloc] init];
}

- (NSString*)plainText
{
    NSString* result = [super plainText];
    result = [NSString stringWithFormat:@"%@\n", result];    
    return result;
}

- (BOOL)loadFromXMLElement:(GDataXMLElement *)element
{
    if (!element || ![element.name isEqualToString:FB2ElementSubtitle])
        return NO;
    
    return  [super loadFromXMLElement:element];
}

@end
