//
//  XYTopImageManager.h
//  Designer
//
//  Created by 罗 显扬 on 4/1/15.
//  Copyright (c) 2015 罗 显扬. All rights reserved.
//

#import "JSONModel.h"
#import "XYTopImage.h"

@interface XYTopImageManager : JSONModel

@property (assign, nonatomic) long list_size;
@property (strong, nonatomic) NSArray <XYTopImage> *focus_list;

@end
