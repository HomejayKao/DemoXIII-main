//
//  HomeViewController.swift
//  DemoX
//
//  Created by homejay on 2021/2/15.
//

import UIKit
import AVKit
import MediaPlayer
import AVFoundation
import Lottie


class HomeViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var trailingConstraint: NSLayoutConstraint!
    
    var sideMenuIsOpening:Bool = false {
        didSet {
            switch sideMenuIsOpening {
            case true:
                trailingConstraint.constant = 0 // 向右移動 (-240 ——＞ 0)
            default:
                trailingConstraint.constant = -240
            }
            updateMenuViewShadow()
        }
    }
    
    
    //@IBOutlet weak var circleAnimationView: AnimationView! //用outlet的方式會出現紅色錯誤，但仍能使用
    var circleAnimationView:AnimationView!
    @IBOutlet var plusButton: UIButton!
    
    @IBOutlet var playerButtons: [UIButton]!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    var playerLoop:AVPlayerLooper?
    var playerItem:AVPlayerItem?
    var queuePlayer = AVQueuePlayer()
    let playerItemUrl = [//"MarineBGM",
                         "RushiaBGM",
                         "PekoraBGM",
                         "NoelBGM"]
    var notification:Any?
    var number = 0
    
    @IBOutlet weak var amongUsImageView: UICollectionView!
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    //var homeCollectionView:UICollectionView! //純程式用
    
    var flowLayout:UICollectionViewFlowLayout! //普通的CollectionViewFlowLayout樣式 用來設置CollectionView屬性等排版
    var galleryFlowLayout:GalleryEffectCollectionViewFlowLayout! //自定義的CollectionViewFlowLayout樣式
    
    let cellID = "GalleryEffectCollectionViewCell"
    
    var thirdImageNames = [String]()
    var thirdChannelIDs = [String]()
    var thirdPlaylistIDs = [String]()
    var thirdTwitterNames = [String]()
    var hololiveMemers = [Hololive]()
    var item = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCollectionView() //初始化Collection View
        
        //註冊tap點擊事件
        let tapRecognizer = UITapGestureRecognizer(target: self,action: #selector(self.handleTap(_:)))
        homeCollectionView.addGestureRecognizer(tapRecognizer)
        
        //建立資料
        thirdImageNames = Hololive.returnThirdImageNameArray()
        thirdChannelIDs = Hololive.returnThirdChannel_ID()
        thirdPlaylistIDs = Hololive.returnThirdPlaylist_ID()
        thirdTwitterNames = Hololive.returnThirdTwitterName()
        hololiveMemers = Hololive.makeHololiveList(imageNames: thirdImageNames,
                                                   channels: thirdChannelIDs,
                                                   playlists: thirdPlaylistIDs,
                                                   twitterNames: thirdTwitterNames)
        
        playVideo()
        
        //buttonsTouchUp(playerButtons[4])
        
        
        sideMenuIsOpening = false
        
        makeCircleAnimationView()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //隱藏 tabBar
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.alpha = 0
        //顯示 navigationBar
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.alpha = 1
    }
    
    
    //Lottie動畫
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        circleAnimationView.loopMode = .loop
        circleAnimationView.play()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        circleAnimationView.pause()
    }
    
    func makeCircleAnimationView() {
        circleAnimationView = AnimationView(name: "circle")
        view.addSubview(circleAnimationView) //要先添加進去才能調整AutoLayout
        view.sendSubviewToBack(circleAnimationView) //放到最下層
        
        circleAnimationView.translatesAutoresizingMaskIntoConstraints = false
        circleAnimationView.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor).isActive = true
        circleAnimationView.centerXAnchor.constraint(equalTo: plusButton.centerXAnchor).isActive = true
        circleAnimationView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        circleAnimationView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
    }
    
    func playVideo() {
        
        //預設初始音樂
        switchSong(arrayNumber: number)
        
        //觀察播放進度
        queuePlayer.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: DispatchQueue.main) { [weak self] (CMTime) in
            
            guard let self = self else { return }
            
            if self.queuePlayer.timeControlStatus == .playing{
                self.playerButtons[2].setTitle("⏸", for: UIControl.State.normal)
                /*
                 可替換寫成
                 let currentTime = CMTimeGetSeconds(queuePlayer.currentTime())
                 */
                let currentTime = Float64(self.queuePlayer.currentTime().seconds) //Float64 = Double
                
                self.playerSlider.value = Float(currentTime)
                
                self.minLabel.text = self.caculateTime(seconds: currentTime)
            }else{
                self.playerButtons[2].setTitle("▶️", for: UIControl.State.normal)
            }
            
        }
        
        //歌曲播放完的通知與動作
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] (Notification) in
            guard let self = self else { return }
            
            //通知中心默認加入一個觀察，觀察的事件為影片播畢時的動作
            
            switch self.playerButtons[4].currentTitle {
            case "🔂": //單曲循環，重複播放
                self.queuePlayer.removeAllItems()
                self.switchSong(arrayNumber: self.number)
                self.playerLoop = AVPlayerLooper(player: self.queuePlayer, templateItem: self.playerItem!)
            case "🔁": //結束就換下一首，循環輪播
                self.playerLoop?.disableLooping()
                if self.number < 2 {
                    self.number += 1
                }else{
                    self.number = 0
                }
                self.queuePlayer.removeAllItems()
                self.switchSong(arrayNumber: self.number)
            default:
                break
            }
        }
    }
    
    //將總秒數變成 幾分幾秒並以文字呈現
    func caculateTime(seconds: Float64) -> String {
        
        /*
         因Float64(Double)轉Int會出現NaN(Not A Number)，
         故用guard else當條件 seconds是一個數字時 為不成立，
         回傳一個空字串，後續下面的就不執行了
         */
        guard !(seconds.isNaN) else {
            print(seconds)
            print(seconds.isNaN)
            return ""
        }
        
        let time = Int(seconds)
        
        let min = Int(time / 60)
        let sec = Int(time % 60)
        
        var content = ""
        
        if min < 10 {
            content = "0\(min):"
        }else{
            content = "\(min):"
        }
        
        if sec < 10 {
            content += "0\(sec)"
        }else{
            content += "\(sec)"
        }
        
        return content
        
    }
    //變更光碟片內容
    func makePlayerItem(playItemUrl:String) {
        let url = Bundle.main.url(forResource: playItemUrl, withExtension: "mp4")!
        
        playerItem = AVPlayerItem(url: url)
        
        guard let duration = playerItem?.asset.duration else {
            print("沒有光碟 playerItem")
            return
        }//光碟的持續時間
        
        let totalSeconds = CMTimeGetSeconds(duration) //變成秒數
        
        playerSlider.minimumValue = 0
        playerSlider.maximumValue = Float(totalSeconds)
        playerSlider.isContinuous = true //想要拖動後才更新進度，那就設為 false；如果想要直接更新就設為 true
        
        maxLabel.text = caculateTime(seconds: totalSeconds)
        
    }
    
    func switchSong(arrayNumber:Int) {
        makePlayerItem(playItemUrl: playerItemUrl[arrayNumber])
        queuePlayer.replaceCurrentItem(with: playerItem)
        queuePlayer.play()
        
        playerLoop?.disableLooping() //關閉單曲循環
    }
    
    
    func playOrPause(){
        if queuePlayer.timeControlStatus == .playing{
            playerButtons[2].setTitle("▶️", for: UIControl.State.normal)
            queuePlayer.pause()
        }else{
            playerButtons[2].setTitle("⏸", for: UIControl.State.normal)
            queuePlayer.play()
        }
    }
    @IBAction func sliderChange(_ sender: UISlider) {
        
        queuePlayer.seek(to: CMTime(value: CMTimeValue(sender.value), timescale: 1))
        
        minLabel.text = caculateTime(seconds: Float64(sender.value))
    }
    
    @IBAction func buttonsTouchUp(_ sender: UIButton) {
        
        switch sender {
        case playerButtons[0]: //隨機播放
            
            //number = Int.random(in: 0...3)
            number = Int.random(in: 0...2)
            
            switchSong(arrayNumber: number)
            
        case playerButtons[1]://上一首
            
            if number > 0 {
                number -= 1
            }else{
                //number = 3
                number = 2
            }
            
            switchSong(arrayNumber: number)
            
        case playerButtons[2]://播放或暫停
            
            playOrPause()
            
        case playerButtons[3]://下一首
            
//            if number < 3 {
//                number += 1
//            }else{
//                number = 0
//            }
            
            if number < 2 {
                number += 1
            }else{
                number = 0
            }
            
            switchSong(arrayNumber: number)
            
        case playerButtons[4]://單曲循環or全部輪播
            
            if sender.currentTitle == "🔁"{
                playerButtons[4].setTitle("🔂", for: UIControl.State.normal)
            }else{
                playerButtons[4].setTitle("🔁", for: UIControl.State.normal)
            }
            
            NotificationCenter.default.removeObserver(self.notification as Any) //先移除掉之前通知中心的觀察結果
            
        default:
            break
        }
        
    }
    
    //初始化Collection View
    private func initCollectionView() {
        
        //設定CollectionView的flowLayout樣式，就是Sction與Cell的大小 間距 排列方式
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 80, height: 80) // cell的寬、高
        flowLayout.sectionInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        //section與section之間的距離(如果只有一個section，可以想像成frame)(數字太小會被NavigationBar擋住Cell)
        
        flowLayout.minimumLineSpacing = CGFloat(integerLiteral: 10)
        // 滑動方向為「垂直」的話即「上下」的間距;滑動方向為「平行」則為「左右」的間距
        flowLayout.minimumInteritemSpacing = CGFloat(integerLiteral: 0)
        // 滑動方向為「垂直」的話即「左右」的間距;滑動方向為「平行」則為「上下」的間距
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        // 滑動方向預設為垂直。注意若設為垂直，則cell的加入方式為由左至右，滿了才會換行；若是水平則由上往下，滿了才會換列
        
        //初始化Collection View並設定位置與大小，樣式先用 自定義的，這邊是以純程式碼的方式寫入
        //guard let navigationBarHeight = self.navigationController?.navigationBar.bounds.height else { return }
        //homeCollectionView = UICollectionView(frame: CGRect(x: view.bounds.origin.x, y: navigationBarHeight*2, width: view.bounds.width, height: (view.bounds.height)/3), collectionViewLayout: galleryFlowLayout)
        
        galleryFlowLayout = GalleryEffectCollectionViewFlowLayout() //初始化 自定義的CollectionViewFlowLayout樣式
        homeCollectionView.collectionViewLayout = galleryFlowLayout //設定 自定義的CollectionViewFlowLayout樣式
        
        //Collection View代理設置
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        homeCollectionView.backgroundColor = .white
        
        //純程式碼寫法，配合xib
        //註冊重複用的Cell，因為Cell要一致的關係，重複使用率高，可以在生成Cell.swift時，一起生成Cell.xib
        //let cellXIB = UINib.init(nibName: "GalleryEffectCollectionViewCell", bundle: Bundle.main)
        //homeCollectionView.register(cellXIB, forCellWithReuseIdentifier: cellID)
        
        //純程式碼寫法
        //將Collection View 加到主視圖中
        //view.addSubview(homeCollectionView)
        
    }
    
    //因為版面有滑動，沒有配合觸控手勢，會超級難觸發 點選cell事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = indexPath.item
        print(hololiveMemers[item].imageName)
        print("點到哪個hololive成員")
        
        //將資料不透過Segue 傳到指定頁面 並打開該頁面
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let playlistCVC = storyboard.instantiateViewController(identifier: "PlayListCollectionViewController")
                as? PlayListCollectionViewController else {return}
        
        playlistCVC.hololiveMemerArray = hololiveMemers
        playlistCVC.selectedItem = item
        
        present(playlistCVC, animated: true, completion: nil)
        
    }
    
    
    //會跟tap手勢 衝突到 故不會被觸發
    @IBSegueAction func showPlayListCVC(_ coder: NSCoder) -> PlayListCollectionViewController? {
        let playListCVC =  PlayListCollectionViewController(coder: coder)
        
        print("先觸發segue 才觸發didSelectItemAt")
        
        return playListCVC
    }
    
    /*
     UIGestureRecognizer 手勢識別器
     
     UITapGestureRecognizer(Tap 點擊)
     UIPinchGestureRecognizer(Pinch 縮放)
     UIRotationGestureRecognizer(Rotation 旋轉)
     UISwipeGestureRecognizer(Swipe 滑動)
     UIPanGestureRecognizer(Pan 平移)
     UIScreenEdgePanGestureRecognizer(ScreenEdgePan 螢幕邊緣平移)
     UILongPressGestureRecognizer(LongPress 長按)
     */
    
    //點擊手勢響應
    @objc func handleTap(_ sender:UITapGestureRecognizer){
        if sender.state == UIGestureRecognizer.State.ended { //手勢狀態是否結束
            let tapPoint = sender.location(in: self.homeCollectionView) //location會返回一個在collectionView內手勢結束時的位置CGPoint
            //點擊Cell
            if let  indexPath = self.homeCollectionView.indexPathForItem(at: tapPoint) {
                //indexPathForItem at 得到item在collectionView指定位置的 indexPath索引路徑
                //不同於 collectionView.indexPathsForSelectedItems 得到所選item的[indexPath]索引路徑陣列。
                
                //performBatchUpdates 執行批量更新，用於對多個插入，刪除，重新加載和移動操作進行動畫處理。
                //跟collection.reload()一樣，但變成closure 可以執行事件
                //同時該方法觸發collectionView所對應的 layout對應的動畫。
                self.homeCollectionView.performBatchUpdates({ () -> Void in
                    
                    collectionView(homeCollectionView, didSelectItemAt: indexPath) //觸發 點擊Cell事件
                    
                    
                    /* //刪除點擊的Cell
                     self.homeCollectionView.deleteItems(at: [indexPath]) //刪除 指定[indexPath]索引路徑陣列中的item。
                     self.hololiveMemers.remove(at: indexPath.item) //刪除點到的圖片
                     */
                    
                    /* //呼叫 指定的StoryBoard 與其內 指定的VC
                     let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                     
                     guard let signUpVC = storyboard.instantiateViewController(identifier: "SignUpViewController")
                     as? SignUpViewController else {return}
                     guard let itemListVC = storyboard.instantiateViewController(identifier: "ItemListCollectionViewController")
                     as? ItemListCollectionViewController else {return}
                     
                     present(signUpVC, animated: true, completion: nil)
                     present(itemListVC, animated: true, completion: nil)
                     */
                    
                }, completion: nil)
                
            }
            //點擊空白位置 要執行的事情 //例如 在開頭 新增 一筆資料
            else{
                /*
                let index = 0 //新item插入的陣列位置
                
                let newMember = Hololive(imageName: "Rusia", channel_ID: thirdChannelIDs.last!, playlist_ID: thirdPlaylistIDs.last!, twitterName: thirdTwitterNames.last!)
                hololiveMemers.insert(newMember, at: index) //在指定位置插入
                
                //在指定section與item位置的[indexPath]索引路徑陣列處 插入新item。
                self.homeCollectionView.insertItems(at: [IndexPath(item: index, section: 0)])
                */
            }
        }
    }
    
    
    //切換設定樣式
    @IBAction func changeLayout(_ sender: Any) {
        self.homeCollectionView.collectionViewLayout.invalidateLayout()//invalidate使無效
        
        //交替切换 新設置的樣式
        let newLayout = homeCollectionView.collectionViewLayout
            .isKind(of: GalleryEffectCollectionViewFlowLayout.self) ? flowLayout : galleryFlowLayout
        //這是三原運算子，if else的另一種寫法，如果？前為true，newLayout 則為flowLayout, false則為linearLayput
        
        homeCollectionView.setCollectionViewLayout(newLayout!, animated: true)
        
    }
    
    //MenuView 陰影
    func updateMenuViewShadow() {
        
        switch sideMenuIsOpening {
        case true:
            containerView.layer.shadowOpacity = 1 //陰影不透明度
            containerView.layer.shadowRadius = 6 //讓陰影更粗 更明顯
        default:
            containerView.layer.shadowOpacity = 0 //系統 預設為 0
            containerView.layer.shadowRadius = 3 //系統 預設為 3
        }
        
    }
    
    @IBAction func openSideMenu(_ sender: UIBarButtonItem) {
        
        sideMenuIsOpening.toggle()
        
        //添加動畫
        UIView.animate(withDuration: 0.3) {
            //要讓AutoLayout的Constraint變動時，有動畫呈現
            self.view.layoutIfNeeded()
        }
        
        //viewTransform()
    }
    
    func viewTransform() {
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3,
                                                       delay: 0,
                                                       options: .curveEaseIn,
                                                       animations: {
                                                        if self.sideMenuIsOpening == true {
                                                            let transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                                                            self.view.center.x = self.view.center.x - 100
                                                            self.view.transform = transform
                                                        }else{
                                                            self.view.transform = .identity
                                                            self.view.center.x = self.view.center.x + 100
                                                        }
                                                       }, completion: nil)

    }
    
    
    
    
    //內存警告
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    deinit {
        
        //queuePlayer.removeTimeObserver(notification)
        //NotificationCenter.default.removeObserver(notification)
        
        print("HomeViewController＿＿＿＿＿死亡")
    }
}

//Collection View 數據資源協議相關方法
extension HomeViewController: UICollectionViewDataSource {
    //Section數
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //每個Section的Cell數
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return hololiveMemers.count
    }
    
    //每個Cell的內容
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:cellID, for: indexPath)
                as? GalleryEffectCollectionViewCell else { return UICollectionViewCell() }
        
        cell.imageViewGallery.image = UIImage(named: hololiveMemers[indexPath.item].imageName)
        
        //cell.galleryImageView.image = UIImage(named: hololiveMemers[indexPath.item].imageName) //配合xib寫法 練習用
        return cell
    }
}

//Collection View 樣式設定協議相關方法
extension HomeViewController: UICollectionViewDelegate {
    
}



