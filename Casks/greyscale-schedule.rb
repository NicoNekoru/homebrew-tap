cask "greyscale-schedule" do
  version "1.10.0"
  sha256 "11739e895ef83464f88679f2cf0b553e6c876b817436316da07e02ec0b86d807"

  url "https://github.com/NicoNekoru/GreyscaleSchedule/releases/download/v#{version}/GreyscaleSchedule-v#{version}-macos-arm64.dmg"
  name "Greyscale Schedule"
  desc "Scheduled greyscale display filter with a native Control Centre toggle"
  homepage "https://github.com/NicoNekoru/GreyscaleSchedule"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :tahoe

  app "Greyscale Schedule.app"

  uninstall quit: "local.greyscale-schedule"

  # Keep the schedule and tile intact during ordinary upgrades. Complete
  # user-requested cleanup uses the app's Uninstall button and brew --zap.
  zap launchctl: [
        "local.greyscale-schedule",
        "local.greyscale-schedule.control-agent",
      ],
      trash:     [
        "~/Library/Application Support/Greyscale Schedule",
        "~/Library/Caches/local.greyscale-schedule",
        "~/Library/Containers/local.greyscale-schedule.control2",
        "~/Library/Logs/Greyscale Schedule.log",
        "~/Library/Preferences/local.greyscale-schedule.plist",
        "~/Library/Saved Application State/local.greyscale-schedule.savedState",
      ]

  caveats <<~EOS
    Open Greyscale Schedule once and click Save Schedule.
    Click Install / Refresh Control to add the Control Centre tile.
    Later tile clicks stay windowless.

    For complete removal, use Uninstall in the app before
    running brew uninstall --cask --zap greyscale-schedule.
  EOS
end
