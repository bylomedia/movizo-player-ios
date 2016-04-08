//
//  MovizoReporter.swift
//  DemoPlayer
//
//  Created by bylo media inc. on 2016/02/24.
//  Copyright © 2016年 movizo.jp. All rights reserved.
//

import Foundation
import Alamofire
import AVFoundation

public class MovizoReporter {
    // レポート送信URL
    let REPORT_URL = MovizoUtil.MZ_REPORT_URL
    // アカウントID
    private var accountId: String?
    // 動画ID
    private var movieId: String?
    // 動画ファイル名
    private var fileName: String?
    // デバイス固有ID
    private var deviceId: String = MovizoUtil.loadDeviceID()
    // 動画長(s)
    private var duration: Float = 0.0
    // 再生開始時刻(s)
    private var startTime: Float = 0.0
    // 再生停止時刻(s)
    private var stopTime: Float = 0.0
    // state=startを送信する為のフラグ（視聴ログを最初に送信するとき、直前で送信する）
    private var firstTime: Bool = true
    
    init(accountId: String, movieId: String, fileName: String, duration: CMTime) {
        self.accountId = accountId
        self.movieId = movieId
        self.fileName = fileName
        self.duration = Float(duration.seconds)
    }
    
    // 再生開始時刻のセット
    public func setStartTime(startTime: CMTime) {
        self.startTime = validateTime(startTime)
        self.stopTime = self.startTime
    }
    
    // 動画の初回再生時に１度だけ通知
    public func reportStart() {
        doReport(REPORT_URL + "/?state=start")
    }
    
    // 動画の再生時刻を通知
    public func reportPeriod(time: CMTime) {
        let currentTime: Float = validateTime(time)
        // 0.5秒以上の再生がない場合は通知しない(シーク後にAVPlayerのイベントが連続で上がって来るため)
        if 0.5 < currentTime - self.startTime {
            self.stopTime = currentTime
            var query: String! = "&start=" + startTime.description
            query = query + "&end=" + stopTime.description
            query = query + "&duration=" + duration.description
            
            if firstTime == true {
                reportStart()
                firstTime = false
            }
            
            doReport(REPORT_URL + "/?state=play" + query)
            self.startTime = self.stopTime
        }
    }
    
    // レポート送信
    private func doReport(url: String!) {
        var query: String! = "&accountID=" + self.accountId!
        query = query! + "&movieID=" + self.movieId!
        query = query! + "&fileName=" + self.fileName!
        query = query! + "&device=" + self.deviceId
        
        print("Report=" + url + query)
        
        let qualityOfServiceClass = DISPATCH_QUEUE_PRIORITY_DEFAULT
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        // バックスレッドで送信
        dispatch_async(backgroundQueue, {
            Alamofire.request(.GET,url + query)
            dispatch_async(dispatch_get_main_queue(), {
                // NOP
            })
        })
    }
    
    // 時刻値の正当性チェック(0.0〜durationまでの間である事)
    private func validateTime(currentTime: CMTime) -> Float {
        let time: Float = Float(currentTime.seconds)
        if time < 0.0 {
            return 0.0
        }
        else if self.duration < time {
            return self.duration
        }
        return time
    }
}
