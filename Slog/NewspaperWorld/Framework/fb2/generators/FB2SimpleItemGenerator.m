//
//  FB2SimpleItemGenerator.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 08.04.13.
//
//

#import "FB2SimpleItemGenerator.h"
#import "FB2PlainText.h"
#import "FB2Link.h"
#import "FB2PageTextItem.h"
#import "FB2PlainTextGenerator.h"
#import "FB2PageLinkItem.h"
#import "NSString+MultiThreadDraw.h"
#import "Utils.h"

@implementation FB2SimpleItemGenerator

- (void)generatePagesForItem:(FB2Item*)item withContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle
{
    if (![item isKindOfClass:[FB2TextItem class]])
        return;
    
    FB2TextItem*  text = (FB2TextItem*)item; 
    FB2TextStyle* currentItemTextStyle =  [self styleWithApplyParentStyle:parentStyle toStyle:text.textStyle]; 
    
    if ( [text.plainText rangeOfString:@" и реальных"].length > 0)
    {
        NSLog(@"");
    }
    //Если это не простой текст то генерируем разметку для subitemов
    if (![text isKindOfClass:[FB2PlainText class]])
    {
        for (FB2Item* subItem in text.subItems)
        {
            [subItem generatePagesWithContext:context parentStyle:currentItemTextStyle];
        }
        return;
    }

    CGFloat          lineHeight = currentItemTextStyle.lineHeight;
    CGFloat    refVerticalSlide = currentItemTextStyle.verticalOffset;

    // Если текущая позиция это самый низ страницы
    if (context.position->y + lineHeight > context.pageHeight)
    {
        [context nextPage];
        context.page = [FB2PageData pageData];
        [text generatePagesWithContext:context parentStyle:currentItemTextStyle];
        return;
    }

    //делим на слова
    NSArray* words = [text.plainText divideByWhitespacesAnNewlinesWithBlock:nil];

    CGFloat     firstStringLenght = 0;
    int     firstStringWordsCount = 0;
    
    //подсчитаем число слов в первой строке
    NSString * firstString = [self getFirstStringForWordsArray:words
                                                        length:&firstStringLenght
                                                 andWordsCount:&firstStringWordsCount
                                                          font:currentItemTextStyle.textFont
                                                       context:context];

    //Если у куска текста есть в начале хвостик, то добавляем в разметку его
    CGRect frame = CGRectZero;
    if (firstString.length > 0)
    {
        frame = CGRectMake(context.position->x,
                           context.position->y - refVerticalSlide,
                           (context.pageWidth - context.position->x),
                           lineHeight);
        [self addItemWithData:firstString
                        frame:frame
                    fb2ItemID:text.itemID
                        style:currentItemTextStyle
                      context:context
                  newPosition:CGPointMake(context.position->x + firstStringLenght, context.position->y)];
    }

    //Если кусок текста помещается в одну строку, то выходим
    if ((firstStringWordsCount == 0) && (firstString.length > 0))
        return;
    
    if (words.count > (firstStringWordsCount)) {
        NSString * word = [words objectAtIndex:firstStringWordsCount];

        CGFloat strWidth = [word MTSizeWithFont:currentItemTextStyle.textFont].width;
        if (context.position->x + strWidth >= context.pageWidth)
        {      
            [context nextStringWithLineHeight:lineHeight];
        }
    }

    NSMutableString* remainingStrings = [[[NSMutableString alloc] init] autorelease];

    // get remains strings
    for(int j = firstStringWordsCount; j < words.count; j++) {
        NSString * theWord = [words objectAtIndex:j];
        [remainingStrings appendString:theWord];
    }

    FB2PlainTextGenerator* gen = [[FB2PlainTextGenerator alloc] init];
    [gen generatePagesForTextBlock:remainingStrings
                         fb2ItemID:text.itemID
                         textStyle:currentItemTextStyle
                           context:context];
    [gen release];

}

- (void)addItemWithData:(id)data frame:(CGRect)frame fb2ItemID:(int)itemID style:(FB2TextStyle*)style context:(FB2PageGeneratorContext*)context newPosition:(CGPoint)newPosition
{
    FB2PageDataItem* textFB2PageItem = nil;
    
    textFB2PageItem = [FB2PageTextItem itemWithData:data
                                          frameRect:frame
                                          fb2ItemID:itemID
                                          textStyle:style];
    
    [context.page.items addItem:textFB2PageItem];
    
    [self actionAfterAddingItemWithFrame:frame context:context];
    
    context.position->x = newPosition.x;
    context.position->y = newPosition.y;
    context.page.contentHeight = context.position->y;
}

- (FB2TextStyle*)styleWithApplyParentStyle:(FB2TextStyle*)parentStyle toStyle:(FB2TextStyle*)srcStyle
{
    if (!parentStyle)
        return srcStyle;
    
    FB2TextStyle* newStyle     = [[parentStyle copy] autorelease];
    FB2TextStyle* defaultStyle = [[[FB2TextStyle alloc] init] autorelease];

    if (srcStyle.textAlignment != defaultStyle.textAlignment)
    {
        newStyle.textAlignment = srcStyle.textAlignment;
    }
    if (srcStyle.isStrikeThrough != defaultStyle.isStrikeThrough)
    {
        newStyle.isStrikeThrough = srcStyle.isStrikeThrough;
    }
    if (![srcStyle.textColor isEqual:defaultStyle.textColor])
    {
        newStyle.textColor = srcStyle.textColor;
    }
    if (![srcStyle.textFont.fontName isEqual:defaultStyle.textFont.fontName])
    {
        [newStyle applyTextFontFamily:srcStyle.textFont.fontName];
    }
    if (srcStyle.textFont.pointSize != defaultStyle.textFont.pointSize)
    {
        [newStyle applyFontSize:srcStyle.textFont.pointSize];
    }
    if (srcStyle.verticalOffset != defaultStyle.verticalOffset)
    {
        newStyle.verticalOffset = srcStyle.verticalOffset;
    }
    if (srcStyle.lineHeight != defaultStyle.lineHeight)
    {
        newStyle.lineHeight = srcStyle.lineHeight;
    }
    if (srcStyle.textType != defaultStyle.textType)
    {
        newStyle.textType = srcStyle.textType;
    }

    return newStyle;
}

- (NSString*)getFirstStringForWordsArray:(NSArray*)words length:(CGFloat*)firstStringLenght andWordsCount:(int*)wordsCount font:(UIFont*)font context:(FB2PageGeneratorContext*)context
{
    NSString*            theWord = nil;
    NSMutableString* firstString = [[[NSMutableString alloc] init] autorelease];
    
    //подсчитаем число слов в первой строке
    for(int j = 0; j < words.count; j++) {
        theWord = [words objectAtIndex:j];
        *firstStringLenght += ([theWord MTSizeWithFont:font]).width;
        
        if (context.position->x + *firstStringLenght >= (context.pageWidth)) {
            *firstStringLenght -= [theWord MTSizeWithFont:font].width;
            *wordsCount = j;
            break;
        } else {
            [firstString appendString:theWord];
        }
    }
    return firstString;
}

- (NSString*)getLastStringForTextBlock:(NSArray*)wordsInBlock completeStrings:(unsigned*)numOfCompleteString font:(UIFont*)font context:(FB2PageGeneratorContext*)context
{
    if ((!wordsInBlock)||(!numOfCompleteString)) {
        return @""; // empty string
    }


    NSMutableString* lastString = [[[NSMutableString alloc] init] autorelease];
    *numOfCompleteString = 1;
    [lastString setString:@""];
    NSMutableString* tmpStr = [[[NSMutableString alloc] init] autorelease];
    CGFloat sizeSpace = ([@" " MTSizeWithFont:font]).width;

    for(int j = 0; j < wordsInBlock.count; j++)
    {
        NSString* theWord = [wordsInBlock objectAtIndex:j];

        if (theWord.length == 0)
            continue;

        [tmpStr appendString:theWord];
        CGFloat strLen = ([tmpStr MTSizeWithFont:font]).width;

        if (strLen > (context.pageWidth))
        {
            NSString* lastChar = [theWord substringFromIndex:(theWord.length - 1)];
            if ([lastChar isEqualToString:@" "])
            {
                if (strLen <= context.pageWidth + sizeSpace - 1.0)
                {
                    [lastString appendString:theWord];
                    continue;
                }
            }
            [lastString setString:theWord];
            [tmpStr setString:theWord];
            (*numOfCompleteString)++;            
        }
        else 
            [lastString appendString:theWord];        
    }
    
    return lastString;
}

- (void)actionAfterAddingItemWithFrame:(CGRect)frame context:(FB2PageGeneratorContext*)context
{
    if (!context.linkForAdd)
        return;

    FB2PageLinkItem* linkItem = [FB2PageLinkItem itemWithLink:context.linkForAdd
                                                    frameRect:frame];
    [context.page.links addItem:linkItem];
}

@end
