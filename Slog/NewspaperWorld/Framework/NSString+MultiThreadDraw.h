//
//  NSString+MultiThreadDraw.h
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 15.04.13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (MultiThreadDraw)

- (CGSize)MTDrawInRect:(CGRect)rect withFont:(UIFont *)font;
- (CGSize)MTDrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (CGSize)MTDrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment;

- (CGSize)MTSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGSize)MTSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)MTSizeWithFont:(UIFont *)font;
- (CGSize)MTSizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (NSString*)hyphenatedStringWithLocale:(NSLocale*)locale;

@end
