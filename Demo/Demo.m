//
//  SMGUtils.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/19.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Demo.h"
#import "PINCache.h"
#import "XGWedis.h"
#import "XGRedis.h"

@implementation Demo

+(id) searchObjectForFilePath:(NSString*)filePath fileName:(NSString*)fileName time:(double)time{
    //1. 数据检查
    filePath = STRTOOK(filePath);

    //2. 优先取redis
    NSString *key = STRFORMAT(@"%@/%@",filePath,fileName);//随后去掉前辍
    id result = [[XGRedis sharedInstance] objectForKey:key];

    //3. 再取wedis
    if (result == nil) {
        result = [[XGWedis sharedInstance] objectForKey:key];

        //4. 最后取disk
        if (result == nil) {
            PINDiskCache *cache = [[PINDiskCache alloc] initWithName:@"" rootPath:filePath];
            result = [cache objectForKey:fileName];
        }

        //5. 存到redis (wedis/disk)
        if (time > 0 && result) {
            [[XGRedis sharedInstance] setObject:result forKey:key time:time];
        }
    }
    return result;
}

+(void) insertObject:(NSObject*)obj rootPath:(NSString*)rootPath fileName:(NSString*)fileName time:(double)time{
    //1. 存disk (异步持久化)
    NSString *key = STRFORMAT(@"%@/%@",rootPath,fileName);
    [[XGWedis sharedInstance] setObject:obj forKey:key];
    [[XGWedis sharedInstance] setSaveBlock:^(NSDictionary *dic) {
        dic = DICTOOK(dic);
        for (NSString *saveKey in dic.allKeys) {
            NSObject *saveObj = [dic objectForKey:saveKey];

            NSArray *saveKeyArr = ARRTOOK([saveKey componentsSeparatedByString:@"/"]);
            NSString *saveFileName = ARR_INDEX(saveKeyArr, saveKeyArr.count - 1);
            saveFileName = STRTOOK(saveFileName);
            NSString *saveRootPath = STRTOOK(SUBSTR2INDEX(saveKey, (saveKey.length - saveFileName.length - 1)));
            PINDiskCache *cache = [[PINDiskCache alloc] initWithName:@"" rootPath:saveRootPath];
            [cache setObject:saveObj forKey:saveFileName];
        }
    }];

    //2. 存redis
    [[XGRedis sharedInstance] setObject:obj forKey:key time:time];//随后去掉(redisKey)前辍
}

@end
