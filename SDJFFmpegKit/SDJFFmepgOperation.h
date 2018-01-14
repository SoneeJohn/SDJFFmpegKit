//
//  SDJFFmepgOperation.h
//  SDJFFmpegKit
//
//  Created by Soneé John on 1/14/18.
//  Copyright © 2018 Soneé John. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDJFFmepgOperation : NSOperation

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithInputPaths:(NSArray<NSString *> *)inputhPaths outputPath:(NSString *)outputPath options:(NSDictionary<id, NSArray *> * __nullable)options NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithInputPath:(NSString *)inputPath outputPath:(NSString *)outputPath;

@property (strong, atomic, readonly) NSArray<NSString *> *inputPaths;
@property (strong, atomic, readonly) NSString *outputPath;
@property (nullable, strong, atomic, readonly) NSDictionary<id, NSArray *> *options;
@property (nullable, strong, atomic, readonly) NSData *outputData;

extern NSString *const SDJFFmepgOperationGlobalOptionsKey;
extern NSString *const SDJFFmepgOperationInputFileOptionsKey;
extern NSString *const SDJFFmepgOperationOutputFileOptionsKey;

@end

NS_ASSUME_NONNULL_END
