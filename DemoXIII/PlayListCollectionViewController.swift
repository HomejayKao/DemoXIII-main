//
//  PlayListCollectionViewController.swift
//  DemoX
//
//  Created by homejay on 2021/3/10.
//

import UIKit
import WebKit

private let reuseIdentifier = "PlayListCollectionViewCell"

class PlayListCollectionViewController: UICollectionViewController {
    
    @IBOutlet var topView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var videoWebView: WKWebView!
    
    
    var playlistArray = [PlaylistResponse.Item]()
    var nextPageToken:String?
    var youtubeAPIKey = "AIzaSyBMjj3jIZeANrW5CK88YDtLwvQUwY3Gng4"
    var searchAPI = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=搜尋字串&type=搜尋類型&maxResults=影片數量&key=金鑰"
    var searchKeyWord = ""
    var searchType = ["channel","playlist","video"]
    
    var playlistAPI = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=影片清單的ＩＤ&maxResults=影片數量&key=金鑰"
    
    var hololiveMemerArray = [Hololive]()
    var selectedItem = 0
    
    var twitterAPI = "https://api.twitter.com/1.1/users/show.json?screen_name=推特名"
    var profile:ProfileResponse?
    
    
    var channelAPI = "https://www.googleapis.com/youtube/v3/channels?part=snippet&id=頻道的ＩＤ&key=金鑰"
    var channelItems = [ChannelResponse.Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hololiveMemerArray.count",hololiveMemerArray.count)
        print("selectedItem",selectedItem)
        
        loadPlaylistAPI(hololiveMemerArray[selectedItem].playlist_ID, 10, youtubeAPIKey)
        loadChannelAPI(hololiveMemerArray[selectedItem].channel_ID, youtubeAPIKey)
        loadTwitterProfileAPI(hololiveMemerArray[selectedItem].twitterName)
        
        setFlowLayout(itemSpace: 1, columnCount: 2)
        //addView(newView: topView) //present無法用凍結效果
        
        channelImageView.layer.cornerRadius = channelImageView.bounds.width/2 //圓角
        
        collectionView.addSubview(topView)
        
        videoWebView.backgroundColor = UIColor(red: 33, green: 33, blue: 33, alpha: 1)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    func setFlowLayout(itemSpace:CGFloat,columnCount:CGFloat) {
        //實現一排 4 張正方形的照片，照片間的距離為 3，總共有 3 個間距，那麼在寬度 414 的 iPhone 11 時，cell 的寬度將為 (414 - 4*3) / 4 = 100.5
        
        //間隔寬、間距
        let itemSpace = itemSpace
        //列數
        let columnCount = columnCount
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        
        //利用 function floor 將小數點後的數字捨去，因為還有小數點的話，有可能會讓最後加起來的寬度超過螢幕寬度。(間距數 = 列數-1)
        let cellWidth = floor((collectionView.bounds.width - itemSpace * (columnCount-1)) / columnCount)
        flowLayout?.itemSize = CGSize(width: cellWidth , height: cellWidth )
        
        //將 Min Spacing For Cells & Min Spacing For Lines 都設為 itemSpace。
        flowLayout?.estimatedItemSize = .zero
        flowLayout?.minimumInteritemSpacing = itemSpace
        flowLayout?.minimumLineSpacing = itemSpace
        
        let top = topView.bounds.height
        flowLayout?.sectionInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
    }
    
    func addView(newView:UIView) {
        // 此屬性為告訴ios自動建立放置位置的約束條件，有要autolayout就不會有它，有它就無法autolayout
        newView.translatesAutoresizingMaskIntoConstraints = false
        
        // 在collectionView上加 View
        collectionView.addSubview(newView)
        
        guard let navigationBarHeight = self.navigationController?.navigationBar.bounds.height else { return }
        
        // 設定View的高度
        newView.heightAnchor.constraint(equalToConstant: (collectionView.bounds.height)/3 + navigationBarHeight).isActive = true
        
        // 設定View左右與collectionView左右無間距
        newView.leadingAnchor.constraint(equalTo: collectionView.frameLayoutGuide.leadingAnchor).isActive = true
        newView.trailingAnchor.constraint(equalTo: collectionView.frameLayoutGuide.trailingAnchor).isActive = true
        
        
        // 設定top與contentLayoutGuide top無間距, 並設定Priority為999, 發生衝突時將犧牲此約束條件
        let topConstraint = newView.topAnchor.constraint(equalTo: collectionView.contentLayoutGuide.topAnchor)
        topConstraint.priority = UILayoutPriority(999)
        topConstraint.isActive = true
        
        // 設定View底部 與collectionView top間距65,讓View底部保留25不會被捲動
        // 設定buttom與safeAreaLayoutGuide 大於等於 safeAreaLayoutGuide top + 常數 三分之一螢幕與bar 的高
        newView.bottomAnchor.constraint(greaterThanOrEqualTo: collectionView.safeAreaLayoutGuide.topAnchor, constant: (collectionView.bounds.height)/3 + navigationBarHeight).isActive = true
        
    }
    
    func loadPlaylistAPI(_ ID:String , _ count:Int , _ key:String) {
        
        playlistAPI = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(ID)&maxResults=\(count)&key=\(key)"
        
        NetworkController.shared.fetchYoutubePlaylistAPI(urlString: playlistAPI) { (result) in
            switch result {
            
            case let .success(playlistItemResponse):
                
                self.playlistArray = playlistItemResponse.items
                
                self.nextPageToken = playlistItemResponse.nextPageToken
                
                DispatchQueue.main.async {
                    self.channelTitleLabel.text = self.playlistArray.first?.snippet.channelTitle
                    
                    if let videoID = self.playlistArray.first?.snippet.resourceId.videoId {
                        self.embedVideo(videoID: videoID)
                    }
                    
                    self.collectionView.reloadData()
                }
                
            case let .failure(error):
                print("擷取播放清單失敗",error)
            }
        }
    }
    
    func loadChannelAPI(_ ID:String , _ key:String) {
        
        channelAPI = "https://www.googleapis.com/youtube/v3/channels?part=snippet&id=\(ID)&key=\(key)"
        
        NetworkController.shared.fetchYoutubeChannelAPI(urlString: channelAPI) { (result) in
            switch result {
            
            case let .success(channelResponse):
                
                self.channelItems = channelResponse.items
                
                DispatchQueue.main.async {
                    self.updateUI()
                }
                
            case let .failure(error):
                print("擷取頻道失敗",error)
            }
        }
    }
    
    func loadTwitterProfileAPI (_ twitterName:String) {
        
        twitterAPI = "https://api.twitter.com/1.1/users/show.json?screen_name=\(twitterName)"
        
        NetworkController.shared.fetchTwitterProfileAPI(urlString: twitterAPI) { (result) in
            switch result {
            
            case let .success(profileResponse):
                
                self.profile = profileResponse
                
                DispatchQueue.main.async {
                    self.updateUI()
                }
                
            case let .failure(error):
                print("擷取推特失敗",error)
            }
        }
    }
    
    func updateUI(){
        if let bannerImageUrl = profile?.profile_banner_url {
            NetworkController.shared.fetchImage(url: bannerImageUrl) { (result) in
                switch result {
                
                case let .success(image):
                    DispatchQueue.main.async {
                        self.bannerImageView.image = image
                    }
                case let .failure(error):
                    print("擷取banner圖失敗",error)
                }
            }
        }
        
        if let imgUrl = channelItems.first?.snippet.thumbnails.medium.url {
            NetworkController.shared.fetchImage(url: imgUrl) { (result) in
                switch result {
                
                case let .success(image):
                    DispatchQueue.main.async {
                        self.channelImageView.image = image
                    }
                case let .failure(error):
                    print("擷取Channel圖片失敗",error)
                }
            }
        }
    }
    
    // 鑲嵌影片
    func embedVideo (videoID:String) {
        if let embedURL = URL(string: "https://www.youtube.com/embed/\(videoID)") {
            videoWebView.load(URLRequest(url: embedURL))
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = indexPath.item
        
        if let videoID = playlistArray[item].snippet.resourceId.videoId {
            embedVideo(videoID: videoID)
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
       
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return playlistArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PlayListCollectionViewCell else { return UICollectionViewCell() }
        
        if let imageUrl = playlistArray[indexPath.item].snippet.thumbnails.medium.url,
           let title = playlistArray[indexPath.item].snippet.title {
            
            cell.setInfo(imageUrl,title)
        }

        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    deinit {
        print("PlayListCollectionViewController＿＿＿＿＿死亡")
    }

}
