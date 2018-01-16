//
//  SDJFFmpegClient.h
//  SDJFFmpegKit
//
//  Created by Soneé John on 1/16/18.
//  Copyright © 2018 Soneé John. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDJFFmpegKit/SDJFFmepgOperation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDJFFmpegClient : NSObject

+ (SDJFFmpegClient *)sharedClient;

- (void)convertInputPaths:(NSArray<NSString *> *)inputPaths outputPath:(NSString *)outputPath options:(NSDictionary<id, NSArray *> * __nullable)options completionHandler:(void (^)(SDJFFmepgOperation *operation))completionHandler;

- (void)convertInputPaths:(NSArray<NSString *> *)inputPaths outputPath:(NSString *)outputPath completionHandler:(void (^)(SDJFFmepgOperation *__nullable))completionHandler;

NS_ASSUME_NONNULL_END

@end
