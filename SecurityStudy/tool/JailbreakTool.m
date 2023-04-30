//
//  JailbreakTool.m
//  ReverseOC
//
//  Created by lzd_free on 2020/12/26.
//

#import "JailbreakTool.h"
#import <UIKit/UIKit.h>

@implementation JailbreakTool

+ (instancetype)sharedManager {
    static JailbreakTool *staticInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[super allocWithZone:NULL] init]; // 与下面两个方匹配
    });
    return staticInstance;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    return [[self class] sharedManager];
}

-(id)copyWithZone:(struct _NSZone *)zone{
    return [[self class] sharedManager];
}

-(BOOL)isJailbroken{
    BOOL status1 = [self checkFile];
    BOOL status2 = [self canCallCydia];
    BOOL status3 = [self checkEnv];
    BOOL status = status1 || status2 || status3;
    return  status;
}

-(BOOL)checkFile {
    NSArray *filePaths = @[
        @"/Applications/Cydia.app",
        @"/Applications/limera1n.app",
        @"/Applications/greenpois0n.app",
        @"/Applications/blackra1n.app",
        @"/Applications/blacksn0w.app",
        @"/Applications/redsn0w.app",
        @"/Applications/Absinthe.app",
        @"/User/Applications/",
        @"/private/var/lib/apt/"
    ];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *filePath in filePaths) {
        if([fileManager fileExistsAtPath:filePath]) {
            return YES;
        }
    }
    return NO;
}

//能否唤起Cydia商店
-(BOOL)canCallCydia {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        return YES;
    }
    return NO;
}

//读取环境变量
-(BOOL)checkEnv {
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (env) {
        return YES;
    }
    return NO;
}

@end
