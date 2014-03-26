//
//  FB2SimpleImageGenerator.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 08.04.13.
//
//

#import "FB2ImageGenerator.h"
#import "FB2Image.h"
#import "FB2PageImageItem.h"
#import "Utils.h"
#import "FB2PageGeneratorContext.h"
#import "FB2TextStyle.h"

static CGFloat fontHeight;

@implementation FB2ImageGenerator

- (void)generatePagesForItem:(FB2Item*)item withContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle
{
    if (![item isKindOfClass:[FB2Image class]])
        return;
    
    FB2Image* imageItem = (FB2Image*)item;

    if (parentStyle == nil)
        [self generatePagesForSeparateImageItem:imageItem withContext:context];
    else
        [self generatePagesForInlineImageItem:imageItem withContext:context parentStyle:parentStyle];
}

//simple image
- (void)generatePagesForSeparateImageItem:(FB2Image*)imageItem withContext:(FB2PageGeneratorContext*)context
{   
    if (!context.page)
        context.page = [FB2PageData pageData];

    UIImage* image = [UIImage imageWithData:[context.fb2File dataForBinaryID:imageItem.binaryID]];
    
    const CGSize  originalSize = CGSizeMake(image.size.width, image.size.height);
    CGSize  imageSize = originalSize;
    CGFloat imageAspect = imageSize.width/imageSize.height;

    const CGFloat maxImageWidth = (CGFloat)context.pageWidth;
    CGFloat neededHeight = (CGFloat)context.pageWidth/imageAspect;

    const CGFloat maxImageHeight = (CGFloat)context.pageHeight;

    UIImage* originalImage = nil;
    if (imageSize.width > maxImageWidth)
    {
        originalImage = [[image retain] autorelease];

        if (maxImageWidth/imageAspect <= neededHeight)
        {
            imageSize = CGSizeMake(maxImageWidth, maxImageWidth/imageAspect);
        } else {
            imageSize = CGSizeMake(neededHeight*imageAspect, neededHeight);
        }
    }

    if (imageSize.height > maxImageHeight)
        imageSize = CGSizeMake(maxImageHeight*imageAspect, maxImageHeight);

    if (!CGSizeEqualToSize(originalSize, imageSize))
        image = [Utils image:image scaledToSize:imageSize];

    CGFloat imageX = (context.pageWidth - imageSize.width)/2;

    CGRect imageFrame;
    if (context.page.contentHeight + imageSize.height < context.pageHeight)
    {
        imageFrame = CGRectMake (imageX, context.page.contentHeight, imageSize.width, imageSize.height);       
    }
    else
    {
        imageFrame = CGRectMake (imageX, 0, imageSize.width, imageSize.height);
        [context nextPage];
        context.page = [FB2PageData pageData];
    }
    [context.page.items addItem:[FB2PageImageItem itemWithImage:image
                                                      frameRect:imageFrame
                                                      fb2ItemID:imageItem.itemID
                                                  originalImage:originalImage]];
    context.page.contentHeight += imageSize.height;
    context.position->y = context.page.contentHeight;
}

//inline


- (void)generatePagesForInlineImageItem:(FB2Image*)imageItem withContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle
{
    if (context.page == nil)
        context.page = [FB2PageData pageData];

    UIImage*    image  = [UIImage imageWithData:[context.fb2File dataForBinaryID:imageItem.binaryID]];
    UIFont*     font   = [[[FB2TextStyle alloc] init] autorelease].textFont;

    fontHeight = [font lineHeight];

    if (image == nil)
    {
        return;
    }

    CGSize  originalImgSize = CGSizeMake(image.size.width, image.size.height);
    CGSize imageSize = CGSizeMake(originalImgSize.width, originalImgSize.height);
    float scaleFactor = fontHeight/image.size.height;

    if (((scaleFactor < 0.9) || (scaleFactor > 1.0)) && (scaleFactor > 0)) {
        imageSize.height = scaleFactor*originalImgSize.height;
        imageSize.width = scaleFactor*originalImgSize.width;
        image = [Utils image:image scaledToSize:imageSize];
    }

    CGFloat newX = context.position->x + image.size.width;

    if (newX > context.pageWidth) {
        context.position->x = 0;
        context.position->y += fontHeight;
    }

    if (context.position->y > context.pageHeight)
    {
        [context.pages addObject:context.page];
        context.page = nil;
        context.position->y = 0;
        context.position->x = 0;
        context.page = [FB2PageData pageData];

        [self generatePagesForInlineImageItem:imageItem withContext:context parentStyle:parentStyle];
        return;
    }

    FB2PageDataItem* pageDataItem = [FB2PageDataItem itemWithData:image
                                                        frameRect:CGRectMake(context.position->x, context.position->y, image.size.width, image.size.height)
                                                        fb2ItemID:imageItem.itemID];

    if (pageDataItem == nil)
    {
        return;
    }

    [context.page.items addItem:pageDataItem];
    context.position->x += image.size.width;

    if (context.position->x >= (context.pageWidth))
    {
        context.position->x = 0;
        context.position->y += fontHeight;
    }
    context.page.contentHeight = context.position->y;
}
@end
