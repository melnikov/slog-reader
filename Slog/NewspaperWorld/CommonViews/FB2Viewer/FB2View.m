//
//  FB2View.m
//  NewspaperWorld
//

#import "FB2View.h"
#import "FB2Body.h"
#import "FB2Section.h"
#import "FB2PageData.h"
#import "NWSettings.h"
#import "Utils.h"
#import "FB2PageDataItem.h"
#import "FB2PageTextItem.h"
#import "FB2PageImageItem.h"
#import "FB2LinkTextStyle.h"
#import "FB2StrikeThroughtTextStyle.h"
#import "NSString+MultiThreadDraw.h"
#import "FB2Constants.h"
#import "FB2PageLinkItem.h"

static const BOOL draw_spc = NO; // if YES should draw whitespaces

@interface FB2View()
{
    FB2TextStyle* _linkStyle;
    NSMutableArray* _oneLineItems;
}
- (void)showCurrentPosition;
- (void)updatePageSize;
- (void)initializeDefaults;
- (CGFloat)getSpaceMultiplierForLineOfItems:(NSArray*)items;
- (CGFloat)drawTextBlockWithNewSpaceWidth:(CGFloat)spaceWidth textblock:(FB2PageTextItem*)item;

@end

@implementation FB2View

@synthesize visiblePagesCount;
@synthesize currentPage;
@synthesize pageMargin;

#pragma mark Memory management

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [self initializeDefaults];
    self = [super initWithCoder:aDecoder];
    if (self)
    {
      
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    [self initializeDefaults];
    self = [super initWithFrame:frame];
    if (self)
    {
       
    }
    return self;
}

- (void)dealloc
{
    [_pageGenerator release];
    [_oneLineItems release];
    [_linkStyle release];
    [super dealloc];
}

#pragma mark UIView life cycle

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self updatePageSize];
    [self showCurrentPosition];
}

- (void)layoutSubviews
{    
    [super layoutSubviews];
    [self updatePageSize];
    [self showCurrentPosition];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (_pageGenerator.pagesCount == 0 ||
        currentPage > _pageGenerator.pagesCount - 1 ||
        currentPage < 0)
        return;

    if (_oneLineItems)
        [_oneLineItems removeAllObjects];
    
    FB2PageData* page = [_pageGenerator pageAtIndex:currentPage];
    NSMutableArray* arrayOfItemsOnOnceLine = [[NSMutableArray alloc] init];
 
    CGFloat lastX = 0;
    NSUInteger count = 0;
    BOOL isLastLineInParagraph = NO;
    BOOL isNextLine = NO;
    NSUInteger nextLineIdx = 0;
    
    for (int i = 0; i < page.items.count; i++)
    {
        FB2PageDataItem * item = [page.items itemAtIndex:i];
        
        isLastLineInParagraph = [self isLastLineInParagraph:page.items index:i]; // in this case we should not to align
        isNextLine = [self nextItemOnNewLine:page.items index:i];
        
        if (isNextLine)
        {
            nextLineIdx = i + 1;
        }
        
        if ([item isKindOfClass:[FB2PageTextItem class]])
        {
            FB2PageTextItem* txtItem = (FB2PageTextItem*)item;
            CGSize txtItemSize = ([(NSString*)txtItem.data MTSizeWithFont:txtItem.textStyle.textFont]);
            
           
            //Заголовки, эпиграфы итд надо рисовать без выравнивания по ширине
            if ((txtItem.textStyle.textAlignment == UITextAlignmentCenter) ||
                (txtItem.textStyle.textType != TEXTTYPE_DEFAULT))
            {
                // this item is title/header/etc
                [self drawItemsOnLine:arrayOfItemsOnOnceLine];
                [arrayOfItemsOnOnceLine removeAllObjects];
                [self drawTextItem:item];
                lastX = 0;
                continue;
            }
            
            
            // add in current line
            if (((lastX + txtItemSize.width) > (_pageWidth)))
            {
                [self drawItemsOnLine:arrayOfItemsOnOnceLine];
                [arrayOfItemsOnOnceLine removeAllObjects];
                [arrayOfItemsOnOnceLine addObject:item];
                lastX = ([(NSString*)txtItem.data MTSizeWithFont:txtItem.textStyle.textFont]).width;
            }
            else
            {
                // NSLog(@"txt = %@", (NSString*)txtItem.data);
                if (nextLineIdx && (nextLineIdx == i) && !isLastLineInParagraph)
                {
                    [self drawItemsOnLine:arrayOfItemsOnOnceLine];
                    [arrayOfItemsOnOnceLine removeAllObjects];
                    [arrayOfItemsOnOnceLine addObject:item];
                    lastX = [self getItemWidth:item];
                    count++;
                    continue;
                }
                [arrayOfItemsOnOnceLine addObject:item];
                lastX += txtItemSize.width;
            }
            
            // last line on page
            if (i == page.items.count-1)
            {
                if (!isLastLineInParagraph)
                {
                    [self drawItemsOnLine:arrayOfItemsOnOnceLine];
                    [arrayOfItemsOnOnceLine removeAllObjects];
                    lastX = 0;
                }
            }
                    
            if (isLastLineInParagraph)
            {
                [self drawLastItems:arrayOfItemsOnOnceLine];
                [arrayOfItemsOnOnceLine removeAllObjects];
                lastX = 0;
            }
        }
        else
        {
            CGFloat stdLineHeight = [self getStdFontHeigth];

            if (item.frame.size.height > 1.5 * stdLineHeight)
            {
                // not inline image
                [self drawItemsOnLine:arrayOfItemsOnOnceLine];
                [arrayOfItemsOnOnceLine removeAllObjects];
                [self drawImageItem:item];
                lastX = 0;
            }
            else
            {
                // NSLog(@"txt = %@", (NSString*)txtItem.data);
                if ((lastX + item.frame.size.width) > (_pageWidth - 1))
                {
                    [self drawItemsOnLine:arrayOfItemsOnOnceLine];
                    [arrayOfItemsOnOnceLine removeAllObjects];
                    [arrayOfItemsOnOnceLine addObject:item];
                    lastX = item.frame.size.width + item.frame.origin.x;
                }
                else
                {
                    [arrayOfItemsOnOnceLine addObject:item];
                    lastX = item.frame.origin.x + item.frame.size.width;
                }
            }
        }
    }
    
    if (_oneLineItems.count > 0)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self drawOneLineContext:context];
    }
    
    [arrayOfItemsOnOnceLine release];
}

- (void)drawLastItems:(NSArray*)items
{
    for(FB2PageTextItem* itemLastString in items) {
        [self drawTextItem:itemLastString];
        [self drawImageItem:itemLastString];
    }
}

- (BOOL)nextItemOnNewLine:(FB2PageDataItems*)items index:(NSUInteger)idx
{
    FB2PageDataItem* nextItem = nil;
    FB2PageDataItem* item = [items itemAtIndex:idx];
    BOOL result = NO;
    CGFloat lineHeight = 0;
    
    if ([item.data isKindOfClass:[NSString class]])
    {
        lineHeight = ((FB2PageTextItem*)item).textStyle.textFont.lineHeight;
    }
    else
    {
        lineHeight = ((FB2PageImageItem*)item).frame.size.height;
    }
    if (idx < items.count-1)
    {
        nextItem = [items itemAtIndex:idx + 1];        
        if (nextItem.frame.origin.y >= (item.frame.origin.y  +lineHeight))
        {
            result = YES;
        }
    }
    else
    {
        result = YES;
    }
    
    return result;
}

- (CGFloat)getItemWidth:(FB2PageDataItem*)item
{
    CGFloat result = 0;
    
    if ([item isKindOfClass:[FB2PageTextItem class]]) {
        FB2PageTextItem* txtItem = (FB2PageTextItem*)item;
        
        if (txtItem.textStyle.textAlignment != UITextAlignmentCenter) {
            result = ([(NSString*)txtItem.data MTSizeWithFont:txtItem.textStyle.textFont]).width;
        } else {
            result = item.frame.size.width;
        }
    } else {
        result = item.frame.size.width;
    }
    
    return result;
}

- (CGFloat)getStdFontHeigth
{
    static CGFloat stdLineHeight = 0;
    if (stdLineHeight == 0)
    {
        FB2TextStyle* txtStyle = [[FB2TextStyle alloc] initWithFontFamily:[NWSettings sharedSettings].readerFontFamily
                                                                 size:[NWSettings sharedSettings].readerFontSize
                                                                color:[UIColor redColor]
                                                            alignment:NSTextAlignmentLeft];
    
        stdLineHeight = ([@" " MTSizeWithFont:txtStyle.textFont]).height;
        [txtStyle release];
    }
    return stdLineHeight;
}

- (BOOL)isLastLineInParagraph:(FB2PageDataItems*)items index:(NSUInteger)idx
{
    FB2PageDataItem* nextItem = nil;
    BOOL isLastLineInParagraph = NO;
    
    if (idx < items.count-1) {
        nextItem = [items itemAtIndex:idx+1];
        CGFloat newParagraphStep = 0;
        
        if ([nextItem isKindOfClass:[FB2PageTextItem class]])
        {
            FB2PageTextItem * nextTextItem = (FB2PageTextItem*)nextItem;
            if (nextTextItem.textStyle.textAlignment == UITextAlignmentCenter)
            {
                 isLastLineInParagraph = YES;
            }
            newParagraphStep = [FB2FormattingTAB MTSizeWithFont:nextTextItem.textStyle.textFont].width;
        }
        else // для картинок
        {
            CGFloat stdLineHeight = [self getStdFontHeigth];
            
            if (nextItem.frame.size.height > 1.5*stdLineHeight)//не инлайн
            {
                isLastLineInParagraph = YES;
            }
        }
        if ((nextItem.frame.origin.x > newParagraphStep - 0.5) && (nextItem.frame.origin.x < 1.2*newParagraphStep))
        {
            isLastLineInParagraph = YES;
        }

    } else {
        // last line on page
        FB2PageDataItem* curItem = [items itemAtIndex:idx];
        
        if (curItem.frame.origin.y <= _pageHeight-curItem.frame.size.height) {
            isLastLineInParagraph = YES;
        }
    }
    
    return isLastLineInParagraph;
}

- (void)drawItemsOnLine:(NSArray*)items
{
    if ((items == nil) || (items.count == 0)) {
        return;
    }
    
    CGFloat multuiplierSpace = [self getSpaceMultiplierForLineOfItems:items];
    FB2PageDataItem* firstItem = [items objectAtIndex:0];
    CGFloat x = firstItem.frame.origin.x;
    
    FB2PageDataItem * copy = nil;
    for(FB2PageDataItem* item in items)
    {
        copy = [item copy];
        copy.frame = CGRectMake(x, item.frame.origin.y, item.frame.size.width, item.frame.size.height);
        
        if (![copy isKindOfClass:[FB2PageTextItem class]])
        {
            [self drawImageItem:copy];
            x += copy.frame.size.width;
        } else {
            x = [self drawTextBlockWithNewSpaceWidth:multuiplierSpace textblock:(FB2PageTextItem*)copy];
        }
        [copy release];
    }
}

- (CGFloat)drawTextBlockWithNewSpaceWidth:(CGFloat)spaceWidth textblock:(FB2PageTextItem*)textItem
{
    NSString* txt = (NSString*)textItem.data;
    NSArray* words = [txt divideByWhitespacesAnNewlinesWithBlock:nil];
    CGFloat x = textItem.frame.origin.x;
    CGFloat wordLength = 0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor* textColor = ([textItem.textStyle.textColor isEqual:_linkStyle.textColor]) ? textItem.textStyle.textColor : [NWSettings sharedSettings].readerTextColor;
    CGContextSetFillColorWithColor(context, textColor.CGColor);
    CGContextSetStrokeColorWithColor(context, textColor.CGColor);
    NSUInteger count = 0;
    BOOL isWhitespaceEnd = NO;
    NSString* wordWithoutSpace = nil;
        
    for(NSString* word in words) {
        wordLength = ([word MTSizeWithFont:textItem.textStyle.textFont]).width;
        
        if (wordLength < 1) {
            continue;
        }
        
        isWhitespaceEnd = [self stringIsEndsWhithWhitebox:word];
        
        if (isWhitespaceEnd && ([word isEqualToString:@" "])) {
            x += spaceWidth;
            
            if (draw_spc) {
                [self drawSpace:CGRectMake(x+spaceWidth, textItem.frame.origin.y, spaceWidth, textItem.frame.size.height) size:spaceWidth];
            }
            
            continue;
        }
        
        wordWithoutSpace = [word stringByReplacingOccurrencesOfString:@" " withString:@""];
        wordLength = ([wordWithoutSpace MTSizeWithFont:textItem.textStyle.textFont]).width;
        CGRect rect = CGRectMake(x, textItem.frame.origin.y, wordLength, textItem.frame.size.height);
        
        if (textItem.textStyle.isStrikeThrough) {
            [self drawStrikeThoughText:wordWithoutSpace frame:rect style:textItem.textStyle];
            
        } else {
            [wordWithoutSpace MTDrawInRect:rect withFont:textItem.textStyle.textFont lineBreakMode:NSLineBreakByWordWrapping alignment:textItem.textStyle.textAlignment];
        }
        
        if (draw_spc && isWhitespaceEnd)
        {
            [self drawSpace:CGRectMake(x+wordLength, textItem.frame.origin.y, spaceWidth, textItem.frame.size.height) size:spaceWidth];
        }
        
        if (isWhitespaceEnd)
        {
            x += (spaceWidth + wordLength);
        }
        else
        {
            x += wordLength;
        }
        
        count++;
    }
    
    return x;
}


// debug function for highliting whitespaces
- (void)drawSpace:(CGRect)rect size:(CGFloat)spcwidth
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 4);
    
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    CGContextMoveToPoint(context, x, y+2*rect.size.height/3);
    CGContextAddLineToPoint(context, x + rect.size.width, y+2*rect.size.height/3);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (BOOL)stringIsEndsWhithWhitebox:(NSString*)str
{
    BOOL result = NO;
    
    if ((str.length > 0) && ([[str substringFromIndex:str.length-1] isEqualToString:@" "])) {
        result = YES;
    }
    
    return result;
}

- (CGFloat)getSpaceMultiplierForLineOfItems:(NSArray*)items
{
    if ((items == nil) || (items.count == 0)) {
        return 0.0;
    }
    
    CGFloat spaceCountInLine = 0;
    FB2PageDataItem* firstItem = [items objectAtIndex:0];
    CGFloat lengthLineItems = firstItem.frame.origin.x;
    NSString* text = nil;
    NSArray* wordsInItem = nil;
    NSUInteger count = 0;
    
    for(FB2PageDataItem* item in items) {
        if ([item isKindOfClass:[FB2PageTextItem class]])
        {
            FB2PageTextItem* textItem = (FB2PageTextItem*)item;
            text = (NSString*)textItem.data;
            
            //removing last space on string
            if ([[text substringFromIndex:text.length-1] isEqualToString:@" "] && (count == items.count-1)) {
                NSRange rnage;
                rnage.location = 0;
                rnage.length = text.length-1;
                text = [text substringWithRange:rnage];
            }
            
            wordsInItem = [text componentsSeparatedByString:@" "]; //  num of scpaces in text
            spaceCountInLine += (wordsInItem.count-1);
         //   text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
            lengthLineItems += [self getLengthOfStringByWord:wordsInItem withFont:textItem.textStyle.textFont];
        }
        else
        {
            lengthLineItems += item.frame.size.width;
        }
        
        count++;
    }
    
    CGFloat output = 0;
    
    if (lengthLineItems && spaceCountInLine) {
        output = (self.pageSize.width-lengthLineItems)/spaceCountInLine;
    }
    
    return output;
}

- (CGFloat)getLengthOfStringByWord:(NSArray*)words withFont:(UIFont*)font
{
    CGFloat result = 0;
    
    for(NSString* word in words) {
        result += ([word MTSizeWithFont:font]).width;
    }
    
    return result;
}

- (void)drawTextItem:(FB2PageDataItem*)item
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ([item isKindOfClass:[FB2PageTextItem class]])
    {
        FB2PageTextItem* textItem = (FB2PageTextItem*)item;
        if (textItem.textStyle.isStrikeThrough)
        {
            [self drawStrikeThoughTextItem:textItem context:context];
        }
        else        
        {
            [self drawAlignedTextItem:textItem context:context];
        }
    }
    else
    {
        if (_oneLineItems.count > 0)
            [self drawOneLineContext:context];
    }
}

- (void)drawAlignedTextItem:(FB2PageTextItem*)textItem context:(CGContextRef)context
{
    if (!_oneLineItems)
        _oneLineItems = [[NSMutableArray alloc] init];

    if (textItem.textStyle.textAlignment != UITextAlignmentCenter)
    {
        [self centeringLine];
        [self drawOneLineContext:context];
        [self drawTextItem:textItem context:context];
        return;
    }

    FB2PageTextItem* lastItemInArray = (FB2PageTextItem*)[_oneLineItems lastObject];
    
    if (lastItemInArray == nil ||
        lastItemInArray.frame.origin.y == textItem.frame.origin.y)
    {
        [_oneLineItems addObject:[[textItem copy] autorelease]];
    }
    else
    {
        [self centeringLine];
        [self drawOneLineContext:context];
        [_oneLineItems addObject:[[textItem copy] autorelease]];
    }
}

- (void)centeringLine
{
    int lineLen = 0;
    int firstXpos = -1;
    for (FB2PageTextItem* subItem in _oneLineItems)
    {
        if (firstXpos == -1)
        {
            firstXpos = subItem.frame.origin.x;
        }
        NSString* textBlock = (NSString*)subItem.data;
        lineLen += [textBlock MTSizeWithFont:subItem.textStyle.textFont].width;
    }
    int newXpos = (_pageWidth - lineLen)/2;
    int offset = newXpos - firstXpos;    
    for (FB2PageTextItem* subItem in _oneLineItems)
    {
        if (offset > 0)
        {
            subItem.textStyle.textAlignment = UITextAlignmentLeft;
            subItem.frame = CGRectOffset(subItem.frame, offset, 0);
        }
        else
        {
            subItem.textStyle.textAlignment = UITextAlignmentCenter;
        }
    }
}

- (void)drawOneLineContext:(CGContextRef)context
{
    for (FB2PageTextItem* lineItem in _oneLineItems)
    {
        [self drawTextItem:lineItem context:context];
    }
    [_oneLineItems removeAllObjects];
}

- (void)drawTextItem:(FB2PageTextItem*)textItem context:(CGContextRef)context
{
    if (!_linkStyle)
        _linkStyle = [[FB2LinkTextStyle alloc] init];
    UIColor* textColor = ([textItem.textStyle.textColor isEqual:_linkStyle.textColor]) ? textItem.textStyle.textColor : [NWSettings sharedSettings].readerTextColor;

    CGContextSetFillColorWithColor(context, textColor.CGColor);
    CGContextSetStrokeColorWithColor(context, textColor.CGColor);

    NSString* textBlock = (NSString*)textItem.data;
    
    //textBlock = [textBlock hyphenatedStringWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru"]];
    [textBlock MTDrawInRect:textItem.frame
                   withFont:textItem.textStyle.textFont
              lineBreakMode:NSLineBreakByWordWrapping
                  alignment:textItem.textStyle.textAlignment];
}

- (void)drawStrikeThoughText:(NSString*)txt frame:(CGRect)rect style:(FB2TextStyle*)style
{
    if (!style.isStrikeThrough)
        return;
    
    if (!_linkStyle)
        _linkStyle = [[FB2LinkTextStyle alloc] init];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor* textColor = ([style.textColor isEqual:_linkStyle.textColor]) ? style.textColor : [NWSettings sharedSettings].readerTextColor;
    
    CGContextSetFillColorWithColor(context, textColor.CGColor);
    CGContextSetStrokeColorWithColor(context, textColor.CGColor);    
    CGContextSetLineWidth(context, 1.5);

    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y + rect.size.height/2 + rect.size.height*0.1;
    
    //txt = [txt hyphenatedStringWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru"]];
    
    [txt MTDrawInRect:rect
                      withFont:style.textFont
                 lineBreakMode:NSLineBreakByWordWrapping
                     alignment:style.textAlignment];
    
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x + rect.size.width, y);
    CGContextStrokePath(context);
}

- (void)drawStrikeThoughTextItem:(FB2PageTextItem*)textItem context:(CGContextRef)context
{
    if (!textItem.textStyle.isStrikeThrough)
        return;

    if (!_linkStyle)
        _linkStyle = [[[FB2LinkTextStyle alloc] init] autorelease];
    UIColor* textColor = ([textItem.textStyle.textColor isEqual:_linkStyle.textColor]) ?
    textItem.textStyle.textColor :
    [NWSettings sharedSettings].readerTextColor;

    CGContextSetFillColorWithColor(context, textColor.CGColor);
    CGContextSetStrokeColorWithColor(context, textColor.CGColor);
    
    NSArray *stringsArray = [self divideTextBlockForString:textItem];

    CGContextSetLineWidth(context, 1.5);
    CGSize stringSize;
    NSString *stringToDraw = nil;

    for (int j = 0; j < stringsArray.count; j++)
    {
        stringToDraw = [stringsArray objectAtIndex:j];
        //stringToDraw = [stringToDraw hyphenatedStringWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru"]];
        
        if (![[stringToDraw stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
        {
            
            stringSize = [stringToDraw MTSizeWithFont:textItem.textStyle.textFont
                                             forWidth:textItem.frame.size.width
                                        lineBreakMode:NSLineBreakByCharWrapping];

            CGRect curRect = CGRectMake(textItem.frame.origin.x,
                                        textItem.frame.origin.y + stringSize.height*j,
                                        textItem.frame.size.width,
                                        textItem.frame.size.height);
            CGFloat x = textItem.frame.origin.x;
            CGFloat y = curRect.origin.y + stringSize.height/2 + stringSize.height*0.1;

            
            [stringToDraw MTDrawInRect:curRect
                              withFont:textItem.textStyle.textFont
                         lineBreakMode:NSLineBreakByWordWrapping
                             alignment:textItem.textStyle.textAlignment];

            CGContextMoveToPoint(context, x, y);
            CGContextAddLineToPoint(context, x + stringSize.width, y);
            CGContextStrokePath(context);
        }
    }
}

- (void)drawImageItem:(FB2PageDataItem*)item
{
    if ([item.data isKindOfClass:[UIImage class]])
    {
        UIImage* img = (UIImage*)item.data;
        [img drawInRect:item.frame];
    }
}

- (NSArray*)divideTextBlockForString:(FB2PageTextItem*)textItem
{
    NSMutableArray* output = [[[NSMutableArray alloc] init] autorelease];
    NSString* theWord = nil;
    CGFloat strLen = 0;
    NSMutableString* theString = [[[NSMutableString alloc] init] autorelease];
    NSMutableString* tmpStr    = [[NSMutableString alloc] init];
    NSArray* wordsInBlock = [[NSString stringWithFormat:@"%@", textItem.data] divideByWhitespacesAnNewlinesWithBlock:nil];
    CGFloat sizeSpace = ([@" " MTSizeWithFont:textItem.textStyle.textFont]).width;
    
    for(int j = 0; j < wordsInBlock.count; j++) {
        theWord = [wordsInBlock objectAtIndex:j];
        
        if (theWord.length == 0) continue;
        
        [tmpStr appendString:theWord];
        strLen = ([tmpStr MTSizeWithFont:textItem.textStyle.textFont]).width;
        
        if (strLen > (_pageWidth)) {
            if ([[theWord substringFromIndex:(theWord.length-1)] isEqualToString:@" "]) {
                if (strLen > (_pageWidth+sizeSpace-1.0)) { // -1 for lenght error compensation
                    [output addObject:[NSString stringWithString:theString]];
                    [theString setString:theWord];
                    [tmpStr setString:@""];
                    [tmpStr appendString:theWord];
                } else {
                    [theString appendString:theWord];
                }
            } else {
                [output addObject:[NSString stringWithString:theString]];
                [theString setString:theWord];
                [tmpStr setString:@""];
                [tmpStr appendString:theWord];
            }
        } else {
            [theString appendString:theWord];
        }
    }
    
    if (theString.length > 1) {
        [output addObject:[NSString stringWithString:theString]];
    }
    
    [tmpStr release];
    return output;
}

- (void)drawUnderlineOnContext:(CGContextRef)context pageItem:(FB2PageTextItem*)item
{
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetStrokeColorWithColor(context, item.textStyle.textColor.CGColor);

    CGContextMoveToPoint(context, item.frame.origin.x, item.frame.origin.y + item.frame.size.height - 1);
    CGContextAddLineToPoint(context, item.frame.origin.x + item.frame.size.width, item.frame.origin.y + item.frame.size.height - 1);

    CGContextStrokePath(context);  
}

- (void)drawStrikeThroughtOnContext:(CGContextRef)context pageItem:(FB2PageTextItem*)item
{
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetStrokeColorWithColor(context, item.textStyle.textColor.CGColor);

    CGContextMoveToPoint(context, item.frame.origin.x, item.frame.origin.y + item.frame.size.height/2);
    CGContextAddLineToPoint(context, item.frame.origin.x + item.frame.size.width, item.frame.origin.y + item.frame.size.height/2);

    CGContextStrokePath(context);
}

#pragma mark Public methods

- (void)initializeWithPageGenerator:(FB2PagesGenerator *)generator
{
    [_pageGenerator release];
    _pageGenerator = [generator retain];
    [self setNeedsDisplay];
}

#pragma mark Private methods

- (void)initializeDefaults
{
    _pageGenerator = nil;
    currentPage = 0;
    pageMargin = 0;
    visiblePagesCount = 1;
}
- (void)showCurrentPosition
{
    [self setNeedsDisplay];
}

- (void)updatePageSize
{
    _pageWidth  = (double)(self.frame.size.width - pageMargin*(visiblePagesCount + 1))/visiblePagesCount;
    _pageHeight = self.frame.size.height - 2*pageMargin;
}

#pragma mark Property accessors

- (void)setCurrentPage:(int)value
{
    if (value != currentPage)
    {
        currentPage = value;
        [self setNeedsDisplay];
    }
}

- (CGSize)pageSize
{
    return CGSizeMake(_pageWidth, _pageHeight);
}
@end
