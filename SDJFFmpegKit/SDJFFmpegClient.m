//
//  SDJFFmpegClient.m
//  SDJFFmpegKit
//
//  Created by Soneé John on 1/16/18.
//  Copyright © 2018 Soneé John. All rights reserved.
//

#import "SDJFFmpegClient.h"

@interface SDJFFmpegClient ()

@property (strong, atomic) NSOperationQueue *queue;

@end

@implementation SDJFFmpegClient


#pragma mark - Life cycle

+ (SDJFFmpegClient *)sharedClient {
    
    static SDJFFmpegClient *sharedClient = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _queue = [NSOperationQueue new];
        _queue.maxConcurrentOperationCount = 3;
        _queue.name = [NSString stringWithFormat:@"%@ Queue", NSStringFromClass([self class])];
    }
    
    return self;
}

#pragma - Public

- (void)convertInputPaths:(NSArray<NSString *> *)inputPaths outputPath:(NSString *)outputPath options:(NSDictionary<id, NSArray *> * __nullable)options completionHandler:(void (^)(SDJFFmepgOperation *))completionHandler {
    
    SDJFFmepgOperation *operation = [[SDJFFmepgOperation alloc]initWithInputPaths:inputPaths outputPath:outputPath options:options];
    __weak SDJFFmepgOperation *weakOperation = operation;
    
    operation.completionBlock = ^{
        completionHandler(weakOperation);
    };
    
    [self.queue addOperation:operation];
}

- (void)convertInputPaths:(NSArray<NSString *> *)inputPaths outputPath:(NSString *)outputPath completionHandler:(void (^)(SDJFFmepgOperation * _Nonnull))completionHandler {
    
    [self convertInputPaths:inputPaths outputPath:outputPath options:nil completionHandler:^(SDJFFmepgOperation * __nullable operation) {
       
        completionHandler(operation);
    }];
}

@end
