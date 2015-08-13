//
//  ActorSystemMock.h
//  Actors
//
//  Created by Anastasiya Gorban on 8/11/15.
//  Copyright (c) 2015 Techery. All rights reserved.
//

#import "DTActorSystem.h"
#import "Kiwi.h"

extern DTMainActorSystem * actorSystemMock();

DTMainActorSystem * actorSystemMock() {
    DTMainActorSystem *actorSystem = [DTMainActorSystem mock];
    
    [actorSystem stub:@selector(configs) andReturn:[KWMock mockForProtocol:@protocol(Configs)]];
    [actorSystem stub:@selector(serviceLocator) andReturn:[[ServiceLocator alloc] initWithBuilder:^(ServiceLocator *locator) {
        
    }]];

    return actorSystem;
}