//
//  FB2TitleGenerator.m
//  NewspaperWorld
//
//  Created by Эльдар Пикунов on 08.04.13.
//
//

#import "FB2TitleGenerator.h"
#import "FB2PageGeneratorContext.h"
#import "FB2Title.h"

@implementation FB2TitleGenerator

- (void)generatePagesForItem:(FB2Item*)item withContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle
{
    if (![item isKindOfClass:[FB2Title class]])
        return;

    FB2Title* title = (FB2Title*)item;
    FB2TextStyle* style = parentStyle;
    style.textType = TEXTTYPE_EPIGRAPH;
    [title setTextStyle:style];
    BOOL first = YES;
    for (FB2Item* subItem in title.subItems)
    {
        if (first)
        {
            if (!context.page)
                context.page = [FB2PageData pageData];

            [context.page.items addItem:[FB2PageDataItem itemWithData:nil frameRect:CGRectZero fb2ItemID:title.itemID]];
            first = NO;
        }
        [subItem generatePagesWithContext:context parentStyle:title.textStyle];

        if (subItem.ID.length > 0)
            [context.page.nodeIDs addObject:subItem.ID];
    }    
}

@end
