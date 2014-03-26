//
//  FB2Title.m
//  NewspaperWorld
//

#import "FB2Title.h"
#import "FB2Constants.h"
#import "FB2TitleTextStyle.h"
#import "FB2EmptyLine.h"
#import "FB2TitleGenerator.h"
#import "NWSettings.h"

@implementation FB2Title

+ (FB2Title*)itemFromXMLElement:(GDataXMLElement*)element
{    
    FB2Title* item = [[[FB2Title alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.generator = [[[FB2TitleGenerator alloc] init] autorelease];
        _baseIncreaseParam = 2.5+0.5*(([NWSettings sharedSettings].readerFontSize-[NWSettings sharedSettings].readerFontSizeDefaults)/[NWSettings sharedSettings].readerFontSizeDefaults);
        _nestingSizes = [[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:0.9],
                         [NSNumber numberWithFloat:1.3], [NSNumber numberWithFloat:1.5], nil] retain];
    }
    return self;
}

- (void)increaseNesting
{    
    if (_nesting < 5) {
        _nesting++;
        [self initTextStyle];
    }
}

- (void)setNesting:(NSUInteger)newValue
{
    if (newValue == _nesting) {
        return;
    }
    
  //  NSLog(@"cur nesting = %i", new);
    
    if (newValue < 6) {
        _nesting = newValue;
    } else {
        _nesting = 5;
    }
    
    [self initTextStyle];
}

- (NSUInteger)getNesting
{
    return _nesting;
}

- (void)initTextStyle
{
    [_textStyle release];
    _textStyle = [[FB2TitleTextStyle alloc] init];
    
    float nestingParam = (_nesting == 0) ? 0 : [[_nestingSizes objectAtIndex:_nesting-1] floatValue];
    float increaseParam = (_nesting > 0) ? _baseIncreaseParam-nestingParam : _baseIncreaseParam;
    [_textStyle applyFontSize:increaseParam*[NWSettings sharedSettings].readerFontSize];
    _textStyle.textType = TEXTTYPE_EPIGRAPH;
}

- (BOOL)loadFromXMLElement:(GDataXMLElement *)element
{
    if (!element || ![element.name isEqualToString:FB2ElementTitle])
        return NO;
    
    [super loadFromXMLElement:element];
    [_subItems addObject:[[[FB2EmptyLine alloc] init] autorelease]];
    return YES;
}

- (void)dealloc
{
    [_nestingSizes release];
    [super dealloc];
}

@end
