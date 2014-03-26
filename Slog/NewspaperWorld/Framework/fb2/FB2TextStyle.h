//
//  FB2TextStyle.h
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 29.03.13.
//
//

#import <Foundation/Foundation.h>

typedef enum
{
    TEXTTYPE_DEFAULT = 0,
    TEXTTYPE_EPIGRAPH
} TextType;

@interface FB2TextStyle : NSObject <NSCopying>
{
    UIFont *        _textFont;
    UIColor *       _textColor;
    NSTextAlignment _textAlignment;
    BOOL            _isDefault;
    CGFloat         _verticalOffset;
    CGFloat         _lineHeight;
}

- (id)initWithFontFamily:(NSString*)family size:(CGFloat)size color:(UIColor*)color alignment:(NSTextAlignment)alignment;

- (void)applyTextFontFamily:(NSString*)fontFamily;
- (void)changeFontSizeTo:(CGFloat)fontSizeDiff;
- (void)applyFontSize:(CGFloat)newFontSize;

@property (nonatomic, readonly) UIFont*         textFont;
@property (nonatomic, retain)   UIColor*        textColor;
@property (nonatomic, assign)   NSTextAlignment textAlignment;
@property (nonatomic, readonly) BOOL            isDefault;
@property (nonatomic, assign)   CGFloat         verticalOffset;
@property (nonatomic, assign)   CGFloat         lineHeight;
@property (nonatomic, assign)   BOOL            isStrikeThrough;
@property (nonatomic, assign)   TextType        textType;

@end
