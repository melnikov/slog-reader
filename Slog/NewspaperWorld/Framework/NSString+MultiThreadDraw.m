//
//  NSString+MultiThreadDraw.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 15.04.13.
//
//

#import "NSString+MultiThreadDraw.h"

static NSObject* _lockObject = nil;

static void release_lockObject()
{
    [_lockObject release];
    _lockObject = nil;
}

static NSObject* get_lockObject()
{
    if (!_lockObject)
    {
        _lockObject = [[NSObject alloc] init];
        atexit(release_lockObject);
    }
    return _lockObject;
}

@implementation NSString (MultiThreadDraw)

- (CGSize)MTDrawInRect:(CGRect)rect withFont:(UIFont *)font
{
    CGSize sz;
    @synchronized(get_lockObject())
    {
        sz = [self drawInRect:rect withFont:font];
    }
    return sz;
}

- (CGSize)MTDrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize sz;
    @synchronized(get_lockObject())
    {
        sz = [self drawInRect:rect withFont:font lineBreakMode:lineBreakMode];
    }
    return sz;
}

- (CGSize)MTDrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment
{
    CGSize sz;
    @synchronized(get_lockObject())
    {
        sz = [self drawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:alignment];
    }
    return sz;
}

- (CGSize)MTSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGSize sz;
    @synchronized(get_lockObject())
    {
        sz = [self sizeWithFont:font constrainedToSize:size];
    }
    return sz;
}

- (CGSize)MTSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize sz;
    @synchronized(get_lockObject())
    {
        sz = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
    }
    return sz;
}

- (CGSize)MTSizeWithFont:(UIFont *)font
{
    CGSize sz;
    @synchronized(get_lockObject())
    {
        sz = [self sizeWithFont:font];
    }
    return sz;
}

- (CGSize)MTSizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize sz;
    @synchronized(get_lockObject())
    {
        sz = [self sizeWithFont:font forWidth:width lineBreakMode:lineBreakMode];
    }
    return sz;
}

@end
