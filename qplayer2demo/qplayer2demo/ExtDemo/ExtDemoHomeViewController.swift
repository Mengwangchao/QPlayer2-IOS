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


class ExtDemoHomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    var config : CommonPlayerConfig<Any, myIlogic, CommonPlayableParams, CommonVideoParams>!
    var mPlayerDataSource : CommonPlayerDataSource<CommonPlayableParams,CommonVideoParams>!
    var mCommonPlayer : CommonPlayer<Any, myIlogic, CommonPlayableParams, CommonVideoParams>!
    var flag : Int!
    var fullButton : QNButtonView!
    var nextVideoButton : QNButtonView!
    var rePlayButton : QNButtonView!
    var firstVideoButton : QNButtonView!
    var playerView : UIView!
    var playerConfigArray : Array<QNClassModel>!
    var playerModels : Array<QMediaModel>!
    var urlTableView : UITableView!
    var selectedIndex : Int!
    var forceNetwork : Bool!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playerConfigArray = QDataHandle.shareInstance().playerConfigArray;
        self.setUrlArray()
//        var s = PlayerControlPanelContainer<myIlogic, CommonPlayableParams, CommonVideoParams>()
//        s.show()
        self.playerView = UIView(frame: CGRect(x: 0, y: 50, width:  UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width*9/16))
        self.view.addSubview(self.playerView)
        self.view.backgroundColor = .white
        self.setButtonView()
        self.mPlayerDataSource = self.createCommonPlayerDataSource()
        flag = 1
            
        self.setUpPlayer(models: self.playerConfigArray)
        self.mCommonPlayer = CommonPlayer(playerConfig: self.config)
        var videoArray = self.mPlayerDataSource.getVideoParamsList()
        var video = videoArray[0]
        if video != nil{
            self.mCommonPlayer.playerVideoSwitcher.switchVideo(id: video.id, params: nil)
        }
        
        self.setTableView()
        
    }
    func setButtonView(){
        
        self.fullButton = QNButtonView(frame: CGRect(x: 100, y: self.playerView.frame.size.height + self.playerView.frame.origin.y + 10, width: 70, height: 30), title: "全屏", target: self, action: #selector(fullButtonClick))
        self.view.addSubview(self.fullButton)
        self.nextVideoButton = QNButtonView(frame: CGRect(x: 100, y: 140, width: 70, height: 30), title: "下一个", target: self, action: #selector(nextVideoButtonClick))
        self.nextVideoButton.isHidden = true
        self.view.addSubview(self.nextVideoButton)
        self.rePlayButton = QNButtonView(frame: CGRect(x: 100, y: 180, width: 70, height: 30), title: "重播", target: self, action: #selector(rePlayButtonClick))
        self.rePlayButton.isHidden = true
        self.view.addSubview(self.rePlayButton)
        self.firstVideoButton = QNButtonView(frame: CGRect(x: 100, y: 220, width: 70, height: 30), title: "第一集", target: self, action: #selector(firstVideoButtonClick))
        self.firstVideoButton.isHidden = true
        self.view.addSubview(self.firstVideoButton)
    }
    @objc func rePlayButtonClick(sender: UIButton){
        self.mCommonPlayer.playerVideoSwitcher.replayCurrentVideo()
    }
    @objc func firstVideoButtonClick(sender :UIButton){
        self.mCommonPlayer.playerVideoSwitcher.switchFirstVideo()
    }
    @objc func nextVideoButtonClick(sender:UIButton){
        if self.mCommonPlayer.playerVideoSwitcher.hasNextVideo(){
            
            self.mCommonPlayer.playerVideoSwitcher.switchNextVideo()
        }else{
            var label = UILabel(frame: CGRectMake(UIScreen.main.bounds.width/2-75, UIScreen.main.bounds.height/2-15, 150 , 30))
            label.backgroundColor = UIColor.gray
            label.text = "没有下一个了"
            self.view.addSubview(label)
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                label.removeFromSuperview()
            }
//            var timer = Timer(timeInterval: 2, repeats: false) { _ in
//                label.removeFromSuperview()
//            }
        }
    }
    func setUpPlayer(models:Array<QNClassModel>){
        var service = Set<String>()
        do{
            var controlfig = ControlPanelConfig("name", Array())
            let builder = try CommonPlayerConfig<Any, myIlogic, CommonPlayableParams, CommonVideoParams>.CommonPlayerCoreConfig.Builder().setPlayerDataSource(playerDataSource: self.mPlayerDataSource)
                .addEnviroment(name: "sas", enviroment: QNExtICommonPlayerEnvironment(name: "safas", serviceTypes: service))
                .setRootUIContanier(rootContainer: self.playerView)
                .addControlPanel(controlContainerConfig: controlfig)
                .enableScreenRender()
            var configs = Array<QNClassModel>()
            
            if (!models.isEmpty){
                let userdafault = UserDefaults.standard
                let dataArray : Array<Data> = userdafault.object(forKey: "PLPlayer_settings") as! Array<Data>
                if !dataArray.isEmpty{
                    for data : Data in dataArray{
                        let classModel : QNClassModel = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! QNClassModel
                        configs.append(classModel)
                    }
                }
                
            }
            else
            {
                configs = models
            }
            for model : QNClassModel in configs{
                for configModel : PLConfigureModel in model.classValue{
                    if model.classKey == "PLPlayerOption"{
                        self.configurePlayerWithConfigureModel(configureModel: configModel, classModel: model, builder: builder)
                    }
                }
            }
            self.config = try builder.build()
        }catch{
            
        }
        
    }
    func configurePlayerWithConfigureModel(configureModel : PLConfigureModel , classModel : QNClassModel , builder : CommonPlayerConfig<Any, myIlogic, CommonPlayableParams, CommonVideoParams>.CommonPlayerCoreConfig.Builder){
        
        let myIndex : Int = configureModel.selectedNum.intValue
        
        if classModel.classKey == "PLPlayerOption"{
            if configureModel.configuraKey.contains("播放速度"){
                let speed : String = configureModel.configuraValue[myIndex] as! String
                builder.setSpeed(speed: Float(speed)!)
            }
            if configureModel.configuraKey.contains("播放起始"){
                
            }else if configureModel.configuraKey.contains("Decoder"){
                builder.setDecodeType(type: QPlayerDecoder(rawValue: myIndex)!)
            }else if configureModel.configuraKey.contains("Seek"){
                builder.setSeekMode(mode: QPlayerSeek(rawValue: myIndex)!)
            }else if configureModel.configuraKey.contains("Start Action"){
                builder.setStartAction(action: QPlayerStart(rawValue: myIndex)!)
            }else if configureModel.configuraKey.contains("Render ratio"){
                builder.setRenderRatio(ratio: QPlayerRenderRatio(rawValue: myIndex + 1)!)
            }else if configureModel.configuraKey.contains("色盲模式"){
                builder.setBlindType(type: QPlayerBlind(rawValue: myIndex)!)
            }else if configureModel.configuraKey.contains("SEI"){
                if myIndex == 0 {
                    builder.setSEIEnable(enable: true)
                }else
                {
                    builder .setSEIEnable(enable: false)
                }
            }else if configureModel.configuraKey.contains("鉴权"){
                if myIndex == 0{
                    builder.setForceAuthenticationFromNetwork(true)
                }
                else
                {
                    builder.setForceAuthenticationFromNetwork(false)
                }
                
            }else if configureModel.configuraKey.contains("后台播放"){
                if myIndex == 0{
                    builder.setBackgroundPlay(true)
                }else{
                    builder.setBackgroundPlay(false)
                }
            }else if configureModel.configuraKey.contains("清晰度切换"){
                print("清晰度切换")
            }
        }
        
    }
    func setTableView(){
        self.urlTableView = UITableView(frame: CGRect(x: 0, y: self.playerView.frame.height + 200, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.playerView.frame.height - 200))
        self.urlTableView.backgroundColor = .white
        self.urlTableView.delegate = self
        self.urlTableView.dataSource = self
        self.urlTableView.register(QNURLListTableViewCell.self, forCellReuseIdentifier: "listCell")
        self.view.addSubview(self.urlTableView)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playerModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell :QNURLListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! QNURLListTableViewCell
        cell.configureListURLString(self.playerModels[indexPath.row].streamElements[0].url, index: indexPath.row)
        cell.deleteButton.tag = 100 + indexPath.row;
        cell.deleteButton.isHidden = true
        if indexPath.row == self.selectedIndex{
            cell.urlLabel.textColor = .init(red: 69/255.0, green: 169/255.0, blue: 195/255.0, alpha: 1.0)
            cell.urlLabel.font = .systemFont(ofSize: 14)
        }
        else{
            cell.urlLabel.textColor = .black
            cell.urlLabel.font = .systemFont(ofSize: 13)
        }
        cell.selectionStyle = .none
        return cell;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return QNURLListTableViewCell.configureListCellHeight(withURLString: self.playerModels[indexPath.row].streamElements[0].url, index: indexPath.row)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedIndex = indexPath.row;
        let selectedUrl = URL(string: self.playerModels[indexPath.row].streamElements[0].url)!
        if self.mCommonPlayer.mPlayerCore.playerContext.controlHandler.currentPlayerState == .QPLAYER_STATE_PLAYING{
            self.mCommonPlayer.mPlayerCore.playerContext.controlHandler.pauseRender()
        }
        self.selectedIndex = indexPath.row
        self.urlTableView .reloadData()
        let model = self.playerModels[indexPath.row]

        if QDataHandle.shareInstance().getAuthenticationState(){
            self.mCommonPlayer.mPlayerCore.playerContext.controlHandler.forceAuthenticationFromNetwork()
        }
        self.mCommonPlayer.playerVideoSwitcher.switchVideo(id: Int64(indexPath.row))
        self.judgeWeatherIsLive(url: selectedUrl)
    }
    
    func judgeWeatherIsLive(url: URL) {
        let scheme : String = url.scheme ?? ""
        let pathExtension :String = url.pathExtension
        var isLive : Bool
        if (scheme == "rtmp" && pathExtension != "pili") || (scheme  == "http" && pathExtension == "flv" ) {
            isLive = true
        }else
        {
            isLive = false
        }
        self.updateSegmentAndInfomation(isLive: isLive)
    }
    func updateSegmentAndInfomation(isLive: Bool) {
        self.urlTableView.removeFromSuperview()
        self.setTableView()
    }

    func setUrlArray(){
        let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        var path = documentsDir?.appending("urls.json")
        var data = NSData(contentsOfFile: path ?? "") ?? nil
        
        if (data == nil) {
            path = Bundle.main.path(forResource: "urls", ofType: "json")
//            data = Data(contentsOf: .init(string: path)!)
            data = NSData(contentsOfFile: path ?? "") ?? nil
        }
        let urlArray = try? JSONSerialization.jsonObject(with: data! as Data , options: .mutableContainers)
        
        self.playerModels = Array<QMediaModel>()
        for dic : Dictionary<String,Any> in urlArray as! Array{
            let isLive : Bool = dic["isLive"] as! Int == 0 ? false : true
            let builder : QMediaModelBuilder = QMediaModelBuilder(isLive: isLive)
            var streams = Array<QStreamElement>()
            for elDic : Dictionary<String,Any> in dic["streamElements"] as! Array{
                let subModel : QStreamElement = QStreamElement()
                subModel.setValuesForKeys(elDic)
                streams.append(subModel)
            }
            builder.add(streams)
            let model = builder.build()
            self.playerModels.append(model)
        }

    }
    @objc func fullButtonClick(sender:UIButton){
        sender.isSelected = !sender.isSelected

        self.urlTableView.isHidden = sender.isSelected
        self.forceOrientationLandscape(isLandscape: sender.isSelected)
    }
    @objc func forceOrientationLandscape(isLandscape:Bool){
        let appDelegate  = UIApplication.shared.delegate as! QNAppDelegate
//        QNAppDelegate *appDelegate = (QNAppDelegate *)[UIApplication4
        appDelegate.isFlip = isLandscape;
        if UIDevice.current.orientation == .unknown{
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        appDelegate.application(UIApplication.shared, supportedInterfaceOrientationsFor: self.view.window)
        if #available(iOS 16.0,*) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
            guard let windowScene = view.window?.windowScene else{
                return
            }
            let orientation = isLandscape ? UIInterfaceOrientationMask.landscape : UIInterfaceOrientationMask.portrait
            let geometryOreferencesIOS = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientation)
            windowScene.requestGeometryUpdate(geometryOreferencesIOS){ error in
                print("转屏出错")
            }
            self.orientationLandscapeForUI(isLandscape: isLandscape)
        }
        else{
            UIViewController.attemptRotationToDeviceOrientation()
            if (isLandscape) {
                if UIDevice.current.orientation != .landscapeLeft{
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight, forKey: "orientation")
                }else{
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft, forKey: "orientation")
                }
            } else {
                
                UIDevice.current.setValue(UIInterfaceOrientation.portrait, forKey: "orientation")
            }
            
            self.orientationLandscapeForUI(isLandscape: isLandscape)
        }
    }
    func orientationLandscapeForUI(isLandscape:Bool){
        if isLandscape {
            self.fullButton.frame = CGRect(x: 100, y: 100, width: 70, height: 30)
            self.nextVideoButton.isHidden = false
            self.rePlayButton.isHidden = false
            self.firstVideoButton.isHidden = false
            self.playerView.frame = CGRect(x: 0, y:0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        }
        else{
            
            self.playerView.frame = CGRect(x: 0, y: 50, width:  UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.height*9/16)
            self.nextVideoButton.isHidden = true
            self.rePlayButton.isHidden = true
            self.firstVideoButton.isHidden = true
            
            self.fullButton.frame = CGRect(x: 100, y: self.playerView.frame.height + self.playerView.frame.origin.y + 10, width: 70, height: 30)
        }
    }
    func createCommonPlayerDataSource() -> CommonPlayerDataSource<CommonPlayableParams,CommonVideoParams>{
        let dataSourceBuilder = CommonPlayerDataSource.DataSourceBuilder<CommonPlayableParams,CommonVideoParams>()
        for (modelIndex,item) in self.playerModels.enumerated(){
            var longVideoArray = Array<CommonPlayableParams>()
            let videoParams = CommonVideoParams(id: Int64(modelIndex))
            longVideoArray.append(CommonPlayableParams(mediaModel: item, controlPanelType: "longVideo", displayOrientation: .LANDSCAPE, environmentType: "longVideo", startPos: 0))
            dataSourceBuilder.addVideo(videoParams: videoParams, playableParamsArray: longVideoArray)
        }
        
        let dataSource = dataSourceBuilder.build()
        
        return dataSource
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



