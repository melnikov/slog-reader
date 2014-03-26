//
//  FB2PoemGenerator.m
//  NewspaperWorld
//
//  Created by Эльдар Пикунов on 08.04.13.
//
//

#import "FB2PoemGenerator.h"
#import "FB2PageGeneratorContext.h"
#import "FB2Poem.h"

@implementation FB2PoemGenerator

- (void)generatePagesForItem:(FB2Item*)item withContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle
{

    if (![item isKindOfClass:[FB2Poem class]])
        return;

    FB2Poem* poem = (FB2Poem*)item;
    FB2TextStyle* style = poem.textStyle;
    style.textType = TEXTTYPE_EPIGRAPH;
    style.textAlignment = UITextAlignmentCenter;

    for (FB2Item* subItem in poem.subItems)
    {
        [subItem generatePagesWithContext:context parentStyle:style];
    }

    if (poem.textAuthor.subItems.count > 0)
    {
        [poem.textAuthor generatePagesWithContext:context parentStyle:poem.textAuthor.textStyle];
        [context nextStringWithLineHeight:poem.textAuthor.textStyle.lineHeight];
    }    

    if (poem.date.subItems.count > 0)
    {
        [poem.date generatePagesWithContext:context parentStyle:poem.textAuthor.textStyle];
        [context nextStringWithLineHeight:poem.textAuthor.textStyle.lineHeight];
    }

    if (poem.ID.length > 0)
        [context.page.nodeIDs addObject:poem.ID];
}

@end
