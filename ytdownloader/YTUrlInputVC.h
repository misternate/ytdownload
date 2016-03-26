//
//  YTUrlInput.h
//  ytdownloader
//
//  Created by Nate Edwards on 2/14/16.
//  Copyright © 2016 oso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTGetVideoProps.h"

@interface YTUrlInputVC : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *youtubeUrlField;
-(void)updateUrlField: (NSString*)updatedStringValue;

@end
