//
//  NWSettings.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>

@interface NWSettings : NSObject
{
    
}

+ (NWSettings*)sharedSettings;

@property (nonatomic, assign)  CGFloat readerFontSize;

@property (nonatomic, retain)  UIColor* readerTextColor;

@property (nonatomic, retain)  UIColor* readerBackgroundColor;

@property (nonatomic, copy)  NSString* readerFontFamily;

@property (nonatomic, readonly)  NSString* readerBoldFontFamily;

@property (nonatomic, readonly)  NSString* readerItalicFontFamily;

@property (nonatomic, readonly) CGFloat readerFontSizeDefaults;
@property (nonatomic, readonly) UIColor* readerTextColorDefaults;
@property (nonatomic, readonly) UIColor* readerBackgroundColorDefaults;

@end
