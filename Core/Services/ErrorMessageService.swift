import Foundation

enum ErrorMessageService {
    static func message(for error: Error) -> String {
        if let e = error as? KeychainServiceError {
            switch e {
            case .unhandledStatus(let status):
                return "系统密钥存取失败（\(status)），请重试。"
            }
        }

        if let e = error as? AppConfigServiceError {
            switch e {
            case .emptyAPIKey:
                return "请先在设置中填写 API Key。"
            case .emptyBaseURL:
                return "请先在设置中填写 Base URL。"
            }
        }

        if let e = error as? DictionaryServiceError {
            switch e {
            case .noMatch:
                return "未找到对应英文词，请换一个中文词或直接输入英文。"
            }
        }

        if let e = error as? NetworkServiceError {
            switch e {
            case .noNetwork:
                return "当前无网络连接，请联网后再生成。"
            }
        }

        if let e = error as? URLError {
            switch e.code {
            case .timedOut:
                return "请求超时（超过15秒），请稍后重试。"
            case .notConnectedToInternet:
                return "当前无网络连接，请联网后再生成。"
            case .cannotFindHost, .cannotConnectToHost:
                return "无法连接服务地址，请检查 Base URL。"
            case .networkConnectionLost:
                return "网络连接中断，请重试。"
            default:
                return "网络请求失败（\(e.code.rawValue)），请稍后重试。"
            }
        }

        if let e = error as? AIServiceError {
            switch e {
            case .emptyAPIKey:
                return "API Key 为空，请在设置中填写。"
            case .invalidBaseURL:
                return "Base URL 无效，请检查设置。"
            case .invalidJSONBody:
                return "请求内容格式错误，请稍后重试。"
            case .invalidHTTPResponse:
                return "网络响应异常，请稍后重试。"
            case .httpStatus(let code):
                if code == 404 {
                    return "请求地址不存在（HTTP 404）。DeepSeek 推荐填写 https://api.deepseek.com 或 https://api.deepseek.com/chat/completions。"
                }
                return "请求失败（HTTP \(code)），请检查网络或密钥权限。"
            case .emptyAssistantContent:
                return "AI 未返回有效内容，请重试。"
            }
        }

        if let e = error as? JSONValidatorError {
            switch e {
            case .invalidJSONObject:
                return "AI 返回内容不是有效 JSON，请重试。"
            case .topLevelKeysMismatch:
                return "AI 返回字段缺失，请重试。"
            case .morphologyKeysMismatch:
                return "AI 返回词根/前缀/后缀字段不完整，请重试。"
            case .invalidStringArray:
                return "AI 返回的列表字段格式错误，请重试。"
            case .emptyWord:
                return "AI 返回的单词为空，请重试。"
            }
        }

        if let e = error as? AIPipelineError {
            switch e {
            case .invalidAssistantJSON, .schemaValidationFailed:
                return "AI 返回格式不符合要求，请重试。"
            case .failedAfterRetryLimit(let lastErrorDescription):
                return "AI 输出多次不合规（最后错误：\(lastErrorDescription)）。"
            }
        }

        if error is DecodingError {
            return "服务返回格式不兼容，请检查 Base URL 或模型配置。"
        }

        if (error as NSError).domain == NSCocoaErrorDomain {
            return "本地文件读写失败，请重试。"
        }

        return "发生未知错误：\(String(describing: error))"
    }
}
