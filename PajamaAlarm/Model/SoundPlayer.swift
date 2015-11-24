//
//  SoundPlayer.swift
//
//  Created by hideki on 2015/05/05.
//
//

import Foundation
import AVFoundation


enum SoundPlayerErrorCode:Int {
	case NoError
	case FileNotFound
}

public class SoundPlayer: NSObject, AVAudioPlayerDelegate {
	
	// サウンド再生用のチャンネルの数
	var CH_COUNT = 10
	// サウンドファイルの拡張子が無い場合に付ける拡張子
	let SOUND_SUFFIXES = [".mp3", ".m4a", ".wav", ".aiff"]
	
	// エラーメッセージ、エラーコード
	var _errorMessage = ""
	var _errorCode    = SoundPlayerErrorCode.NoError
	
	// サウンド再生用のプレイヤー 複数チャンネル分用意
	var _players    = [AVAudioPlayer?]()
	var _subPlayers = [AVAudioPlayer?]()
	
	// ボイス再生に特化したプレイヤー 連続再生と音声レベルの取得が可能
	var _voicePlayer: AVAudioPlayer?
	// ボイスの連続再生間隔
	var _voicePlayInterval: Double!
	// ボイスを連続再生する際のファイルの配列
	var _voiceFiles = [String]()
	
	// 無音再生用のプレイヤー
	var _muteSoundPlayer: AVAudioPlayer?
	
	// 音声レベル取得用　直前の再生レベル
	var _lastVoiceLevel: Float?

	
	override init() {
		super.init()
		
		// AVAudioPlayerの配列を作成
		for _ in 0 ..< CH_COUNT {
			_players.append(nil)
			_subPlayers.append(nil)
		}
		

	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	//======================================================
	// チャンネル別の再生、停止
	//======================================================
	
	// 音声ファイルを再生
	func play(fileName: String, ch: Int = 0, volume: Float = 1.0, loop: Bool = false) {
		let player = makeAudioPlayer(fileName)
		if _errorCode != SoundPlayerErrorCode.NoError {
			return
		}
		
		if loop == true {
			player?.numberOfLoops = 65535
		}
		
		player?.volume   = volume
		player?.delegate = self
		player?.play()
		
		print("　サウンドを再生します: " + fileName)
		
		_players[ch] = player
		//_players[ch]!.play()
	}
	
	// 音声ファイルをギャップ無しでループ再生
	func playByGaplessLoop(fileName: String, ch: Int = 0, volume: Float = 1.0) {
		if _players[ch] != nil {
			stop(ch)
			return
		}
		
		_players[ch]    = makeAudioPlayer(fileName)
		_subPlayers[ch] = makeAudioPlayer(fileName)
		
		if _errorCode != SoundPlayerErrorCode.NoError {
			return
		}
		
		_players[ch]?.volume    = 0
		_subPlayers[ch]?.volume = 0
		
		_players[ch]?.prepareToPlay()
		_subPlayers[ch]?.prepareToPlay()
		
		controlPlayersAsCrossFade(_players[ch]!, nextPlayer: _subPlayers[ch], ch: ch, volume: volume)
	}
	
	// 一時停止
	func pause(ch: Int = 0) {
		if _players[ch] != nil {
			_players[ch]?.pause()
		}
	}
	
	// 停止
	func stop(ch: Int = 0) {
		if _players[ch] != nil {
			_players[ch]?.stop()
			_players[ch] = nil
		}
		
		if _subPlayers[ch] != nil {
			_subPlayers[ch]?.stop()
			_subPlayers[ch] = nil
		}
	}
	
	// 再生中か判別
	func isPlaying(ch: Int = 0) -> Bool {
		if _players[ch] == nil {
			return false
		}
		let result = _players[ch]?.playing
		
		return result!
	}
	
	
	//======================================================
	// 無音再生用
	//======================================================
	
	// 音声ファイルを無音で再生
	func playMuteSound(fileName: String) {
		_muteSoundPlayer = makeAudioPlayer(fileName)
		if _errorCode != SoundPlayerErrorCode.NoError {
			return
		}
		
		_muteSoundPlayer?.numberOfLoops = 100000
		_muteSoundPlayer?.volume = 0
		_muteSoundPlayer?.play()
		
		print("　ミュート再生します: " + fileName)
	}
	
	// 無音再生を停止
	func stopMuteSound() {
		if _muteSoundPlayer != nil {
			_muteSoundPlayer?.stop()
		}
	}
	
	//======================================================
	// ボイス再生用
	//======================================================
	
	// 複数のボイスを連続で再生
	func playVoices(fileNames: [String], volume: Float = 1.0, interval: Double = 0) {
		if isVoicePlaying() {
			stopVoice()
			
			return
		}
		
		// 通知を発行
		NSNotificationCenter.defaultCenter().postNotificationName("voicePlayStarted", object: nil)
		
		_voiceFiles        = fileNames
		//_voiceVolume       = volume
		_voicePlayInterval = interval
		
		advanceToNextVoice(volume)
	}
	
	// 複数のボイスを連続で再生　再生開始時にコールバック処理
	func playVoices(fileNames: [String], volume: Float = 1.0, interval: Double = 0, onStart: () -> ()) {
		playVoices(fileNames, volume: volume, interval: interval)
		
		onStart()
	}
	
	// 次のボイスを再生
	func advanceToNextVoice(volume: Float) {
		let fileName = _voiceFiles.removeAtIndex(0)
		
		_voicePlayer = makeAudioPlayer(fileName)
		if _errorCode != SoundPlayerErrorCode.NoError {
			return
		}
		
		_voicePlayer?.volume          = volume
		_voicePlayer?.delegate        = self
		_voicePlayer?.meteringEnabled = true
		_voicePlayer?.prepareToPlay()
		
		print("　サウンドを再生します: " + fileName ) //" \(NSDate().timeIntervalSince1970)")
		_voicePlayer?.play()
	}
	
	// ボイスが再生中か
	func isVoicePlaying() -> Bool {
		if _voicePlayer == nil {
			return false
		}
		let result = _voicePlayer?.playing
		
		return result!
	}
	
	// ボイスの停止
	func stopVoice() {
		if _voicePlayer != nil {
			_voicePlayer?.stop()
			_voicePlayer = nil
		}
	}
	
	// ボイスの一時停止
	func pauseVoice() {
		if _voicePlayer != nil {
			_voicePlayer?.pause()
		}
	}
	
	//======================================================
	// すべてのチャンネル、ボイスに対する命令　無音ファイルには適用されない
	//======================================================
	
	// 全て一時停止
	func pauseAll() {
		for player in _players {
			if player != nil {
				player?.pause()
			}
		}
		
		for player in _subPlayers {
			if player != nil {
				player?.pause()
			}
		}
		
		if _voicePlayer != nil {
			_voicePlayer?.pause()
		}
	}
	
	// すべて停止
	func stopAll() {
		for player in _players {
			if player != nil {
				player?.stop()
			}
		}
		
		for player in _subPlayers {
			if player != nil {
				player?.stop()
			}
		}
		
		if _voicePlayer != nil {
			_voicePlayer?.stop()
		}
	}
	
	// すべて再開
	func resumeAll() {
		for player in _players {
			if player != nil {
				player?.play()
			}
		}
		
		for player in _subPlayers {
			if player != nil {
				player?.play()
			}
		}
		
		if _voicePlayer != nil {
			_voicePlayer?.play()
		}
	}
	
	//======================================================
	// ギャップレス再生演出用
	//======================================================
	
	// 音声ファイルをギャップ無しでループ再生
	func gaplessLoopPlayWithTimer(fileName: String, ch: Int = 0, volume: Float = 1.0) {
		if _players[ch] != nil {
			stop(ch)
			_gaplessTimer?.invalidate()
			return
		}
		
		_players[ch]    = makeAudioPlayer(fileName)
		_subPlayers[ch] = makeAudioPlayer(fileName)
		
		if _errorCode != SoundPlayerErrorCode.NoError {
			return
		}
		
		_players[ch]?.volume    = 0
		_subPlayers[ch]?.volume = 0
		
		_players[ch]?.prepareToPlay()
		_subPlayers[ch]?.prepareToPlay()
		
		let p = _players[ch]!
		let ti = Double(p.duration) - 2

		print("再生間隔 \(ti)")
		
		let userInfo = ["ch": ch, "volume": volume, "player": _players[ch]!, "subPlayer": _subPlayers[ch]!]
	
		_gaplessTimer = NSTimer.scheduledTimerWithTimeInterval(ti, target: self, selector: "playAlternately:", userInfo: userInfo, repeats: true)
		//controlPlayersAsCrossFade(_players[ch]!, nextPlayer: _subPlayers[ch], ch: ch, volume: volume)
		playAlternately(_gaplessTimer!)
	}
	
	var _gaplessTimer: NSTimer?
	
	func playAlternately(timer: NSTimer) {
		let userInfo:[String: AnyObject] = timer.userInfo as! [String: AnyObject]

		let vol = userInfo["volume"] as! Float
		let player = userInfo["player"] as! AVAudioPlayer
		let subPlayer = userInfo["subPlayer"] as! AVAudioPlayer
		
		if player.playing == true {
			subPlayer.play()
			fadeIn(subPlayer, afterVolume: vol)
			fadeOut(player, beforeVolume: vol)
		} else {
			player.play()
			fadeIn(player, afterVolume: vol)
			fadeOut(subPlayer, beforeVolume: vol)
		}

		print("再生開始 \(NSDate().timeIntervalSince1970)")
	}
	
// ボイス再生時、dispatchで処理が競合してる？ メインスレッドでやる必要ありか
// 正常に機能しないことあり
	// 複数のAVAudioPlayerをクロスフェードしながら再生
	func controlPlayersAsCrossFade(player: AVAudioPlayer, nextPlayer: AVAudioPlayer?, ch: Int = 0, volume: Float = 1.0) {
		player.play()
		fadeIn(player, afterVolume: volume)

		print("ギャップレス再生開始")
		
		// 再生終了間際にフェードアウト、次のプレイヤーの再生
		let dispTime = Double(player.duration) - 2
print("\(dispTime)秒後にフェードアウトします")
		dispatchAfterByOtherThread(dispTime, closure: {
			if self._players[ch] != player && self._subPlayers[ch] != player {
				return
			}
			
			print("フェードアウト開始")
			
			self.fadeOut(player, beforeVolume: volume)
			self.controlPlayersAsCrossFade(nextPlayer!, nextPlayer: player, volume: volume)
		})
	}
	
	// 単一のAVAudioPlayerをフェードイン、フェードアウトしながら再生
	func controlPlayerAsFade(player: AVAudioPlayer, ch: Int = 0, volume: Float = 1.0) {
		player.play()
		fadeIn(player, afterVolume: volume)
		
		// 再生終了間際にフェードアウト
		let dispTime = Double(player.duration) - 2
		
		dispatchAfterByOtherThread(dispTime, closure: {
			if self._players[ch] != player && self._subPlayers[ch] != player {
				return
			}
			
			self.fadeOut(player, beforeVolume: volume)
		})
	}
	
	// フェードイン　徐々に音量を上げる
	func fadeIn(player: AVAudioPlayer, afterVolume: Float) {
		let plusVolume = afterVolume / 10
		
		player.volume += plusVolume
		if afterVolume <= player.volume {
			return
		}
		
		dispatchAfterByOtherThread(0.1, closure: {
			self.fadeIn(player, afterVolume: afterVolume)
		})
	}
	
	// フェードアウト　徐々に音量を下げる
	func fadeOut(player: AVAudioPlayer, beforeVolume: Float) {
		let minusVolume = beforeVolume / 18
		
		player.volume -= minusVolume
		if player.volume <= 0 {
			return
		}
		
		dispatchAfterByOtherThread(0.1, closure: {
			self.fadeOut(player, beforeVolume: beforeVolume)
		})
	}
	
	//======================================================
	// 音量レベル測定用
	//======================================================
	
	// 話し声の音声レベルが一定以上かを判定
	func isTalkingVoiceLevel(threshold: Float = 120.0) -> Bool {
		let result = isSoundLevelOverThreshold(threshold)
		
		return result
	}
	
	// 歌の音声レベルが一定以上かを判定  thresholdが決まらない 110〜115?
	func isSingingVoiceLevel(threshold: Float = 110) -> Bool {
		let result = isSoundLevelOverThreshold(threshold)
		
		return result
	}
	
	// 音声レベルが一定以上かを判定 シンプル化　これで大丈夫……？
	func isSoundLevelOverThreshold(threshold: Float = 120.0) -> Bool {
		var result = false
		
		let level = monitorVoiceLevel()
		
		if threshold < level {
			result = true
		}
		
		outputVoiceMeter(level, threshold: threshold)
		
		return result
	}
	
	// 改良前
	func isSoundLevelOverThresholdO(threshold: Float = 120.0) -> Bool {
		var result = false
		
		let level = monitorVoiceLevel()
		
		if _lastVoiceLevel == nil && 40.0 < level {
			result = true
		} else {
			_lastVoiceLevel = level
		}
		
		if threshold < level {
			result = true
			_lastVoiceLevel = level
		}
		
		outputVoiceMeter(level, threshold: threshold)
		
		return result
	}
	
	/*
	// 音声レベルが一定以上かを判定　最初のやつ
	
	// 音声レベル取得用　音声ファイルの冒頭かどうか 再生開始時はレベルが低いため必要
	//var _atStartOfVoice = false
	
	func isSoundLevelOverThresholdOrg(threshold: Float = 120.0) -> Bool {
	var result = false
	
	let level = monitorVoiceLevel()
	if _lastVoiceLevel == 0 && 40 < level {
	_atStartOfVoice = true
	}
	
	if threshold < level {
	_atStartOfVoice = false
	result = true
	} else if _atStartOfVoice == true {
	result = true
	}
	
	outputVoiceMeter(level, threshold: threshold)
	
	_lastVoiceLevel = level
	
	return result
	}*/
	
	// 音声レベルを測定
	func monitorVoiceLevel() -> Float {
		_voicePlayer?.updateMeters()
		let ch = _voicePlayer?.numberOfChannels
		if ch == nil {
			return 0
		}
		
		let level   = _voicePlayer?.averagePowerForChannel(0)
		let avLevel = level! + 160.0
		
		return avLevel
	}
	
	// 音声レベルをコンソールに出力
	func outputVoiceMeter(level: Float, threshold: Float) {
		var str = "\(level)　"
		
		if threshold <= level {
			for var i = 3; Float(i) < level; i += 3 {
				str += "■"
			}
		}
		
		print(str)
	}
	
	//======================================================
	// バックグラウンド再生のON / OFF
	//======================================================
	
	// バックグラウンド再生を有効に
	func backgroundAudioON() {
		try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
		try! AVAudioSession.sharedInstance().setActive(true)
	}
	
	// バックグラウンド再生を無効に
	func backgroundAudioOFF() {
		try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient, withOptions: [])
		try! AVAudioSession.sharedInstance().setActive(false)
	}
	
	//======================================================
	// エラー処理
	//======================================================
	
	// エラーメッセージを返す
	func getErrorMessage() -> String? {
		return _errorMessage
	}
	
	// エラーコードを返す
	func getErrorCode() -> SoundPlayerErrorCode {
		return _errorCode
	}
	
	//======================================================
	// その他の関数
	//======================================================
	
	// 複数のファイルの総再生時間を算出
	func getAllDuration(files: [String], interval: Double = 0) -> Double {
		var allDuration = 0.0
		
		for file in files {
			_voicePlayer = makeAudioPlayer(file)
			if _voicePlayer == nil {
				audioPlayerDidFinishPlaying(_voicePlayer!, successfully: false)
				continue
			}
			let duration = _voicePlayer?.duration
			allDuration += duration! + interval
		}
		
		allDuration -= interval
		
		return allDuration
	}
	
	// ファイル名に拡張子を補う
	func supplySuffix(fileName: String) -> String {
		// 拡張子があるか？
		let loc = (fileName as NSString).rangeOfString(".").location
		if loc == NSNotFound {
			for suffix in SOUND_SUFFIXES {
				let fileNameWithSuffix = fileName + suffix
				let path = NSBundle.mainBundle().pathForResource(fileNameWithSuffix, ofType: "")
				
				if path != nil {
					return fileNameWithSuffix
				}
			}
		}
		
		return fileName
	}
	
	// ファイル名を受け取り、AVAudioPlayerのインスタンスを返す。エラーがあればnilを返す
	func makeAudioPlayer(res:String) -> AVAudioPlayer? {
		// 拡張子を補う
		let fileName = supplySuffix(res)
		
		// ファイルがなければnilを返す
		let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "")
		if path == nil {
			_errorCode = SoundPlayerErrorCode.FileNotFound
			_errorMessage += "=== error! === ファイルがありません！: " + fileName + "\n"
			print(_errorMessage)
			
			return nil
		}
		
		_errorCode = SoundPlayerErrorCode.NoError
		let url  = NSURL.fileURLWithPath(path!)
		
		var audioPlayer: AVAudioPlayer? = nil
		do {
			audioPlayer = try AVAudioPlayer(contentsOfURL: url)
		}
		catch let error as NSError {
			print(error)
		}
		
		return audioPlayer
	}
	
	// ファイル名の配列を受け取り、AVQueuePlayerのインスタンスを返す。
	func makeAVQuePlayer(files:[String]) -> AVQueuePlayer? {
		var items = [AVPlayerItem]()
		_errorCode    = SoundPlayerErrorCode.NoError
		
		for fileName in files {
			// 拡張子を補う
			let fullFileName = supplySuffix(fileName)
			
			// ファイルがなければnilを返す
			let path = NSBundle.mainBundle().pathForResource(fullFileName, ofType: "")
			if path == nil {
				_errorCode = SoundPlayerErrorCode.FileNotFound
				_errorMessage += "=== error! === ファイルがありません！: " + fileName + "\n"
				print(_errorMessage)
				
				continue
			}
			
			let url  = NSURL.fileURLWithPath(path!)
			let item = AVPlayerItem(URL: url)
			items.append(item)
		}
		
		return AVQueuePlayer(items: items)
	}
	
	// Double型を指定できる dispatch_after   （使い方）delay(2.0, { print("test.") })
	func dispatchAfterByOtherThread(delay:Double, closure:()->()) {
		dispatch_after(
			dispatch_time(
				DISPATCH_TIME_NOW,
				Int64(delay * Double(NSEC_PER_SEC))
			),
			dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), closure)
			//dispatch_get_main_queue(), closure)
	}
	
	//===========================================================
	// AVAudioPlayerDelegate
	//===========================================================
	
	public func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
		if _voicePlayer == player {
			if _voiceFiles.count == 0 {
				print("連続再生が終わりました。")
				_voicePlayer = nil
				NSNotificationCenter.defaultCenter().postNotificationName("voicePlayEnded", object: nil)
			} else {
				print("音声の連続再生が1つ終了。\(_voicePlayInterval)秒、間隔をあけます")
				// 一定秒後に再生を再開
				dispatch_after(
					dispatch_time(DISPATCH_TIME_NOW, Int64(_voicePlayInterval * Double(NSEC_PER_SEC))),
					dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
						self.advanceToNextVoice(player.volume)
					}
				)
			}
		} else {
			// 終了したplayerをnilに
			for i in 0 ..< _players.count {
				if _players[i] == player {
					print("再生終了 playerをnilにします")
					_players[i] = nil
				}
			}
		}
	}
	
	
}