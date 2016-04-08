//
//  ViewController.swift
//  DemoPlayer
//
//  Created by bylo media inc. on 2016/02/23.
//  Copyright © 2016年 movizo.jp. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MovizoPlayer

class PlayerViewController: UIViewController {
    let app:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)

    private var playerController: AVPlayerViewController?
    private var player: MovizoPlayer?
    private var movieTimeObserver: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MovizoPlayerを作成し、アカウントID、動画ID、再生方法を指定して動画を読み込む
        self.player = MovizoPlayer()
        self.player!.loadMovie("AAAAAAAA", movieID: "MMMMMMMM", format: MovizoUtil.Format.HLS)

        // AVPlayerViewControllerを作成し、本Viewに追加
        self.playerController = AVPlayerViewController()
        self.playerController!.player = self.player!
        self.addChildViewController(self.playerController!)
        self.view.addSubview(self.playerController!.view)
        
        // Viewのレイアウト設定(フルスクリーン/インライン)
        layoutFrame(app.isFullScreen)
        
        // (最長でも)15秒間隔で視聴ログを取る
        self.player!.interval = 15.0
        
        // ループ再生する
        self.player!.loop = true
    }

    override func viewDidLayoutSubviews() {
        layoutFrame(app.isFullScreen)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // 再生スタート
        self.player!.play()
        
        // 動画再生時刻のオブザーバーをセット(１秒毎）
        let interval: Float64 = 1
        self.movieTimeObserver = self.player!.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(interval, Int32(NSEC_PER_SEC)),
            queue: dispatch_get_main_queue(),
            usingBlock: {[unowned self](CMTime) in
                self.notifyPlayTimeChanged()
            }
        )
    }
    
    override func viewWillDisappear(animated: Bool) {
        //  再生停止
        self.player!.pause()
        
        // 動画再生時刻のオブザーバーを停止
        if self.movieTimeObserver != nil {
            self.player!.removeTimeObserver(self.movieTimeObserver!)
            self.movieTimeObserver = nil
        }
    }
    
    // AVPlayerViewControllerの配置
    private func layoutFrame(isFullScreen: Bool) {
        //背景色
        self.view.backgroundColor = UIColor.whiteColor()
        
        if isFullScreen {
            // フルスクリーンのときは親ViewControllerのframeに合わせる
            self.playerController!.view.frame = self.view.frame
        }
        else {
            // インラインの時はframeサイズと位置を設定
            self.playerController!.view.frame.size = CGSizeMake(320, 240)
            self.playerController!.view.center.x = self.view.center.x
            self.playerController!.view.center.y = self.view.center.y
        }
    }
    
    // 動画再生時刻が変化すると呼ばれる
    private func notifyPlayTimeChanged() {
        print((self.player!.currentItem?.currentTime().seconds.description)! + "秒")
    }
}
