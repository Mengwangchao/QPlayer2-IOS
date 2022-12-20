//
//  QNExtICommonPlayerEnvironment.swift
//  qplayer2demo
//
//  Created by Dynasty Dream on 2022/12/15.
//

import Foundation
import qplayer2_ext
class QNExtICommonPlayerEnvironment:ICommonPlayerEnvironment{
 
    var name: String
    
    var serviceTypes: Set<String>
    public init(name : String,serviceTypes: Set<String>){
        self.name = name
        self.serviceTypes = serviceTypes
        
    }
    
    func start() {
        
    }
    
    func stop() {
        
    }
    
    func authentication<T3, T4>(playableParams: T3, videoParams: T4?) -> Bool where T3 : CommonPlayableParams, T4 : CommonVideoParams {
        return true
    }
    
    func bindPlayerCore<T1, T2, T3, T4>(playerCore: CommonPlayerCore<T1, T2, T3, T4>) where T2 : ILogicProvider, T3 : CommonPlayableParams, T4 : CommonVideoParams {
        
    }
    
    
}
