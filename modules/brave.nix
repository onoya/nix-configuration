{ ... }:

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
}
