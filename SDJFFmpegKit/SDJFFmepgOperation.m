//
//  SDJFFmepgOperation.m
//  SDJFFmpegKit
//
//  Created by Soneé John on 1/14/18.
//  Copyright © 2018 Soneé John. All rights reserved.
//

#import "SDJFFmepgOperation.h"

@interface SDJFFmepgOperation ()

@property (strong, atomic) NSArray<NSString *> *inputPaths;
@property (strong, atomic) NSString *outputPath;
@property (strong, atomic) NSDictionary<id, NSArray *> *options;
@property (strong, atomic) NSTask *task;
@property (strong, atomic) NSMutableData *outputDataBacking;
@property (strong, atomic) NSError *error;

@property (assign, atomic) BOOL isFinished;
@property (assign, atomic) BOOL isExecuting;

@end

NSString *const SDJFFmepgOperationGlobalOptionsKey = @"ALSYouTubeFFmpegWrapperOperationGlobalOptionsKey";
NSString *const SDJFFmepgOperationInputFileOptionsKey = @"ALSYouTubeFFmpegWrapperOperationInputFileOptionsKey";
NSString *const SDJFFmepgOperationOutputFileOptionsKey = @"ALSYouTubeFFmpegWrapperOperationOutputFileOptionsKey";
NSString *const SDJFFmepgOperationErrorDomain = @"SDJFFmepgOperationErrorDomain";

@implementation SDJFFmepgOperation

#pragma mark - Life cycle

- (instancetype)initWithInputPaths:(NSArray<NSString *> *)inputPaths outputPath:(NSString *)outputPath options:(NSDictionary<id, NSArray *> *)options {
    
    self = [super init];
    
    if (self) {
        _inputPaths = inputPaths;
        _outputPath = outputPath;
        _options = options;
    }
    
    return self;
}

- (instancetype)initWithInputPath:(NSString *)inputPath outputPath:(NSString *)outputPath {
    return [self initWithInputPaths:@[inputPath] outputPath:outputPath options:nil];
}

#pragma mark - NSOperation

- (void)start {
    if (self.isCancelled || self.isFinished) { return; }
    
    self.isExecuting = YES;
    
    self.task = [NSTask new];
    self.task.launchPath = [[NSBundle bundleForClass:[self class]]pathForResource:@"ffmpeg" ofType:@""];
    self.task.arguments = [self lauchArguments];
    
    NSPipe *pipe = [NSPipe pipe];
    // Very important to set the standardOutput to a pipe. Once the parent process is terminated the `NSTask` will be terminated automatically.
    self.task.standardError = pipe;
    self.task.standardOutput = pipe;
    self.task.standardInput = [NSFileHandle fileHandleWithStandardInput];
    
    [[self.task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        
        if (self.outputDataBacking == nil) {
            self.outputDataBacking = [NSMutableData new];
        }
        
        [self.outputDataBacking appendData:[file availableData]];
    }];
    
    __weak typeof(self) weakSelf = self;
    
    self.task.terminationHandler = ^(NSTask * task){
        //Set readabilityHandler to nil or the reading will never stop
        [task.standardOutput fileHandleForReading].readabilityHandler = nil;
        
        if (task.terminationStatus == 0) {
           [weakSelf finish];
           return;
        }
        
        [weakSelf finishWithError:[NSError errorWithDomain:SDJFFmepgOperationErrorDomain code:task.terminationStatus userInfo:@{NSLocalizedDescriptionKey: @"Operation failed"}]];
    };
    
    [self.task launch];
}

- (void)cancel {
    if (self.isCancelled || self.isFinished) { return; }
    
    [super cancel];
    [self.task terminate];
}

- (void)finish {
    
    self.isExecuting = NO;
    self.isFinished = YES;
}

- (void)finishWithError:(NSError *)error {
    
    self.error = error;
    [self finish];
}

- (BOOL)isAsynchronous {
    return YES;
}

#pragma mark - Private

- (NSArray *)lauchArguments {
    
    NSMutableArray *arguments = [NSMutableArray new];
    [arguments addObject:@"-y"]; //Overwrite output files
    [arguments addObject:@"-nostdin"]; //Disables interaction on standard input. See https://ffmpeg.org/ffmpeg.html#Main-options for more info.
    
    if (self.options[SDJFFmepgOperationGlobalOptionsKey]) {
        [arguments addObjectsFromArray:self.options[SDJFFmepgOperationGlobalOptionsKey]];
    }
    
    if (self.options[SDJFFmepgOperationInputFileOptionsKey]) {
        [arguments addObjectsFromArray:self.options[SDJFFmepgOperationInputFileOptionsKey]];
    }
    
    for (NSString *inputPath in self.inputPaths) {
        [arguments addObject:@"-i"];
        [arguments addObject:inputPath];
    }
    
    if (self.options[SDJFFmepgOperationOutputFileOptionsKey]) {
        [arguments addObjectsFromArray:self.options[SDJFFmepgOperationOutputFileOptionsKey]];
    }
    
    [arguments addObject:self.outputPath];
    
    return arguments.copy;
};

#pragma mark - Getters

- (NSData *)outputData {
    return self.outputDataBacking.copy;
}

#pragma mark - KVO

+ (BOOL) automaticallyNotifiesObserversForKey:(NSString *)key {
    SEL selector = NSSelectorFromString(key);
    return selector == @selector(isExecuting) || selector == @selector(isFinished) || [super automaticallyNotifiesObserversForKey:key];
}

@end
