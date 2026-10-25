require "download_strategy"

module Utils
  class XiezuoDownloadStrategy < CurlDownloadStrategy
    private

    # Keep the versioned API URL as the cache key; resolve signed URLs only in the downloader.
    def resolve_url_basename_time_file_size(url, timeout: nil)
      return super if url != self.url

      end_time = Time.now + timeout if timeout
      download_url = resource_url(timeout:)
      super(download_url, timeout: ::Utils::Timer.remaining!(end_time))
    end

    def resource_url(timeout: nil)
      @resource_url ||= begin
        result = curl_output(
          "--fail", "--silent", "--location", "--connect-timeout", "10", "--max-time", "30", url,
          timeout: [timeout, 30].compact.min
        )
        result.assert_success!
        resource = JSON.parse(result.stdout)
        download_url = resource["url"] if resource.is_a?(Hash)
        uri = URI.parse(download_url) if download_url.is_a?(String)

        if !uri.is_a?(URI::HTTPS) || uri.host.blank?
          raise CurlDownloadStrategyError.new(url, "Resource API did not return an HTTPS download URL.")
        end

        download_url
      end
    rescue JSON::ParserError, URI::InvalidURIError
      raise CurlDownloadStrategyError.new(url, "Resource API returned an invalid download response.")
    end
  end
end

cask "xiezuo" do
  arch arm: "mac-arm64", intel: "mac"

  version "5.55.0"
  sha256 arm:   "58f563b55492b521df00e40c6355b84064fc924de6524aac13bd83e1c7e38f07",
         intel: "7b63bb150e4480f6e68ecf7ffd131fc8946a65dc833237c5a9dacf7f56b71cfb"

  url "https://woa.wps.cn/bin/resource?major_ver=#{version.major}&minor_ver=#{version.minor}&patch_ver=#{version.patch}&platform=#{arch}&channel=stable",
      using:   Utils::XiezuoDownloadStrategy,
      referer: "https://woa.wps.cn/"
  name "XieZuo"
  desc "WPS 365 XieZuo"
  homepage "https://www.kimxz.com/"

  livecheck do
    url "https://woa.wps.cn/bin/version?platform=#{arch}&channel=stable"
    strategy :json do |json|
      newest = json.fetch("newest")
      %w[major minor patch].map { |key| newest.fetch(key) }.join(".")
    end
  end

  depends_on :macos

  app "xiezuo.app"

  zap trash: [
    "~/Library/Application Support/Kingsoft/XieZuo",
    "~/Library/Application Support/xiezuo",
    "~/Library/Logs/Global/wps_xiezuo_online*",
    "~/Library/Logs/xiezuo",
    "~/Library/Preferences/com.kingsoft.xiezuo.plist",
  ]
end
