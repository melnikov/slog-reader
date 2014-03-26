//
//  FBPlainText.m
//  NewspaperWorld
//

#import "FB2PlainText.h"

@implementation FB2PlainText

@synthesize plainText;

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || element.kind != GDataXMLTextKind)
        return NO;
    
    [plainText release];
    plainText = [[element stringValue] retain];
    return YES;
}

- (NSString*)plainText
{
    return plainText;
}

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2PlainText* item = [[[FB2PlainText alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

@end
