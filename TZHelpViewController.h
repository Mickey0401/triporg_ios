//
//  TZHelpViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 10/07/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface TZHelpViewController : UIViewController

@property (nonatomic, assign) IBOutlet UIPageControl *indicePaginas;
@property (nonatomic, assign) IBOutlet UIImageView *imagenAyuda;
@property (nonatomic, assign) IBOutlet UILabel *textoAyuda;
@property (nonatomic, assign) IBOutlet UILabel *tituloAyuda;
@property (nonatomic, assign) IBOutlet UIView *viewAyuda;

@end
