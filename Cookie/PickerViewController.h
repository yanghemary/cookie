//
//  PickerViewController.h
//  Cookie
//
//  Created by He Yang on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate> {
    NSMutableArray *shareMethods;
    IBOutlet UIPickerView *pickerView;
}

@end
