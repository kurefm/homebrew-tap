cask "xiezuo" do
  version "5.34.0"
  name "XieZuo"
  desc "WPS 365 XieZuo"
  homepage "https://www.kimxz.com/"

  def versiond_url(version)
    require 'json'
    require 'open-uri'

    major, minor, patch = version.split('.')
    platform = Hardware::CPU.arm? ? "mac-arm64" : "mac"

    begin
      res_url = "https://woa.wps.cn/bin/resource?major_ver=#{major}&minor_ver=#{minor}&patch_ver=#{patch}&platform=#{platform}&channel=stable"

      body = URI.open(res_url).read
      body = JSON.parse(body)

      puts "version #{version} real download url: #{body["url"]}"
      return body["url"]
    rescue => e
      opoo "fetch resource url failed #{e.message}"
      return nil
    end
  end

  url versiond_url(version)
  sha256 "21fbacd4fec8a64542a7f591d04ecd8d183aecf094122971ea8f6e7b7a04d2ec"

  app "xiezuo.app"

  zap trash: [
    "~/Library/Application Support/xiezuo/",
    "~/Library/Application Support/Kingsoft/XieZuo/",
    "~/Library/Logs/xiezuo/",
    "~/Library/Logs/Global/wps_xiezuo_online*",
    "~/Library/Preferences/com.kingsoft.xiezuo.plist"
  ]
end