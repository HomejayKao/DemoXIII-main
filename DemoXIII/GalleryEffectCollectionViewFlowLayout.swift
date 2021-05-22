//
//  GalleryEffectCollectionViewFlowLayout.swift
//  DemoX
//
//  Created by homejay on 2021/3/3.
//

import UIKit

class GalleryEffectCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    //Cell寬度
    var itemWidth:CGFloat = 100
    //Cell高度
    var itemHeight:CGFloat = 100
    
    //collectionView的邊界發生變化時 是否重新使用樣式（滾動時也會觸發)
    //會重新呼叫 prepare()與 layoutAttributesForElements(InRect)獲得部分Cell的設置
    //Invalidate 使無效，雖然叫 是否應該使Layout無效，但其功能為，詢問Layout對新邊界是否需要進行更新。
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true //詢問Layout對新邊界是否需要進行更新。
    }
    
    //對一些Cell樣式排版的準備操作
    override func prepare() {
        super.prepare()
        //Cell大小
        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
        //滾動方向
        self.scrollDirection = .horizontal
        //設置Cell間距
        self.minimumLineSpacing = self.collectionView!.bounds.width / 2 -  itemWidth
        
        //設定Section的間距
        //左右間距一樣 為了讓Cell置於螢幕中央，故要用螢幕寬度去計算
        //上下間距一樣 為了讓Cell置於螢幕正中央，故要用螢幕高度去計算
        let left = (self.collectionView!.bounds.width - itemWidth) / 2
        let top = (self.collectionView!.bounds.height - itemHeight) / 2
        //self.sectionInset = UIEdgeInsetsMake(top, left, top, left) // section與section之間的距離(如果只有一個section，可以想像成frame)
        self.sectionInset = UIEdgeInsets(top: top+40, left: left, bottom: top, right: left)
        //top+40 是為了不要擋到背景圖的Impostor英文字
    }

    //設定滾動時的縮放————————————————————————————————————————————————————————————————————————————————————————
    
    //檢索rect範圍下所有Cell的位置屬性等設置，檢索指定矩形中所有Cell和View的layout屬性。
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
        //從父類別得到默認的所有 預設屬性
        
        guard let superArray = super.layoutAttributesForElements(in: rect) else { return nil} //會回傳 layout屬性設置每個cell 的陣列
        
        //複製原本的superArray，不改動super內的配置為原則
        guard let copyArray = NSArray(array: superArray, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil}
        
        //可見區域的大小（目前顯示出来的位置，位於collectionView上的矩形區域）
        let visiableRect = CGRect(x: self.collectionView!.contentOffset.x,
                                  //contentOffset 原點與滾動偏離的點，偏移的多遠。滑動後與遠點的距離，其位置x
                                  y: self.collectionView!.contentOffset.y,
                                  width: self.collectionView!.frame.width,
                                  height: self.collectionView!.frame.height)
        
        //當前螢幕中心位置，相對於collectionView上的x座標 再加上 半個螢幕寬 就是中心了
        let centerX = self.collectionView!.contentOffset.x + self.collectionView!.bounds.width / 2
        
        //用來計算縮放比例
        let maxDeviation = self.collectionView!.bounds.width / 2 //+ itemWidth / 2 螢幕的一半寬其實就夠了
        
        //設定每個Cell的縮放
        for attributes in copyArray {
            //判斷與可見區域是否相交，intersects判斷兩個矩形是否相交，true
            if visiableRect.intersects(attributes.frame) {
            
            //顯示的Cell根據偏移的大小，決定放大的倍數(此例最大設為 放大1.8倍)，如果放不夠大，滾動時會滾到兩個Cell
            //離螢幕中心越近的Cell縮放越大 ; 離螢幕中心越遠的Cell縮放得越小
                let scale = 1 + (0.8 - abs(centerX - attributes.center.x) / maxDeviation) //abs為 加上絕對值，與中心距離越大，其相減的差越大
                //沒有0.8的話，將會由原本的1去扣，即是原本的大小去扣，這樣遠離中心的圖，會被縮很小
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale) //縮放，若為0.5即是縮小0.5倍的意思
            }
        }
        
        return copyArray
    }
    
    //設定滾動後的位置————————————————————————————————————————————————————————————————————————————————————————
    
    /*
     用來設置collectionView停止滾動時，其位置，位於螢幕中央
     proposedContentOffset: 原本collectionView停止滾動時的位置
     velocity:滾動速度
     返回：最終停留的位置
     */
    
    //targetContentOffset 檢索停止滾動時的point。會回傳一個滾動後停留的CGPoint位置
    override func targetContentOffset(forProposedContentOffset
        proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        //停止滾動時的可見區域
        let lastRect = CGRect(x: proposedContentOffset.x,
                              y: proposedContentOffset.y,
                              width: self.collectionView!.bounds.width,
                              height: self.collectionView!.bounds.height)
        
        //當前螢幕的中心位置，相對於collectionView上的x座標 再加上 半個螢幕寬 就是中心了
        let centerX = proposedContentOffset.x + self.collectionView!.bounds.width / 2
        
        //停止滾動時的可見區域，其所有Cell的位置與屬性 陣列
        let array = self.layoutAttributesForElements(in: lastRect)
        
        //用來找出 需要移動的距離
        var adjustOffsetX = CGFloat(MAXFLOAT)// maxFloat
        
        //利用每個Cell 作運算找出 移動幅度最小的距離量
        for attributes in array! {
            
            //每個Cell的中心 偏移的量
            let deviation = attributes.center.x - centerX
            
            //找出所有Cell內 與中心偏移幅度最小 其距離的量
            if abs(deviation) < abs(adjustOffsetX) {
                adjustOffsetX = deviation
            }
            
        }
        
        //通過偏移的最小距離量，返回最終停留的位置
        return CGPoint(x: proposedContentOffset.x + adjustOffsetX, y: proposedContentOffset.y)
    }
    
    deinit {
        print("GalleryEffectCollectionViewFlowLayout＿＿＿＿＿死亡")
    }

}

