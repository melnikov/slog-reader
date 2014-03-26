//
//  NWLocalizationManager.h
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 22.02.13.
//
//

#import <Foundation/Foundation.h>


@interface NWLocalizationManager : NSObject
{
@private
    NSString*   _currentLanguage;
    NSBundle *  _currentBundle;
}

+ (NWLocalizationManager *) sharedManager;

- (NSString *) localizedStringForKey:(NSString *)key value:(NSString *)comment;

- (NSString *) localizedPathForResource:(NSString *)resName ofType:(NSString *)resType;

@property (nonatomic, readonly) NSString* interfaceLanguage;

@end

//#define NSLocalizedString(key, comment) [[NWLocalizationManager sharedManager] localizedStringForKey:key value:comment]
#define NWLocalizedPathForResource(name, type) [[NWLocalizationManager sharedManager] localizedPathForResource:name ofType:type]
#define NWInterfaceLanguage       [NWLocalizationManager sharedManager].interfaceLanguage

@interface UIImage(NWLocalization)

//+ (UIImage*)imageNamed:(NSString*)name;

@end