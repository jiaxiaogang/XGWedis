//
//  SMGUtils.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/19.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Demo : NSObject

+(id) searchObjectForFilePath:(NSString*)filePath fileName:(NSString*)fileName time:(double)time;
+(void) insertObject:(NSObject*)obj rootPath:(NSString*)rootPath fileName:(NSString*)fileName time:(double)time;//同时插入到redis,time秒

@end
