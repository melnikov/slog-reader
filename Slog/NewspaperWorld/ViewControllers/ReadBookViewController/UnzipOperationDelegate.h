//
//  UnzipOperationDelegate.h
//  NewspaperWorld
//


#import <Foundation/Foundation.h>

@class UnzipOperation;

@protocol UnzipOperationDelegate <NSObject>

- (void)unzipOperationFinished:(UnzipOperation*)operation withData:(NSData*)unzippedData;

- (void)unzipOperationFailed:(UnzipOperation*)operation;

@end
