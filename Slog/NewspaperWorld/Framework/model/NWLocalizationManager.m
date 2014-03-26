//
//  NWLocalizationManager.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 22.02.13.
//
//

#import "NWLocalizationManager.h"
#import "Utils.h"

static NWLocalizationManager * _sharedManager = nil;
static void removeInstance()
{
    [_sharedManager release];
    _sharedManager = nil;
}

@implementation NWLocalizationManager

@synthesize interfaceLanguage;

+ (NWLocalizationManager *) sharedManager
{
    if (!_sharedManager)
    {
        _sharedManager = [[NWLocalizationManager alloc] init];
        atexit(removeInstance);
    }
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        if (!([_currentLanguage isEqualToString:@"en"] || [_currentLanguage isEqualToString:@"ru"]))
        {
            _currentLanguage = @"ru";
            [_currentLanguage retain];

            NSString *path = [[NSBundle mainBundle] pathForResource:_currentLanguage ofType:@"lproj"];
            if ([Utils fileExistsAtPath:path])
            {
                _currentBundle = [[NSBundle bundleWithPath:path] retain];
            }
        }
        else
            [_currentLanguage retain];
    }
    return self;
}

- (void)dealloc
{
    [_currentBundle release];
    [_currentLanguage release];
    [super dealloc];
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment
{
    if (_currentBundle)
        return [_currentBundle localizedStringForKey:key value:comment table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:(key) value:comment table:nil];
}

- (NSString *) localizedPathForResource:(NSString *)resName ofType:(NSString *)resType
{
    NSString* path = [[NSBundle mainBundle] pathForResource:resName ofType:resType inDirectory:nil forLocalization:_currentLanguage];
    if (!path)
        path = [[NSBundle mainBundle] pathForResource:resName ofType:resType inDirectory:@"Resources" forLocalization:_currentLanguage];
    if (!path)
        path = [[NSBundle mainBundle] pathForResource:resName ofType:resType];
    if (!path)
        path = [[NSBundle mainBundle] pathForResource:resName ofType:resType inDirectory:@"Resources"];

    return path;
}

- (NSString*) interfaceLanguage
{
    return _currentLanguage;
}

@end

@implementation UIImage(Localization)

//+ (UIImage*)imageNamed:(NSString*)name
//{
//    NSString* ext = [name pathExtension];
//    if (ext.length == 0)
//        name = [name stringByAppendingString:@".png"];
//
//    NSString *path = NWLocalizedPathForResource(name,  @"");
//    return [UIImage imageWithContentsOfFile:path];
//}

@end
