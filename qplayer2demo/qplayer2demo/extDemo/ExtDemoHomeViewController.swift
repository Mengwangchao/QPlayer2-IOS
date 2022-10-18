//
//  ExtDemoHomeViewController.swift
//  qplayer2demo
//
//  Created by 王声禄 on 2022/9/21.
//

import UIKit
import qplayer2_ext
import qplayer2_core
class myIlogic:ILogicProvider{
    
}
class myICommonPlayerScreenChangedListener:ICommonPlayerScreenChangedListener{
    public init(){
        
    }
    func onScreenTypeChanged(screenType: ScreenType) {
        
    }
}
class myICommonPlayerEnvironment:ICommonPlayerEnvironment{

    
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
class ExtDemoHomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        var s = PlayerControlPanelContainer<myIlogic, CommonPlayableParams, CommonVideoParams>()
//        s.show()
        var view = UIView(frame: CGRect(x: 100, y: 100, width: 300, height: 150))
        view.backgroundColor = UIColor.blue
        self.view.addSubview(view)
        var mPlayerDataSource = self.createCommonPlayerDataSource()
        
        do{
            var service = Set<String>()
            var config = try CommonPlayerConfig<Any, myIlogic, CommonPlayableParams, CommonVideoParams>.CommonPlayerCoreConfig.Builder()
                .setPlayerDataSource(playerDataSource: mPlayerDataSource)
                .addEnviroment(name: "sas", enviroment: myICommonPlayerEnvironment(name: "safas", serviceTypes: service))
                .setRootUIContanier(rootContainer: view)
                .enableScreenRender()
                .build()
            var mCommonPlayer = CommonPlayer(playerConfig: config)
            var video = mPlayerDataSource.getVideoParamsList()[0]
            if video != nil{
                mCommonPlayer.playerVideoSwitcher.switchVideo(id: video.id, params: nil)
            }
        }catch{
            
        }
        

        
        var dic = ["1":1,"2":2,"3":3]
        var arr = [1,2,3,4,5,6]
        
    }
    func createCommonPlayerDataSource() -> CommonPlayerDataSource<CommonPlayableParams,CommonVideoParams>{
        var longVideo : CommonPlayerDataSource<CommonPlayableParams,CommonVideoParams>
        var dataSourceBuilder = CommonPlayerDataSource.DataSourceBuilder<CommonPlayableParams,CommonVideoParams>()
        var videoParams  = CommonVideoParams(id: 1)
        var builder = QMediaModel(false)
        builder.addStreamElements("", urlType: QPlayerURLType.QURL_TYPE_QAUDIO_AND_VIDEO, url: "http://demo-videos.qnsdk.com/qiniu-1080p.mp4", quality: 1080, isSelected: true, backupUrl: "", referer: "", renderType: QPlayerRenderType.QPLAYER_RENDER_TYPE_PLANE)
        var longViedArray : Array<CommonPlayableParams> = [CommonPlayableParams(mediaModel: builder, controlPanelType: "sss", displayOrientation: DisplayOrientation.LANDSCAPE, environmentType: "321", startPos: 0)]
        
        dataSourceBuilder.addVideo(videoParams: videoParams, playableParamsArray: longViedArray)
        return dataSourceBuilder.build()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class mf : NSObject , ICommonVideoPlayEventListener{
    func onVideoParamsStart<T4>(videoParams: T4) where T4 : CommonVideoParams {
        
    }
    
    func onPlayableParamsStart<T3, T4>(playableParams: T3, videoParams: T4) where T3 : CommonPlayableParams, T4 : CommonVideoParams {
        
    }
    
    func onPlayableParamsWillChange<T3, T4>(oldPlayableParams: T3?, oldVideoParams: T4?, newPlayableParams: T3, newVideoParams: T4, switchVideoParams: Dictionary<String, Any>?) where T3 : CommonPlayableParams, T4 : CommonVideoParams {
        
    }
    
    func onVideoParamsWillChange<T4>(oldVideoParams: T4?, newVideoParams: T4, switchVideoParams: Dictionary<String, Any>?) where T4 : CommonVideoParams {
        
    }
    
    func onPlayableParamsCompleted<T3, T4>(playableParams: T3, videoParams: T4) where T3 : CommonPlayableParams, T4 : CommonVideoParams {
        
    }
    
    func onVideoParamsCompleted<T4>(videoParams: T4) where T4 : CommonVideoParams {
        
    }
    
    func onAllVideoParamsCompleted() {
        
    }
    
    func onVideoParamsSetChanged() {
        
    }
    
    
}
class lis :NSObject, switchListener{
    func switchVideoIdSubject(videoId: Dictionary<Int64, Dictionary<String, Any>?>) {
        
    }
    
    func switchPlayableParamsSubject<T3>(playableParams: T3) where T3 : CommonPlayableParams {
        
    }
    
    
}
