cask "xiezuo" do
  version "5.31.0"
  name "XieZuo"
  desc "WPS 365 XieZuo"
  homepage "https://www.kimxz.com/"

  begin
    require 'json'
    require 'open-uri'

    major, minor, patch = version.split('.')
    platform = Hardware::CPU.arm? ? "mac-arm64" : "mac"
    res_url = "https://woa.wps.cn/bin/resource?major_ver=#{major}&minor_ver=#{minor}&patch_ver=#{patch}&platform=#{platform}&channel=stable"

    body = URI.open(res_url).read
    body = JSON.parse(body)

    cask_url = body["url"]
    
    puts "version #{version} real download url: #{cask_url}"
  rescue => e
    opoo "fetch resource url failed #{e.message}"
    cask_url = "invalid"
  end

  url cask_url
  sha256 :no_check

  app "xiezuo.app"

  zap trash: [
  ]
end