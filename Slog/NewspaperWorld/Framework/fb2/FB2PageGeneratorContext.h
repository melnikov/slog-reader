//
//  FB2PageGeneratorContext.h
//  NewspaperWorld
//


#import <Foundation/Foundation.h>

#import "FB2PageData.h"
#import "FB2File.h"

@class FB2Link;

@interface FB2PageGeneratorContext : NSObject
{
    CGPoint _position;
}

@property (nonatomic, readonly) CGPoint*        position;
@property (nonatomic, readonly) NSMutableArray* pages;
@property (nonatomic, assign)   int             pageWidth;
@property (nonatomic, assign)   int             pageHeight;
@property (nonatomic, retain)   FB2File*        fb2File;
@property (nonatomic, assign)   FB2PageData*    page;
@property (nonatomic, assign)   FB2Link*        linkForAdd;

- (void)clear;

- (void)nextPage;
- (void)nextStringWithLineHeight:(CGFloat)lineHeight;

@end
