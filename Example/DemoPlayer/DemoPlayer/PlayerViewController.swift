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
        
        // MovizoPlayerを作成し、動画を読み込む
        self.player = MovizoPlayer()

        // MOVIZOのアカウントID,動画ID,プロファイルID、および配信方法をセットします。
        // 各IDはMOVIZOコンソール(https://console.movizo.jp)で確認できます。
        // 配信方法はストリーミング(MovizoUtil.Format.Streaming)・プログレッシブダウンロード(MovizoUtil.Format.Progressive)・インライン(MovizoUtil.Format.Inline)のいずれかです。
        // プロファイルIDと一致する配信方法を記述してください。
        //
        // ここではサンプル動画として、
        // アカウントID="AAAAAAAA",動画ID="MMMMMMMM",プロファイルID="PPPPPPPP",配信方法=MovizoUtil.Format.Streaming を指定しています。
        self.player!.loadMovie("AAAAAAAA", movieID: "MMMMMMMM", profileID: "PPPPPPPP", format: MovizoUtil.Format.Streaming)

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
