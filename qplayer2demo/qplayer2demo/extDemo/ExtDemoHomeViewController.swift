//
//  ExtDemoHomeViewController.swift
//  qplayer2demo
//
//  Created by 王声禄 on 2022/9/21.
//

import UIKit
import qplayer2_ext
import qplayer2_core
import AVFAudio
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
    var config : CommonPlayerConfig<Any, myIlogic, CommonPlayableParams, CommonVideoParams>!
    var mPlayerDataSource : CommonPlayerDataSource<CommonPlayableParams,CommonVideoParams>!
    var mCommonPlayer : CommonPlayer<Any, myIlogic, CommonPlayableParams, CommonVideoParams>!
    var flag : Int!
    override func viewDidLoad() {
        super.viewDidLoad()
//        var s = PlayerControlPanelContainer<myIlogic, CommonPlayableParams, CommonVideoParams>()
//        s.show()
        var view = UIView(frame: CGRect(x: 10, y: 100, width: 300, height: 150))
//        view.backgroundColor = UIColor.blue
        self.view.addSubview(view)
        self.mPlayerDataSource = self.createCommonPlayerDataSource()
        flag = 1
        do{
            var service = Set<String>()
            self.config = try CommonPlayerConfig<Any, myIlogic, CommonPlayableParams, CommonVideoParams>.CommonPlayerCoreConfig.Builder()
                .setPlayerDataSource(playerDataSource: self.mPlayerDataSource)
                .addEnviroment(name: "sas", enviroment: myICommonPlayerEnvironment(name: "safas", serviceTypes: service))
                .setRootUIContanier(rootContainer: view)
                .enableScreenRender()
                .build()
            self.mCommonPlayer = CommonPlayer(playerConfig: config)
            var videoArray = self.mPlayerDataSource.getVideoParamsList()
            var video = videoArray[0]
            if video != nil{
                self.mCommonPlayer.playerVideoSwitcher.switchVideo(id: video.id, params: nil)
            }
            var time = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timeAction), userInfo: nil, repeats: true)
        }catch{
            
        }

        
        var dic = ["1":1,"2":2,"3":3]
        var arr = [1,2,3,4,5,6]
        
    }
    @objc func timeAction(){
        var videoArray = self.mPlayerDataSource.getVideoParamsList()
        var video = videoArray[0]
        var param = self.mPlayerDataSource.getPlayableParams(videoId: video.id, index: 1)
        if param != nil && flag == 1{
            self.mCommonPlayer.playerVideoSwitcher.switchPlayableParamsSubject(playableParams: param!)
            flag+=1
        }
        else{
            video = videoArray[1]
            self.mCommonPlayer.playerVideoSwitcher.switchVideo(id: video.id, params: nil)
        }
    }
    func createCommonPlayerDataSource() -> CommonPlayerDataSource<CommonPlayableParams,CommonVideoParams>{
        var longVideo : CommonPlayerDataSource<CommonPlayableParams,CommonVideoParams>
        var dataSourceBuilder = CommonPlayerDataSource.DataSourceBuilder<CommonPlayableParams,CommonVideoParams>()
        var videoParams  = CommonVideoParams(id: 1)
        var builder = QMediaModel(false)
        builder.addStreamElements("", urlType: QPlayerURLType.QURL_TYPE_QAUDIO_AND_VIDEO, url: "http://demo-videos.qnsdk.com/qiniu-1080p.mp4", quality: 1080, isSelected: true, backupUrl: "", referer: "", renderType: QPlayerRenderType.QPLAYER_RENDER_TYPE_PLANE)
        var builder2 = QMediaModel(false)
        builder2.addStreamElements("", urlType: QPlayerURLType.QURL_TYPE_QAUDIO_AND_VIDEO, url: "http://demo-videos.qnsdk.com/shortvideo/nike.mp4", quality: 1080, isSelected: true, backupUrl: "", referer: "", renderType: QPlayerRenderType.QPLAYER_RENDER_TYPE_PLANE)
        var longViedArray = Array<CommonPlayableParams>()
        
        longViedArray.append(CommonPlayableParams(mediaModel: builder, controlPanelType: "builder", displayOrientation: DisplayOrientation.LANDSCAPE, environmentType: "builder", startPos: 0))
        longViedArray.append(CommonPlayableParams(mediaModel: builder2, controlPanelType: "builder2", displayOrientation: DisplayOrientation.LANDSCAPE, environmentType: "builder2", startPos: 0))
        
        
        var videoParams2 = CommonVideoParams(id: 2)
        var videoParams2Playable = QMediaModel(false)
        videoParams2Playable.addStreamElements("", urlType: QPlayerURLType.QURL_TYPE_QAUDIO_AND_VIDEO, url: "http://demo-videos.qnsdk.com/bbk-bt709.mp4", quality: 1080, isSelected: true, backupUrl: "", referer: "", renderType: QPlayerRenderType.QPLAYER_RENDER_TYPE_PLANE)
        
        var videoParams2PlayableArray = Array<CommonPlayableParams>()
        videoParams2PlayableArray.append(CommonPlayableParams(mediaModel: videoParams2Playable, controlPanelType: "videoParams2Playable", displayOrientation: DisplayOrientation.LANDSCAPE, environmentType: "videoParams2Playable", startPos: 0))
        dataSourceBuilder.addVideo(videoParams: videoParams, playableParamsArray: longViedArray)
        dataSourceBuilder.addVideo(videoParams: videoParams2, playableParamsArray: videoParams2PlayableArray)
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

