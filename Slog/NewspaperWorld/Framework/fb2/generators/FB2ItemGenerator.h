//
//  FB2ItemGenerator.h
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 08.04.13.
//
//

#import <Foundation/Foundation.h>

@class FB2Item;
@class FB2PageGeneratorContext;
@class FB2TextStyle;

@protocol FB2ItemGenerator <NSObject>

@required
- (void)generatePagesForItem:(FB2Item*)item withContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle;

@end
