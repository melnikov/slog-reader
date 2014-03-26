//
//  NWSettings.m
//  NewspaperWorld
//

#import "NWSettings.h"

static NWSettings* _instance = nil;

@implementation NWSettings

@synthesize readerFontSize;
@synthesize readerFontSizeDefaults;
@synthesize readerTextColor;
@synthesize readerTextColorDefaults;
@synthesize readerFontFamily;
@synthesize readerBoldFontFamily;
@synthesize readerItalicFontFamily;
@synthesize readerBackgroundColor;
@synthesize readerBackgroundColorDefaults;

#pragma mark Memory management

- (id)init
{
    self = [super init];
    if (self)
    {
        readerFontSizeDefaults = 16;
        readerBackgroundColorDefaults = [UIColor whiteColor];
        readerTextColorDefaults = [UIColor blackColor];
        
        self.readerTextColor = readerTextColorDefaults;
        self.readerBackgroundColor = readerBackgroundColorDefaults;
        self.readerFontFamily = @"Helvetica";
        self.readerFontSize = readerFontSizeDefaults;
    }
    return self;
}

- (void)dealloc
{
    [readerFontFamily release];
    [readerTextColor release];
    [readerBackgroundColor release];
    [super dealloc];
}

#pragma mark Public methods

+ (NWSettings*)sharedSettings
{
    if (!_instance)
        _instance = [[NWSettings alloc] init];
    
    return _instance;
}

- (NSString*)readerBoldFontFamily
{
    return [readerFontFamily stringByAppendingString:@"-Bold"];
}


- (NSString*)readerItalicFontFamily
{
    return [readerFontFamily stringByAppendingString:@"-Oblique"];
}
@end
