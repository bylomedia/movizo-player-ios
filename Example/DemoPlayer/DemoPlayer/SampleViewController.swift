//
//  ViewController.swift
//  DemoPlayer
//
//  Created by bylo media inc. on 2016/02/26.
//  Copyright © 2016年 movizo.jp. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController {
    let app:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)

    private var fullScreenButton: UIButton!
    private var inlineButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Movizo SDK サンプルメニュー"
        
        // フルスクリーン再生ボタン
        fullScreenButton = UIButton()
        setPlayButton(fullScreenButton)
        fullScreenButton.setTitle("フルスクリーン再生", forState: UIControlState.Normal)
        fullScreenButton.setTitle("フルスクリーン再生", forState: UIControlState.Highlighted)
        fullScreenButton.layer.position = CGPoint(x: self.view.frame.width/2, y:150)
        fullScreenButton.addTarget(self, action: "onClickFullScreenButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(fullScreenButton)

        // インライン再生ボタン
        inlineButton = UIButton()
        setPlayButton(inlineButton)
        inlineButton.setTitle("インライン再生", forState: UIControlState.Normal)
        inlineButton.setTitle("インライン再生", forState: UIControlState.Highlighted)
        inlineButton.layer.position = CGPoint(x: self.view.frame.width/2, y:250)
        inlineButton.addTarget(self, action: "onClickInlineButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(inlineButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // フルスクリーン再生ボタンをクリック
    func onClickFullScreenButton(sender: UIButton){
        app.isFullScreen = true
        showPlayerScreen()
    }

    // インライン再生ボタンをクリック
    func onClickInlineButton(sender: UIButton){
        app.isFullScreen = false
        showPlayerScreen()
    }

    // プレーヤー画面に遷移
    private func showPlayerScreen() {
        let next_view: UIViewController = PlayerViewController()
        self.navigationController?.pushViewController(next_view, animated: true)
    }
    
    // ボタン設定
    private func setPlayButton(playButton: UIButton) {
        playButton.frame = CGRectMake(0,0,200,40)
        playButton.backgroundColor = UIColor.grayColor()
        playButton.layer.masksToBounds = true
        playButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        playButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        playButton.layer.cornerRadius = 20.0
    }
}