{ lib, pkgs, ... }:

let
  externalExtensionsDir = "Library/Application Support/BraveSoftware/Brave-Browser/External Extensions";

  # Auto-install Brave extensions on next browser launch. Brave reads each
  # JSON file in `External Extensions/` and pulls the matching extension
  # from the Chrome Web Store. Extensions can still be disabled or removed
  # from chrome://extensions.
  extensions = {
    bitwarden     = "nngceckbapebfimnlniiiahkandclblb";
    reactDevtools = "fmkadmapgofadopljbjfkapdkoienihi";
  };

  mkExtensionFile = id: {
    name = "${externalExtensionsDir}/${id}.json";
    value.text = builtins.toJSON {
      external_update_url = "https://clients2.google.com/service/update2/crx";
    };
  };
in
{
  home.file = builtins.listToAttrs (
    map mkExtensionFile (builtins.attrValues extensions)
  );

  # macOS shows a confirmation dialog the first time the default browser
  # changes; click "Use Brave Browser". `defaultbrowser` is idempotent —
  # we only call it when Brave isn't already default to avoid re-prompts.
  # Brave is listed as "browser" because kerma/defaultbrowser doesn't have
  # an alias for `com.brave.Browser`.
  home.activation.setDefaultBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "/Applications/Brave Browser.app" ]; then
      if ! ${pkgs.defaultbrowser}/bin/defaultbrowser 2>/dev/null | grep -q '^\* *browser$'; then
        run ${pkgs.defaultbrowser}/bin/defaultbrowser browser
      fi
    fi
  '';
}
