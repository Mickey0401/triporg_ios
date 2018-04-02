//
//  TZUser.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZMappedObject.h"

@interface TZUser : TZMappedObject

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *uk;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *surname;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSNumber *country;
@property (nonatomic, copy) NSNumber *region;
@property (nonatomic, copy) NSNumber *city;
@property (nonatomic, copy) NSString *birthdate;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSData *downloadedImage;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSNumber *value;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSNumber *isAutomatic;

// API 1
@property (nonatomic, copy) NSNumber *user_id;
@property (nonatomic, copy) NSString *nombre;
@property (nonatomic, copy) NSNumber *sexo_id;
@property (nonatomic, copy) NSString *imagen_perfil_base64;

@property (nonatomic, copy) NSString *edificios_y_monumentos;
@property (nonatomic, copy) NSString *cultura_y_actividades_educativas;
@property (nonatomic, copy) NSString *entretenimiento_y_ocio;
@property (nonatomic, copy) NSString *gastronomia;
@property (nonatomic, copy) NSString *naturaleza_y_paisajes;
@property (nonatomic, copy) NSString *fiestas_populares_y_festivales;
@property (nonatomic, copy) NSString *deporte;
@property (nonatomic, copy) NSString *ferias_y_conferencias;
@property (nonatomic, copy) NSString *otros;

@end
