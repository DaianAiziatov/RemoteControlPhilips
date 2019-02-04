import Foundation

final class APIClient {

    var ipAddress: String

    private lazy var baseURL: URL = {
        let URLString = "http://\(self.ipAddress):1925"
        return URL(string: URLString)!
    }()

    private(set) lazy var session: URLSession = {
        return URLSession.shared
    }()

    init(ipAddress: String) {
        self.ipAddress = ipAddress
    }

    func fetchingSystemInfo(completion: @escaping (Result<SystemInfo, DataResponseError>) -> Void) {
        let urlRequest = URLRequest(url: baseURL.appendingPathComponent(APIRequest.systemNamePath))
        var encodedURLRequest = urlRequest.encode(with: nil)
        encodedURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: encodedURLRequest) { [weak self] data, response, error in
            guard let `self` = self else {
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.hasSuccessStatusCode,
                let data = data else {
                    completion(Result.failure(DataResponseError.network))
                    return
            }

            guard var systemInfo = try? JSONDecoder().decode(SystemInfo.self, from: data) else {
                completion(Result.failure(DataResponseError.decoding))
                return
            }

            systemInfo.ipAddress = self.ipAddress
            completion(Result.success(systemInfo))
        }

        task.resume()
    }

}
