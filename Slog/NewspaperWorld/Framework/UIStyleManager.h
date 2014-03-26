//
//  UIStyleManager.h
//

#import <Foundation/Foundation.h>

#define NAVBAR_BG_IMAGEVIEW_TAG 1000

@interface UIStyleManager : NSObject {
 @private
  NSMutableDictionary*contentOfStylesFile;
}

+ (UIStyleManager*)instance;

- (void)applyStyle:(NSString *)styleName toView:(UIView *)view;

@end
