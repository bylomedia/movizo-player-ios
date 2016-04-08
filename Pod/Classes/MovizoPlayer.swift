//
//  MovizoPlayer.swift
//  DemoPlayer
//
//  Created by bylo media inc. on 2016/02/22.
//  Copyright © 2016年 movizo.jp. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation

public class MovizoPlayer: AVPlayer {
    // 時間監視オブザーバー
    private var movieTimeObserver: AnyObject?
    // 視聴時刻通知レポーター
    private var movizoReporter: MovizoReporter?
    // 再生状況の内部ステータス
    enum State {
        case START
        case PLAYING
        case STOP
        case SEEKING
        
        // デバッグ表示用
        var toString: String! {
            switch self {
            case .START:
                return "START"
            case .PLAYING:
                return "PLAYING"
            case .STOP:
                return "STOP"
            case .SEEKING:
                return "SEEKING"
            }
        }
    }
    
    // AVplayerの再生速度(rate)、再生状況を判定するために必要
    private var lastRate: Float = 0.0
    
    // ループ再生(デフォルト:しない)
    public var loop: Bool = false
    
    // 視聴ログを送信する間隔(s)
    public var interval: Float64 = 10.0
    
    public func loadMovie(accountID: String, movieID: String, format: MovizoUtil.Format) {

        // 動画を読み込む
        let path:String = MovizoUtil.MZ_MOVIE_PREFIX + "/" + accountID + "/" + movieID + "/" + MovizoUtil.DEFAULT_MOVIE_NAME + "." + MovizoUtil.formatToSuffix(format)
        let url = NSURL(scheme: "https", host: MovizoUtil.MZ_MOVIE_HOST, path:path)
        super.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: url!))
        
        // レポーター作成
        movizoReporter = MovizoReporter(accountId: accountID, movieId: movieID,fileName: MovizoUtil.DEFAULT_MOVIE_NAME, duration: (self.currentItem?.asset.duration)!)
    }
    
    // 再生開始
    public override func play() {
        super.play()
        
        // 再生状況の監視をスタート
        self.movieTimeObserver = self.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(self.interval, Int32(NSEC_PER_SEC)),
            queue: dispatch_get_main_queue(),
            usingBlock: {[unowned self](CMTime) in
                self.notifyPlayTimeChanged()
            }
        )
        
        // 動画終了のNotification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.currentItem)
    }
    
    // 再生停止
    public override func pause() {
        super.pause()
        
        // 再生時刻の監視をストップ
        if self.movieTimeObserver != nil {
            removeTimeObserver(self.movieTimeObserver!)
            self.movieTimeObserver = nil
        }
    }
    
    // 動画終了
    public func playerItemDidReachEnd(notification: NSNotification) {
        print("Reach End =" + (self.currentItem?.currentTime().seconds.description)! + "rate=" + self.rate.description)
        // ループ再生なら先頭へ戻る
        if self.loop {
            self.seekToTime(CMTimeMakeWithSeconds(0, Int32(NSEC_PER_SEC)))
            self.play()
            //self.rate = 1.0
        }
    }
    
    // 再生時刻が変わったら呼ばれる(ココで動画の再生状況を判定する)
    private func notifyPlayTimeChanged() {
        switch playStatus(self.rate) {
        case State.START:
            print("START")
            movizoReporter?.setStartTime((self.currentItem?.currentTime())!)
        case State.PLAYING:
            print("PLAYING")
            movizoReporter?.reportPeriod((self.currentItem?.currentTime())!)
        case State.STOP:
            print("STOP")
            movizoReporter?.reportPeriod((self.currentItem?.currentTime())!)
        case State.SEEKING:
            print("SEEKING")
            break
        }
    }
    
    // AVPlayerの再生速度(rate)により再生状況を判定する(停止中の時、rate == 0.0)
    private func playStatus(rate: Float) -> State {
        var status: State?
        
        if self.lastRate == 0.0  {
            status = (rate == 0.0) ? State.SEEKING : State.START
        }
        else {
            status = (rate == 0.0) ? State.STOP : State.PLAYING
        }
        
        lastRate = rate
        
        return status!
    }
    
}
