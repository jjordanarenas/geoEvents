//
//  ParseAnimal.m
//  GoldRush
//
//  Created by Jorge Jordán Arenas on 04/11/11.
//  Copyright (c) 2011 InsanePlatypusGames. All rights reserved.
//

#import "ParseAnimal.h"

@implementation ParseAnimal

-(Animal*)parseAnimal:(NSString *)xml{
    
	animalRet = [[[Animal alloc] init] autorelease];
    
	
	NSData* data=[xml dataUsingEncoding:NSUTF8StringEncoding];
    	
	revParser = [[NSXMLParser alloc] initWithData:data];
	
	[revParser setDelegate:self];
	[revParser setShouldProcessNamespaces:NO];
	[revParser setShouldReportNamespacePrefixes:NO];
	[revParser setShouldResolveExternalEntities:NO];
	[revParser parse]; 
    
	[revParser release];
	
	return animalRet; 
    
}

-(NSMutableArray*)parseAnimalWithData:(NSMutableData *)data{
    
    arrayAnimals = [[NSMutableArray alloc] init];
    
	//animalRet = [[[Animal alloc] init] autorelease];
    
	
	//NSData* data=[xml dataUsingEncoding:NSUTF8StringEncoding];
   
	revParser = [[NSXMLParser alloc] initWithData:data];
    
	[revParser setDelegate:self];
	[revParser setShouldProcessNamespaces:NO];
	[revParser setShouldReportNamespacePrefixes:NO];
	[revParser setShouldResolveExternalEntities:NO];
	[revParser parse]; 
    
	[revParser release];
	
	return arrayAnimals; 
    
}

- (void) parser: (NSXMLParser *) parser parseErrorOccurred: (NSError *) parseError {
	NSLog(@"Error Parser:%@",[parseError localizedDescription]);
}

- (void) parser: (NSXMLParser *) parser didStartElement: (NSString *) elementName
   namespaceURI: (NSString *) namespaceURI
  qualifiedName: (NSString *) qName
     attributes: (NSDictionary *) attributeDict{
	
    if ([elementName isEqualToString:@"ax21:city"]) {
		animalRet = [[[Animal alloc] init] autorelease];
        
	}
        
	/*if ([elementName isEqualToString:@"ax21:city"]) {
        NSLog(@"ax21.city :%@",[attributeDict objectForKey:@"ax21:city"]);
        NSLog(@"city :%@",[attributeDict objectForKey:@"city"]);
        
        NSLog(@"elementName :%@", elementName);
        NSLog(@"attributes :%@", attributeDict);
		animalRet.city = [attributeDict objectForKey:@"city"];
        
	}
    
    if ([elementName isEqualToString:@"ax21:type"]) {
		animalRet.type = [attributeDict objectForKey:@"type"];

	}*/
    
	/*if ([elementName isEqualToString:@"friends"])
	{
		NSMutableArray *tmpArr = [[NSMutableArray alloc] init];
		userRet.arrFriends = tmpArr;
		[tmpArr release];
	}*/
    
	
}

- (void) parser: (NSXMLParser *) parser didEndElement: (NSString *) elementName
   namespaceURI: (NSString *) namespaceURI
  qualifiedName: (NSString *) qName{  
	
   /* NSString *city = [[[NSString alloc] init] autorelease]; 
    NSString *clue = [[[NSString alloc] init] autorelease]; 
    NSString *idAnimal = [[[NSString alloc] init] autorelease]; 
    NSString *image = [[[NSString alloc] init] autorelease]; 
    NSString *latitude = [[[NSString alloc] init] autorelease]; 
    NSString *longitude = [[[NSString alloc] init] autorelease]; 
    NSString *type = [[[NSString alloc] init] autorelease]; 
   */ 
    if ([elementName isEqualToString:@"ax21:city"]) {
     
		animalRet.city = currentElement;
        //city = currentElement;
	}
    

    if ([elementName isEqualToString:@"ax21:clue"]) {
        
		//animalRet.clue = currentElement;
        //clue = currentElement;
	}
    
    if ([elementName isEqualToString:@"ax21:id"]) {
        
		//animalRet.idAnimal = currentElement;
        //idAnimal = currentElement;
	}
    
    if ([elementName isEqualToString:@"ax21:image"]) {
        
		animalRet.image = currentElement;
        //image = currentElement;
	}
    
    if ([elementName isEqualToString:@"ax21:latitude"]) {
        
		animalRet.latitude = currentElement;
        //latitude = currentElement;
	}
    if ([elementName isEqualToString:@"ax21:longitude"]) {
        
		animalRet.longitude = currentElement;
        //longitude = currentElement;
    }
    
    if ([elementName isEqualToString:@"ax21:type"]) {
		
        animalRet.type = currentElement;
        //type = currentElement;
        
       // animalRet = [[[Animal alloc] initWithType:type longitude:longitude latitude:latitude city:city image:image clue:clue idAnimal:idAnimal] autorelease];
        [arrayAnimals addObject:animalRet];
	}

    
   /* if ([elementName isEqualToString:@"password_md5"]) {
        userRet.password_md5 = currentElement;
    } else if ([elementName isEqualToString:@"numPost"]) {
        userRet.numPost = [currentElement intValue];
    }else if ([elementName isEqualToString:@"banned"]) {
        userRet.banned = [currentElement boolValue];
    }
    
    
    if ([elementName isEqualToString:@"friend"]) {
        [userRet.arrFriends addObject:currentElement];
    }
    */
    
    [currentElement release];
    currentElement = nil;
	
}

- (void) parser: (NSXMLParser *) parser foundCharacters: (NSString *) string{
    
	if(!currentElement)
		currentElement = [[NSMutableString alloc] initWithString:string];
	else{
		[currentElement appendString:string];
        
    }
   
}


@end
