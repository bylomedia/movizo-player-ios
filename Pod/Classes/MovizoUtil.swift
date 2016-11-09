//
//  MovizoUtil.swift
//  DemoPlayer
//
//  Created by bylo media inc. on 2016/02/24.
//  Copyright © 2016年 movizo.jp. All rights reserved.
//

import Foundation

public struct MovizoUtil {
    // バージョン
    public static let VERSION = "1.0"
    // 動画のホスト名
    public static let MZ_MOVIE_HOST = "movie.movizo.jp"
    // 動画URLのパス(prefix)
    public static let MZ_MOVIE_PREFIX = ""
    // デフォルトの動画ファイル名
    public static let DEFAULT_MOVIE_NAME = "movie"
    // デバイスID保存ファイル名
    public static let DEVICE_ID_FILENAME = "deviceinfo"
    // レポートURLのパス(prefix)
    public static let MZ_REPORT_URL = "https://s3-ap-northeast-1.amazonaws.com/report.movizo.jp/playlog"
    
    // 配信方法
    public enum Format {
        case Streaming
        case Progressive
        case Inline
    }

    // 配信方法から拡張子を得る
    public static func formatToSuffix(format: MovizoUtil.Format) -> String {
        switch format {
            case MovizoUtil.Format.Streaming:
                return "m3u8"
            case MovizoUtil.Format.Progressive:
                return "m4v"
            case MovizoUtil.Format.Inline:
                return "m4v"
        }
    }

    // デバイスIDを生成
    public static func generateDeviceID() -> String {
        let length: Int = 16;
        // 生成する文字列に含める文字セット
        let chars: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        let charsLen: UInt32 = UInt32(chars.characters.count)

        return String((0..<length).map { _ -> Character in
            return chars[chars.startIndex.advancedBy(Int(arc4random_uniform(charsLen)))]
            })
    }
    
    // デバイスIDを取得する（無ければ作成する）
    public static func loadDeviceID() -> String! {
        var deviceID: String?
        
        deviceID = readDeviceID()
        if(deviceID == nil) {
            deviceID = generateDeviceID()
            if(writeDeviceID(deviceID!) == false) {
                // 書き込みエラー
                deviceID = ""
            }
        }
        return deviceID!
    }
    
    // デバイスIDを読む
    public static func readDeviceID() -> String? {
        let text: String?
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let filePath = documentsPath + "/" + "Movizo" + "/" + DEVICE_ID_FILENAME
        
        // 読み込み
        do {
            text = try NSString( contentsOfFile: filePath, encoding: NSUTF8StringEncoding ) as String
        } catch {
            text = nil
        }
        return text
    }
    
    // デバイスIDを書く
    public static func writeDeviceID(deviceID: String) -> Bool {
        var documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        documentsPath = documentsPath + "/" + "/Movizo"
        
        // ディレクトリが無ければ作成
        let fileManager = NSFileManager.defaultManager()
        if(fileManager.fileExistsAtPath(documentsPath) == false) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(documentsPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return false
            }
        }
        
        // 保存
        let filePath = documentsPath + "/" + DEVICE_ID_FILENAME
        do {
            try deviceID.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            return false
        }
        
        return true
    }
}
