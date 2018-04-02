//
//  TZHelpViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 10/07/13.
//
//

#import "TZHelpViewController.h"
#import "UIColor+String.h"

@interface TZHelpViewController ()

@end

@implementation TZHelpViewController {
    NSInteger numeroAyuda;
}

@synthesize textoAyuda,imagenAyuda,indicePaginas, viewAyuda, tituloAyuda;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Ayuda", @"");
    
    imagenAyuda.image = [UIImage imageNamed:@"captura1.jpg"];
    imagenAyuda.backgroundColor = [UIColor whiteColor];
    
    UISwipeGestureRecognizer *swipeRecognizerR =
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(swipeDetectedR:)];
    swipeRecognizerR.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRecognizerR];
    
    UISwipeGestureRecognizer *swipeRecognizerL =
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(swipeDetectedL:)];
    swipeRecognizerL.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRecognizerL];
    
    numeroAyuda = 0;
    
    indicePaginas.currentPage = 0;
    indicePaginas.numberOfPages = 6;
    
    tituloAyuda.text = NSLocalizedString(@"Organiza tu tiempo de viaje", @"");
    textoAyuda.text = NSLocalizedString(@"Selecciona tu ciudad destino, el tipo de viaje, las fechas de visita.", @"");
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        tituloAyuda.font = [UIFont systemFontOfSize:22];
        textoAyuda.font = [UIFont systemFontOfSize:20];
        textoAyuda.textAlignment = NSTextAlignmentCenter;
        imagenAyuda.backgroundColor = [UIColor whiteColor];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)swipeDetectedR:(UIGestureRecognizer *)sender
{
    if (numeroAyuda == 0)
    {
        
    }
    else
    {
        numeroAyuda--;
        indicePaginas.currentPage = numeroAyuda;
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.36];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromLeft];
        [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
        [[viewAyuda layer] addAnimation:animation forKey:@"SwitchToView1"];
    }
    
    [self setHelpTextAndImage];
}

- (void)swipeDetectedL:(UIGestureRecognizer *)sender
{
    if (numeroAyuda == 5)
    {
        //[self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        numeroAyuda++;
        indicePaginas.currentPage = numeroAyuda;
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.36];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
        [[viewAyuda layer] addAnimation:animation forKey:@"SwitchToView2"];
    }
    
    [self setHelpTextAndImage];
}

/** Cambia la imagen y el texto de la ayuda segun vamos deslizando el dedo */
- (void)setHelpTextAndImage
{
    switch (indicePaginas.currentPage)
    {
        case 0:
            tituloAyuda.text = NSLocalizedString(@"Organiza tu tiempo de viaje", @"");
            textoAyuda.text = NSLocalizedString(@"Selecciona tu ciudad destino, el tipo de viaje, las fechas de visita.", @"");
            imagenAyuda.image = [UIImage imageNamed:@"captura1.jpg"];
            break;
        case 1:
            tituloAyuda.text = NSLocalizedString(@"En segundos obtén el resultado", @"");
            textoAyuda.text = NSLocalizedString(@"Un listado de actividades en su horario recomendado, su información y un mapa de localización.", @"");
            imagenAyuda.image = [UIImage imageNamed:@"captura2.jpg"];
            break;
        case 2:
            tituloAyuda.text = NSLocalizedString(@"La oferta es completa", @"");
            textoAyuda.text = NSLocalizedString(@"El lápiz muestra todas las actividades disponibles en tus fechas de visita.", @"");
            imagenAyuda.image = [UIImage imageNamed:@"captura3.jpg"];
            break;
        case 3:
            tituloAyuda.text = NSLocalizedString(@"Incluye o descarta actividades", @"");
            textoAyuda.text = NSLocalizedString(@"Arrastra la celda y selecciona tu opción.", @"");
            imagenAyuda.image = [UIImage imageNamed:@"captura4.jpg"];
            break;
        case 4:
            tituloAyuda.text = NSLocalizedString(@"Personalizado", @"");
            textoAyuda.text = NSLocalizedString(@"Ajusta tu perfil de intereses para obtener rutas a tu medida.", @"");
            imagenAyuda.image = [UIImage imageNamed:@"captura5.jpg"];
            break;
        case 5:
            tituloAyuda.text = NSLocalizedString(@"Descubre nuevos destinos",@"");
            textoAyuda.text = NSLocalizedString(@"Aquí podrás investigar sobre todas las ciudades disponibles y ayudarte a elegir un destino para tu próximo viaje.", @"");
            imagenAyuda.image = [UIImage imageNamed:@"captura6.jpg"];
            break;
    }
}

@end