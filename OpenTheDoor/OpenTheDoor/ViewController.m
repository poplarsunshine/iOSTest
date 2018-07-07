//
//  ViewController.m
//  OpenTheDoor
//
//  Created by hetao on 2018/5/18.
//  Copyright © 2018年 hetao. All rights reserved.
//

#import "ViewController.h"
#import <zlib.h>


/*
 1-1后门  door_guid=BDD4001702-4854&door_id=619590
 1-1前门  door_guid=BDD4001702-5620&door_id=643804
 东门     door_guid=BDD4001702-4888&door_id=618448
 南门     door_guid=BDD4001702-4267&door_id=617353
 西门     door_guid=BDD4001702-4592&door_id=613725
 北门     door_guid=BDD4001702-3759&door_id=643492

 */
typedef enum : NSUInteger {
    DoorType_11back   = 0,   //1号楼一单元前门
    DoorType_11front  = 1,   //1号楼一单元后门
    DoorType_East     = 2,   //东门
    DoorType_South    = 3,   //南门
    DoorType_West     = 4,   //西门
    DoorType_North    = 5,   //北门

} DoorType;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *tipLb;
@property (weak, nonatomic) IBOutlet UILabel *messageLb;

- (IBAction)btnAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)btnAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [self openTheDoor:btn.tag];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self openTheDoor:DoorType_11back];
}

- (void)openTheDoor:(DoorType)door
{
    NSString *door_guid = @"";
    NSString *door_id = @"";
    NSString *doorName = @"";
    switch (door) {
        case DoorType_11back:
            door_guid = @"BDD4001702-4854";
            door_id = @"619590";
            doorName = @"后门";
            break;
        case DoorType_11front:
            door_guid = @"BDD4001702-5620";
            door_id = @"643804";
            doorName = @"前门";
            break;
        case DoorType_East:
            door_guid = @"BDD4001702-4888";
            door_id = @"618448";
            doorName = @"东门";
            break;
        case DoorType_South:
            door_guid = @"BDD4001702-4267";
            door_id = @"617353";
            doorName = @"南门";
            break;
        case DoorType_West:
            door_guid = @"BDD4001702-4592";
            door_id = @"613725";
            doorName = @"西门";
            break;
        case DoorType_North:
            door_guid = @"BDD4001702-3759";
            door_id = @"643492";
            doorName = @"北门";
            break;
        default:
            door_guid = @"BDD4001702-4854";
            door_id = @"619590";
            doorName = @"后门";
            break;
    }
    
    NSString *urlString = @"https://mobile.api.doordu.com/api/index.php/v10/doors/open";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    [request addValue:@"mobile.api.doordu.com" forHTTPHeaderField: @"Host"];
    [request addValue:@"*/*" forHTTPHeaderField: @"Accept"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    [request addValue:@"{\"app_version\":\"1.3.8\",\"system_type\":\"1\",\"system_version\":\"11.3\",\"system_models\":\"iPhone6sPlus\"}" forHTTPHeaderField: @"doordu-system"];
    [request addValue:@"br, gzip, deflate" forHTTPHeaderField: @"Accept-Encoding"];
    [request addValue:@"BSH/1.3.8 (iPhone; iOS 11.3; Scale/3.00)" forHTTPHeaderField: @"User-Agent"];
    [request addValue:@"com.doordu.doordushijie" forHTTPHeaderField: @"Package-Name"];
    [request addValue:@"Basic YTQ3YTc4OTg0ODFlYWJmNzdhMWE1Y2UwNjFmNzkwOGI6OTNmMzgyZmZmY2EyN2Y4ZTRjODBlOGQ3NWUzNzM5MGU=" forHTTPHeaderField: @"Authorization"];

    NSString *device_guid = @"10C608A0-3168-4BDA-A3F7-6BA2D18F2738";
    NSString *device_type = @"3";
    NSString *room_id = @"4958767";
    NSString *token = @"68028be2-1a8a-441a-ab17-bd549ae31f68";
    NSString *user_id = @"713958";
    
    NSString *body = [NSString stringWithFormat:@"device_guid=%@&device_type=%@&door_guid=%@&door_id=%@&room_id=%@&token=%@&user_id=%@",
                      device_guid,
                      device_type,
                      door_guid,
                      door_id,
                      room_id,
                      token,
                      user_id];

    NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
//    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    NSLog(@"resultDic=%@", resultDic);
    BOOL isOpen = [resultDic count] == 0;
    NSString *success = isOpen ? @"成功" : @"失败";
    NSString *msg = [NSString stringWithFormat:@"开启%@%@", doorName, success];
    NSString *reason = isOpen ? @"" : resultDic[@"message"];

    self.tipLb.text = msg;
    self.messageLb.text = reason;

//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil])];
//    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
