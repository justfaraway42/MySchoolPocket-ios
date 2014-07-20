//
//  TrainingDelegate.h
//  Workouts
//
//  Created by Justus Dög on 15.11.11.
//  Copyright (c) 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NewsParserDelegate
// Dies ist ein selbstgeschriebenes Protokoll für ein Delegate
// PROTOKOLL ist eine Vereinbarung, damit sich zwei Objekte korrekt miteinander austauschen können
@required
// Klassen, die das Protokoll implementieren wollen, MÜSSEN die nachfolgende Methode implementieren
- (void)endParsing;

@optional

- (void)endParsingWithError:(NSError *)error;

// GEGENSTÜCK: @optional (diese Methoden KÖNNEN genutzt werden)

@end
