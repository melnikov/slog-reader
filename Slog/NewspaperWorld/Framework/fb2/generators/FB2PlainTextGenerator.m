//
//  FB2PlainTextGenerator.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 08.04.13.
//
//

#import "FB2PlainTextGenerator.h"
#import "FB2PlainText.h"
#import "FB2PageTextItem.h"
#import "NSString+MultiThreadDraw.h"
#import "Utils.h"

static NSObject* _lockObject = nil;

static void release_lockObject()
{
    [_lockObject release];
    _lockObject = nil;
}

@implementation FB2PlainTextGenerator

- (void)generatePagesForTextBlock:(NSString*)textBlock
                                fb2ItemID:(int)ID
                                textStyle:(FB2TextStyle*)textStyle
                                  context:(FB2PageGeneratorContext *)context
{
    UIFont* currentReaderFont = textStyle.textFont;
    CGSize  pageSize = CGSizeMake(context.pageWidth, context.pageHeight);
    CGFloat lineHeight = currentReaderFont.lineHeight;
    
    while (textBlock.length > 0)
    {
        if (!context.page)
            context.page = [FB2PageData pageData];

        if (_lockObject == nil)
        {
            _lockObject = [[NSObject alloc] init];
            atexit(release_lockObject);
        }

        CGSize textLimitSize = CGSizeMake(2*pageSize.width, 2*pageSize.height);

        __block NSMutableString * nextPageTextBlock = [NSMutableString stringWithString:textBlock];
        __block NSMutableString * currentLineTextBlock = [NSMutableString string];
        __block BOOL              parsed = NO;
        __block CGSize            currentLineSize = CGSizeZero;
        //Перечислим слова
        [textBlock divideByWhitespacesAnNewlinesWithBlock:^(NSString *wordWithDelimiter, BOOL *stop)
        {
            parsed = YES;
            // строка с учетом нового слова
            NSString* newStr = [currentLineTextBlock stringByAppendingString:[NSString stringWithString:wordWithDelimiter]];

            //Длина этой строки
            CGSize newStrSize =  [self sizeForTextBlock:[newStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                                           withFont:currentReaderFont
                                           pageSize:textLimitSize];
            //Длина текущей строки
            currentLineSize =  [self sizeForTextBlock:currentLineTextBlock withFont:currentReaderFont pageSize:textLimitSize];
            if (context.page.contentHeight + lineHeight > context.pageHeight)
            {
                [context nextPage];
                *stop = YES;
            }
            else
            if (context.position->x + newStrSize.width >= pageSize.width)
            {
                [self addItemWithData:[NSString stringWithString:currentLineTextBlock]
                            frame:CGRectMake(context.position->x,context.position->y, currentLineSize.width, currentLineSize.height)
                        fb2ItemID:ID
                            style:textStyle
                          context:context];
            
                [self nextStringWithLineHeight:lineHeight context:context];
                
                if (!context.page)
                {
                    *stop = YES;
                }
                else
                {
                    [currentLineTextBlock setString:[NSString stringWithString:wordWithDelimiter]];
                    [nextPageTextBlock deleteCharactersInRange:NSMakeRange(0, wordWithDelimiter.length)];
                }
            }
            else
            {
                [currentLineTextBlock appendString:[NSString stringWithString:wordWithDelimiter]];
                [nextPageTextBlock deleteCharactersInRange:NSMakeRange(0, wordWithDelimiter.length)];
            }
        }
        ];
        //если не было захода в функцию
        if (!parsed)
        {
            [nextPageTextBlock setString:@""];
            [currentLineTextBlock setString:textBlock];
        }
        textBlock = [NSString stringWithString:nextPageTextBlock];
        
        if (nextPageTextBlock.length == 0)
        {
            currentLineSize =  [self sizeForTextBlock:currentLineTextBlock withFont:currentReaderFont pageSize:textLimitSize];
            [self addItemWithData:[NSString stringWithString:currentLineTextBlock]
                            frame:CGRectMake(context.position->x,context.position->y, currentLineSize.width, currentLineSize.height)
                        fb2ItemID:ID
                            style:textStyle
                          context:context];
            
            [currentLineTextBlock setString:@""];
            context.position->x += currentLineSize.width;
        }
    }//while
}

- (void)nextStringWithLineHeight:(CGFloat)lineHeight context:(FB2PageGeneratorContext*)context
{
    context.position->x = 0;
    context.position->y         += lineHeight;
    if (context.page)
        context.page.contentHeight  += lineHeight;
    
    if (context.page.contentHeight + lineHeight > context.pageHeight)
    {
        [context nextPage];
    }
}

- (void)addItemWithData:(id)data frame:(CGRect)frame fb2ItemID:(int)itemID style:(FB2TextStyle*)style context:(FB2PageGeneratorContext*)context
{
    FB2PageDataItem* textFB2PageItem = nil;
    
    textFB2PageItem = [FB2PageTextItem itemWithData:data
                                          frameRect:frame
                                          fb2ItemID:itemID
                                          textStyle:style];
    
    [context.page.items addItem:textFB2PageItem];
}

- (CGSize)sizeForTextBlock:(NSString*)textBlock withFont:(UIFont*)aFont pageSize:(CGSize)pageSize
{
    return  [textBlock MTSizeWithFont:aFont
                    constrainedToSize:pageSize
                        lineBreakMode:NSLineBreakByWordWrapping];
}
@end
