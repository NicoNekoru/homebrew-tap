# Reference cask file for the apfs-fastindex tap.
#
# The canonical copy lives in the NicoNekoru/homebrew-apfs-fastindex
# repo at `Casks/apfs-fastindex.rb` — that's the path Homebrew's
# tap-resolution machinery looks for. This file in the main
# `apfs-fastindex` repo is the **template** the release flow
# regenerates on every `--publish`, alongside the .dmg.
#
# When you cut a release:
#
#   1. `./make-release.sh --publish --tag vX.Y.Z` here.
#   2. Script writes the `.dmg`, computes its SHA-256, and
#      overwrites this file with the right version + sha256.
#   3. Copy the resulting `homebrew/Casks/apfs-fastindex.rb`
#      into the `homebrew-apfs-fastindex` tap repo, commit,
#      push. Users see the update on their next
#      `brew update && brew upgrade --cask apfs-fastindex`.
#
# Users install via:
#
#   brew tap NicoNekoru/apfs-fastindex
#   brew install --cask apfs-fastindex
#
# Homebrew Cask strips the `com.apple.quarantine` xattr from
# downloaded `.app`s automatically, so users skip the
# right-click-→-Open Gatekeeper friction that ad-hoc-signed
# direct downloads otherwise produce.

cask "apfs-fastindex" do
  version "0.3.2"
  sha256 "e6893af45856a8153f9a3e9325f4a7b32610e0ceb351e4ba33cec4b40689f114"

  url "https://github.com/NicoNekoru/apfs-fastindex/releases/download/v#{version}/ApfsFastindex-v#{version}-macos-arm64.dmg"
  name "apfs-fastindex"
  desc "Fast disk-usage visualizer for macOS / APFS"
  homepage "https://github.com/NicoNekoru/apfs-fastindex"

  # apfs-fastindex is built arm64-only today (the
  # `make-release.sh` flow targets the build host's arch). If
  # an Intel build is added later, remove this line and add an
  # `arch intel: "...", arm: "..."` block at the top.
  depends_on arch: :arm64

  # macOS 13+ matches CFBundleSupportedPlatforms in the
  # Info.plist; brew rejects the install with a clear message
  # rather than letting the app launch and crash on older
  # systems.
  depends_on macos: ">= :ventura"

  app "ApfsFastindex.app"

  # Post-install cleanup. The app is ad-hoc signed (no Developer
  # ID, no notarization). macOS Sonoma 14+ shows the "Apple could
  # not verify [App] is free of malware" dialog on first launch
  # whenever it sees ANY extended attribute residue, not just
  # `com.apple.quarantine`. Brew's default strip targets only
  # `com.apple.quarantine`; clear everything else (provenance,
  # WhereFroms, etc.) so the first launch goes through cleanly.
  #
  # `-cr` clears all xattrs recursively. We do this against the
  # installed `.app` (whichever `appdir` resolves to — typically
  # `/Applications`) and every nested helper, which is where
  # Sparkle.framework's XPC services + Updater.app live.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/ApfsFastindex.app"],
                   sudo: false
  end

  # First-launch caveats. Even with all xattrs cleared, macOS
  # 14.0+ may still pop the verification dialog on the very
  # first launch. The user has to either:
  #   - right-click the app, pick Open, then click Open again
  #     in the confirmation sheet, or
  #   - go to Settings > Privacy & Security and click "Open
  #     Anyway" on the warning shown there.
  # Either path is one-time per install.
  caveats <<~EOS
    apfs-fastindex is ad-hoc signed (no Developer ID). On first
    launch macOS may show:

        "Apple could not verify apfs-fastindex is free of malware"

    Right-click the app in /Applications and pick Open, then
    click Open again to confirm. Subsequent launches go through
    without the prompt. This is a one-time step per install.

    If you'd prefer the no-prompt experience, a notarized build
    requires the maintainer to enroll in the Apple Developer
    Program ($99/yr). See the project README for the current
    plan.
  EOS

  # `zap` removes user-level state on `brew uninstall --zap`.
  # Conservative list — only the prefs file we know we write.
  # Sparkle's own state lives in the same prefs file.
  zap trash: [
    "~/Library/Preferences/com.apfsfastindex.app.plist",
  ]
end
