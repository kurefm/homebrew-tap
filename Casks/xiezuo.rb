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
  generated_script "xiezuo-update-lock.sh", content: <<~SH
    #!/bin/sh
    set -eu
    case "$1" in
      lock|unlock) ;;
      *) exit 64 ;;
    esac
    if [ -L update ] || { [ -e update ] && [ ! -d update ]; }; then
      [ "$1" = unlock ] && exit 0
      echo "Refusing to replace a non-directory update cache: $PWD/update" >&2
      exit 1
    fi
    if [ -d update ]; then
      /usr/bin/chflags nouchg update
    fi
    if [ "$1" = lock ]; then
      # Discard staged updates before locking; existing payloads can otherwise still run.
      /bin/rm -rf update
      /bin/mkdir update
      /usr/bin/chflags uchg update
    fi
  SH

  # shortcut: blocks the current macOS updater staging path; recheck when upgrading XieZuo.
  postflight_steps [
    { type: "mkdir_p", path: { path: "Library/Application Support/xiezuo", base: "home" } },
    {
      type:           "run",
      command:        { path: "xiezuo-update-lock.sh", base: "staged_path" },
      args:           ["lock"],
      chdir:          { path: "Library/Application Support/xiezuo", base: "home" },
      writable_paths: [{ path: "Library/Application Support/xiezuo", base: "home" }],
    },
  ]

  uninstall_preflight_steps [
    {
      type:           "run",
      command:        { path: "xiezuo-update-lock.sh", base: "staged_path" },
      args:           ["unlock"],
      chdir:          { path: "Library/Application Support/xiezuo", base: "home" },
      writable_paths: [{ path: "Library/Application Support/xiezuo", base: "home" }],
      guards:         [{ condition: "if_exists", path: "Library/Application Support/xiezuo", base: "home" }],
    },
  ]

  zap trash: [
    "~/Library/Application Support/Kingsoft/XieZuo",
    "~/Library/Application Support/xiezuo",
    "~/Library/Logs/Global/wps_xiezuo_online*",
    "~/Library/Logs/xiezuo",
    "~/Library/Preferences/com.kingsoft.xiezuo.plist",
  ]

  caveats <<~EOS
    This cask clears staged updates and locks ~/Library/Application Support/xiezuo/update
    for the installing user to block XieZuo's automatic app replacement.
    Quit XieZuo before installing or reinstalling this cask.
    Update checks, downloads and prompts may still occur. Use brew upgrade to update.
    To allow in-app updates again:
      chflags nouchg "$HOME/Library/Application Support/xiezuo/update"
  EOS
end
