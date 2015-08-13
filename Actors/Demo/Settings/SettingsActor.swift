//
//  SettingsActor.swift
//  Actors
//
//  Created by Anastasiya Gorban on 8/5/15.
//  Copyright (c) 2015 Techery. All rights reserved.
//

class GetSettings:NSObject {}

class SettingsActor: DActor {
    let apiActor: DTActorRef
    let mappingActor: DTActorRef
    let settingsStorage: SettingsStorage?
    
    override init!(actorSystem: DTActorSystem!) {
        apiActor = actorSystem.actorOfClass(APIActor)!
        mappingActor = actorSystem.actorOfClass(MappingActor)!
        settingsStorage = actorSystem.serviceLocator.service()
        super.init(actorSystem: actorSystem)
    }
    
    override func setup() {
        on { (msg: GetSettings) -> RXPromise in
            let settingsURL = self.configs[TripsConfigs.Keys.settingsURL] as! String
            let settings = self.apiActor.ask(APIActor.Get(path: settingsURL))
            let mapSettings = settings.then({result in
                if let payload = result as? String {
                    return self.mappingActor.ask(MappingActor.MappingRequest(payload: payload, resultType: Settings.self))
                } else {
                    return nil
                }
            }, nil)
            
            let storeSettings = mapSettings.then({result in
                let promise = RXPromise()
                if let s = result as? Settings {
                    if let storage = self.settingsStorage {
                        storage.settings = s
                        promise.resolveWithResult(s)
                    }
                }
                
                promise.rejectWithReason("Failed to store settings")
                return promise
            }, nil)
            
            return storeSettings
        }
    }
}
