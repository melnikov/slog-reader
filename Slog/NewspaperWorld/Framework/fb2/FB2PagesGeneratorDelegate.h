//
//  FB2ViewDelegate.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>

@protocol FB2PagesGeneratorDelegate <NSObject>
@optional

- (void)pageGeneratingFinished;

@end
