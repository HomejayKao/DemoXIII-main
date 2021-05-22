//
//  NetworkController.swift
//  DemoX
//
//  Created by homejay on 2021/2/15.
//
//以下幾種都是網路抓資料常見的檔名結尾。
//Controller
//Service
//Client
//Manager

import Foundation
import UIKit
import Alamofire //第三方套件

class NetworkController {
    static let shared = NetworkController()
    
    let imageCache = NSCache<NSURL,UIImage>()
    
    func createAirtableRecordAPI(urlString:String? ,postInfo:PostInfo? ) {
        if let urlString = urlString ,
           let url = URL(string: urlString) {
            
            var urlRequest = URLRequest(url: url)
            
            urlRequest.httpMethod = "POST"
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            urlRequest.addValue("Bearer keyq4PyNOUPCWHhYM", forHTTPHeaderField: "Authorization")
            
            urlRequest.addValue("brw=brwqizWYUpCISdV6o", forHTTPHeaderField: "Cookie")
            
            let jsonEncoder = JSONEncoder()
            
            do {
                let data = try jsonEncoder.encode(postInfo)
                
                urlRequest.httpBody = data //Post要設定Body
                
                //let content = String(data: data, encoding: .utf8)
                //print(content)//可以看輸出來的格式長怎樣
                
                URLSession.shared.uploadTask(with: urlRequest, from: data).resume()
                
            } catch {
                print(error)
            }
            
            /* 不同於此方式 是因為 上傳完後 沒有要後續執行甚麼
             URLSession.shared.uploadTask(with: urlRequest, from: data) { (data, response, error) in
             if let data = data {
             print("ok")
             }else{
             print(error)
             }
             }.resume()
             */
        }
    }
    
    func fetchAirtableAPI( urlString:String? , complete: @escaping (Result<InfoResponse,Error>)->Void ) {
        
        if let urlString = urlString, //?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlString)
        {
            var request = URLRequest(url: url, timeoutInterval: Double.infinity)
            
            request.addValue("Bearer keyq4PyNOUPCWHhYM", forHTTPHeaderField: "Authorization")
            request.addValue("brw=brwqizWYUpCISdV6o", forHTTPHeaderField: "Cookie")

            request.httpMethod = "GET"
            
            //print("request.allHTTPHeaderFields==========",request.allHTTPHeaderFields)
            //print("request.httpBody===========",request.httpBody)
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                let jsonDecoder = JSONDecoder()
                
                if let data = data {
                    do {

                        let infoResponse = try jsonDecoder.decode(InfoResponse.self, from: data)
                        //let stringData = String(data: data, encoding: .utf8)
                        //print("------------------stringData",stringData)
                        complete(.success(infoResponse))
                    } catch {
                        //let stringData = String(data: data, encoding: .utf8)
                        //print("___________________",stringData)
                        complete(.failure(error))
                    }
                }
            }.resume()
        }
        
    }
    
    func fetchYoutubePlaylistAPI( urlString:String? , complete: @escaping (Result<PlaylistResponse,Error>)->Void ) {
        
        if let urlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlString)
        {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: .infinity)
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                let jsonDecoder = JSONDecoder()
                
                if let data = data {
                    do {
                        let playListResponse = try jsonDecoder.decode(PlaylistResponse.self, from: data)
                        
                        complete(.success(playListResponse))
                    } catch {
                        complete(.failure(error))
                    }
                }
            }.resume()
        }
    }
    
    func fetchYoutubeSearchAPI( urlString:String? , complete: @escaping (Result<SearchlistResponse,Error>)->Void ) {
        
        if let urlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlString)
        {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                let jsonDecoder = JSONDecoder()
                
                if let data = data {
                    do {
                        let searchlistResponse = try jsonDecoder.decode(SearchlistResponse.self, from: data)
                        
                        complete(.success(searchlistResponse))
                    } catch {
                        complete(.failure(error))
                    }
                }
            }.resume()
            
        }
    }
    
    func fetchYoutubeChannelAPI( urlString:String? , complete: @escaping (Result<ChannelResponse,Error>)->Void ) {
        
        if let urlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlString)
        {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                let jsonDecoder = JSONDecoder()
                
                if let data = data {
                    do {
                        let channelResponse = try jsonDecoder.decode(ChannelResponse.self, from: data)
                        
                        complete(.success(channelResponse))
                    } catch {
                        complete(.failure(error))
                    }
                }
            }.resume()
            
        }
    }
    
    func fetchTwitterProfileAPI ( urlString:String? , complete: @escaping (Result<ProfileResponse,Error>)->Void) {
        
        if let urlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlString)
        {
            var urlRequest = URLRequest(url: url , timeoutInterval: Double.infinity)
            
            urlRequest.addValue("Bearer AAAAAAAAAAAAAAAAAAAAAJPIMQEAAAAA97PK108pfgNZ8AEiNfxCrGTgKQk%3DUkH2508lac4LKX23KBV05oJw3tPI5fiCzRZGhhPQcWoHiosH38", forHTTPHeaderField: "Authorization")
            
            urlRequest.addValue("guest_id=v1%3A161259620765628361; personalization_id=\"v1_grMxqEG+NZtJNTFKB6UqjQ==\"", forHTTPHeaderField: "Cookie")
            
            urlRequest.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                let jsonDecoder = JSONDecoder()
                
                if let data = data {
                    do {
                        let profileResponse = try jsonDecoder.decode(ProfileResponse.self, from: data)
                        complete(.success(profileResponse))
                    } catch {
                        complete(.failure(error))
                    }
                }
            }.resume()
        }
    }
    
    func fetchImage(url:URL? , complete: @escaping (Result<UIImage,Error>)->Void) {
        
        if let url = url {
            /* 懷疑有可能是因為快取，導致久了取不到最新的資料，故先隱藏
            if let image = imageCache.object(forKey: url as NSURL) {
                complete(.success(image))
                return
            }
            */
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data,
                   let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: url as NSURL)
                    
                    complete(.success(image))
                }else{
                    if let error = error {
                        complete(.failure(error))
                    }
                }
            }.resume()
        }
    }
    
    func uploadImageToImgur(uiImage: UIImage ,complete: @escaping (Result<URL,Error>)->Void ) {
        let headers: HTTPHeaders = [
            "Authorization": "Client-ID 74b671d9170a14e",
        ]
        
//        AF.upload(multipartFormData: <#T##(MultipartFormData) -> Void#>, to: <#T##URLConvertible#>, usingThreshold: <#T##UInt64#>, method: <#T##HTTPMethod#>, headers: <#T##HTTPHeaders?#>, interceptor: <#T##RequestInterceptor?#>, fileManager: <#T##FileManager#>, requestModifier: <#T##Session.RequestModifier?##Session.RequestModifier?##(inout URLRequest) throws -> Void#>
        
        AF.upload(multipartFormData: { (data) in
            let imageData = uiImage.jpegData(compressionQuality: 0.9)
            data.append(imageData!, withName: "image")
            
        }, to: "https://api.imgur.com/3/image", headers: headers).responseDecodable(of: UploadImgur.self, queue: .main, decoder: JSONDecoder()) { (response) in
            
            switch response.result {
            case .success(let result):
                print(result.data.link)
                complete(.success(result.data.link))
                
            case .failure(let error):
                print(error)
                complete(.failure(error))
                
            }
        }
    }
    
    deinit {
        print("NetworkController物件＿＿＿＿＿＿＿＿＿＿＿死亡")
    }
    
    
   

    
    
}
