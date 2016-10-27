//
//  BleConnect.h
//  Pedometer
//
//  Created by jinou on 16/9/19.
//  Copyright © 2016年 com.jinou.Pedometer. All rights reserved.
//
#if 0
#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, BleCmdType)
{
    System_Notification = -1,
    BleCmdType_Pedo_Start = 0,
    BleCmdType_Pedo_Stop,
    BleCmdType_Pedo_Inqury,
    BleCmdType_Pedo_Clear,
    BleCmdType_AntiLoss_Alert_Clear,
    BleCmdType_AntiLoss_Alert_Normal,
    BleCmdType_AntiLoss_Alert_Rapid
};

typedef NS_ENUM(NSInteger, BleErrorType)
{
    BleErrorTypeNone = 0,
    BleErrorTypePoweroff,
    BleErrorTypeHasConnection,
    BleErrorTypeSendDataFail
};

@protocol BleDelegate <NSObject>

@optional

-(void)didDiscoverDevice:(NSDictionary*)device;

-(void)didconnectedSuccess:(BOOL)status;

-(void)didDisconnected;

-(void)didSendDataSuccess:(BOOL)status;

-(void)didRecieveData:(NSData*)data;

-(void)didRecieveTakePhotoEvent;

@end

@interface BleConnect : NSObject

@property(assign, nonatomic) id<BleDelegate> delegate;

@property(assign, nonatomic) CGFloat distance;

@property(assign, nonatomic) BOOL didconnected;

-(instancetype)initWithDelegate:(id<BleDelegate>)delegate;

-(BleErrorType)getDeviceList;

-(BleErrorType)connectRequest:(NSData*)mac;

-(void)cancelConnect;

-(BleErrorType)sendDataToPerWithcmdType:(BleCmdType)type;

-(BleErrorType)getDistance;

-(BleErrorType)stoppdateDistance;

@end

#endif
