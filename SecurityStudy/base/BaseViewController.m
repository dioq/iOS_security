//
//  CheckViewController.m
//  SecurityStudy
//
//  Created by Dio Brand on 2023/4/11.
//

#import "BaseViewController.h"
#import "MyPtrace.h"
#import <mach-o/dyld.h>
#import <sys/sysctl.h>
#import "JailbreakTool.h"

@interface BaseViewController ()<UITextViewDelegate>

// 动态库黑名单
@property(nonatomic,strong)NSMutableArray *blacklist_dylib;
// 动态库白名单
@property(nonatomic,strong)NSMutableArray *whitelist_dylib;
// 文件黑名单
@property(nonatomic,strong)NSMutableArray *blacklist_file;
@property (weak, nonatomic) IBOutlet UITextView *show;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"基本防护";
    self.show.delegate = self;
    
    self.blacklist_dylib = [[NSMutableArray alloc] init];
    self.whitelist_dylib = [[NSMutableArray alloc] init];
    [self.blacklist_dylib addObject:@"/Library/MobileSubstrate/DynamicLibraries"];
    [self.blacklist_dylib addObject:@"frida"];
    
    self.blacklist_file = [[NSMutableArray alloc] init];
    [self.blacklist_file addObject:@"/usr/lib/frida/frida-agent.dylib"];
    NSArray *jailbroke_files = @[
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
    [self.blacklist_file addObjectsFromArray:jailbroke_files];
}

- (IBAction)ptrace_act:(UIButton *)sender {
    //app反调试防护,运行这行代码后就不再允许其他进程附加上了
    ptrace(PT_DENY_ATTACH, 0, 0, 0);
}

- (BOOL)isDebug{
    int name[4];//里面存放字节码
    name[0] = CTL_KERN;//内核查询
    name[1] = KERN_PROC;//查询进程
    name[2] = KERN_PROC_PID;//传递的参数是进程ID
    name[3] = getpid();//PID 进程ID
    
    struct kinfo_proc info;//查询到的结果放到此结构体
    
    size_t info_size = sizeof(info);
    
    //调试信息
    sysctl(name, sizeof(name)/sizeof(*name), &info, &info_size, 0, 0);
    
    //info.kp_proc.p_flag 第12位若为1则存在调试
    
    return ((info.kp_proc.p_flag & P_TRACED) !=0);
}
- (IBAction)darwin_act:(UIButton *)sender {
    if([self isDebug]){
        [self.show setText:@"正在被调试"];
    }else{
        [self.show setText:@"没有被其他程序调试"];
    }
}

- (IBAction)dylib_check:(UIButton *)sender {
    NSMutableDictionary *tipDict = [NSMutableDictionary dictionary];
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0 ; i < count; ++i) {
        const char *image_name = _dyld_get_image_name(i);
        //        printf("%s\n",name);
        NSString *image_name2 = [NSString stringWithUTF8String:image_name];
        for (NSString *dylib_name in self.blacklist_dylib) {
            if ([image_name2 containsString:dylib_name]) {
                [tipDict setValue:@"可疑动态库" forKey:image_name2];
            }
        }
    }
    [self showLog:tipDict];
}

- (IBAction)file_check:(UIButton *)sender {
    NSMutableDictionary *tipDict = [NSMutableDictionary dictionary];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *filePath in self.blacklist_file) {
        if ([fileManager fileExistsAtPath:filePath]) {
            [tipDict setValue:@"存在" forKey:filePath];
        }else{
            [tipDict setValue:@"没检测到" forKey:filePath];
        }
    }
    [self showLog:tipDict];
}

- (IBAction)jailbreak_check:(UIButton *)sender {
    BOOL isOr = [[JailbreakTool sharedManager] isJailbroken];
    NSString *result = nil;
    if (isOr) {
        result = @"已经越狱";
    }else{
        result = @"没有越狱";
    }
    [self showTip:result];
}

-(void)showTip:(NSString * _Nonnull)tip {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.show setText:tip];
        NSLog(@"%@",tip);
    });
}

-(void)showLog:(NSDictionary * _Nonnull)tipDict {
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tipDict options:NSJSONWritingPrettyPrinted error:&err];
    
    if (err) {
        [self showTip:[err localizedFailureReason]];
    }else{
        NSString *logStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self showTip:logStr];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
