//
//  File.swift
//  
//
//  Created by yangjian on 2023/10/18.
//

import Foundation
import GoogleMobileAds
import UIKit

public enum GADPreloadError: Error {
    // 超限
    case isLimited
    // 加载中
    case loading
    // 广告位错误
    case postion
    // 没得配置
    case config
}

extension GADUtil {
    
    @MainActor
    public func dismiss() async {
        return await withCheckedContinuation { contin in
            if let view = (UIApplication.shared.connectedScenes.filter({$0 is UIWindowScene}).first as? UIWindowScene)?.keyWindow, let vc = view.rootViewController {
                if let presentedVC = vc.presentedViewController {
                    if let persentedPresentedVC = presentedVC.presentedViewController {
                        persentedPresentedVC.dismiss(animated: true) {
                            presentedVC.dismiss(animated: true) {
                                contin.resume()
                            }
                        }
                        return
                    }
                    presentedVC.dismiss(animated: true) {
                        contin.resume()
                    }
                }
                return
            }
            contin.resume()
        }
    }
    
    @discardableResult
    public func load(_ position: GADPosition) async throws -> GADBaseModel? {
        let ads = ads.filter{
            $0.position == position
        }
        return try await ads.first?.beginAddWaterFall()
    }
    
    @discardableResult
    public func show(_ position: GADPosition) async -> GADBaseModel? {
        debugPrint("[ad] 开始展示")
        return await withCheckedContinuation { continuation in
            show(position) { model in
                debugPrint("[ad] 展示")
                continuation.resume(returning: model)
            }
        }
    }
    
}

extension GADLoadModel {
    
    func beginAddWaterFall() async throws -> GADBaseModel? {
        if !isPreloadingAD , !isPreloadedAD {
            NSLog("[AD] (\(position.rawValue) start to prepareLoad.--------------------")
            guard let array: [GADModel] = GADUtil.share.config?.arrayWith(position), array.count > 0 else {
                NSLog("[AD] (\(position.rawValue)) no configer.")
                throw GADPreloadError.config
            }
            NSLog("[AD] (\(position.rawValue)) start to load array = \(array.count)")
            return try await prepareLoadAd(array)
        } else if isPreloadedAD {
            NSLog("[AD] (\(position.rawValue)) loaded ad.")
            return loadedArray.first
        } else if isPreloadingAD {
            NSLog("[AD] (\(position.rawValue)) loading ad.")
            throw GADPreloadError.loading
        }
        return .none
    }
    
    func prepareLoadAd(_ array: [GADModel], at index: Int = 0)  async throws -> GADBaseModel? {
        if  index >= array.count {
            NSLog("[AD] (\(position.rawValue)) prepare Load Ad Failed, no more avaliable config.")
            throw GADPreloadError.config
        }
        NSLog("[AD] (\(position)) prepareLoaded.")
        if GADUtil.share.isGADLimited {
            NSLog("[AD] (\(position.rawValue)) 用戶超限制。")
            throw GADPreloadError.isLimited
        }
        if isPreloadedAD {
            NSLog("[AD] (\(position.rawValue)) 已經加載完成。")
            return loadedArray.first
        }
        if isPreloadingAD {
            NSLog("[AD] (\(position.rawValue)) 正在加載中.")
            throw GADPreloadError.loading
        }
        var ad: GADBaseModel? = nil
        if position == .native {
            ad = GADNativeModel(model: array[index])
        } else if position == .interstitial {
            ad = GADInterstitialModel(model: array[index])
        }
        guard let ad = ad  else {
            NSLog("[AD] (\(position.rawValue)) 广告位错误.")
            throw GADPreloadError.config
        }
        ad.position = position
        loadingArray.append(ad)
        let result = await ad.loadAD()
        loadingArray = loadingArray.filter({ loadingAd in
            return ad.id != loadingAd.id
        })
        if result.0 {
            loadedArray.append(ad)
            return ad
        }
        NSLog("[AD] (\(self.position.rawValue)) Load Ad Failed: try reload at index: \(index + 1).")
        return try await prepareLoadAd(array, at: index + 1)
    }
}
extension GADBaseModel {
    
    @objc public func loadAD() async -> (Bool, String) {
        await withCheckedContinuation({ continuation in
            loadAd { result, error in
                continuation.resume(returning: (result, error))
            }
        })
    }
    
}

