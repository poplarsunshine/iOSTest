//
//  ViewController.m
//  Blocks
//
//  Created by hetao on 2017/11/9.
//  Copyright © 2017年 hetao. All rights reserved.
//

//参考链接 http://www.jianshu.com/p/14efa33b3562

#import "ViewController.h"

typedef int (^Block21) (int a, int b);

@interface ViewController ()

@end

@implementation ViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    // Block的简单声明、赋值、调用
//    [self blockDefine];
//
//    // 使用typedef定义Block类型
//    [self blockTypedef];
//
//    // Block作为函数参数
//    [self blockArg];
    
    // Block内访问变量
    [self blockVar];
}

#pragma mark - Block的简单声明、赋值、调用
// Block的简单声明、赋值、调用
- (void)blockDefine
{
    /**
     Block变量的声明格式：【返回值类型(^Block名称)(参数列表);】
     * 形参变量名称可以省略,只留有变量类型即可
     * ^被称为“脱字符”
    */
    //    void (^printSumblock)(int a, int b);
    void (^printSumblock)(int, int);
    
    /**
     Block的赋值格式：【Block变量 = ^(参数列表){函数体};】
     */
    printSumblock = ^(int a, int b){
        NSLog(@"%i+%i=%i", a, b, a + b);
    };
    
    /**
     声明并赋值：
     * Block变量的赋值格式可以是: Block变量 = ^返回值类型(参数列表){函数体};
     * 不过通常情况下都将返回值类型省略,因为编译器可以从存储代码块的变量中确定返回值的类型
    */
    //    int (^returnSumBlock)(int, int) = ^int(int a, int b) {
    int (^returnSumBlock)(int, int) = ^(int a, int b) {
        return a + b;
    };
    
    /**
     Block变量的调用：
     */
    printSumblock(23, 33);
    NSLog(@"sum=%i", returnSumBlock(11, 22));
}

// 使用typedef定义Block类型, 具有复用性
- (void)blockTypedef
{
    // 定义无返回值及参数的 Block类型
    // 格式：【typedef returnType(^name)(arguments);】
    typedef void (^ PrintMessage)(void);
    
    // 声明Block类型变量
    PrintMessage printHello = ^(){
        NSLog(@"hello");
    };
    PrintMessage printSorry = ^(){
        NSLog(@"sorry");
    };

    printHello();
    printSorry();
}
#pragma mark - Block作为函数参数

- (void)blockArg
{
    int (^block)(int, int) = ^(int a, int b){
        return a + b;
    };
    [self blockBeArg:block];
    [self blockBeArg:^(int a, int b){
        return b + a;
    }];
    Block21 addBlock = ^(int a, int b){
        return a + b;
    };
    Block21 subBlock = ^(int a, int b){
        return a - b;
    };
    int sum = [self blockIsArg:addBlock];
    int sub = [self blockIsArg:subBlock];
    NSLog(@"sum = %d, sub = %d", sum, sub);
}

// Block作为函数参数
- (void)blockBeArg:(int (^)(int, int)) block
{
    NSLog(@"result = %i", block(11, 33));
}

- (int)blockIsArg:(Block21) block
{
    return block(30, 10);
}

#pragma mark - Block内访问变量
- (void)blockVar
{
    [self blockLocalVar];

    [self blockGloableVar];
    
    [self blockStaticVar];
}

/**
 Block内访问局部变量
 block复制时将局部变量copy，并且不可更改
 加上__block修饰词，可在block内部获得变量指针
 */
- (void)blockLocalVar
{
//    __block int num = 1;
    int num = 1;

    void(^block)(void) = ^(){
        NSLog(@"block num = %d", num);
    };
    
    NSLog(@"num = %d", num);
    num = 2;
    
    block();
}

/**
 Block内访问全局变量
 全局变量所占用的内存只有一份,供所有函数共同调用
 在Block定义时并未将全局变量的值或者指针传给Block变量所指向的结构体
 因此在调用Block之前对局部变量进行修改会影响Block内部的值,同时内部的值也是可以修改的
 */
int GloableNum = 100;
- (void)blockGloableVar
{
    void(^block)(void) = ^(){
        NSLog(@"block GloableNum = %d", GloableNum);
    };
    
    GloableNum = 200;
    
    block();
}

/**
 Block内访问静态变量
 在Block定义时便是将静态变量的指针传给Block变量所指向的结构体
 因此在调用Block之前对静态变量进行修改会影响Block内部的值,同时内部的值也是可以修改的
 */
static int GloableStaticNum = 8000;
- (void)blockStaticVar
{
    void(^block)(void) = ^(){
        NSLog(@"block GloableStaticNum = %d", GloableStaticNum);
    };
    
    GloableStaticNum = 9000;

    block();
}
@end
