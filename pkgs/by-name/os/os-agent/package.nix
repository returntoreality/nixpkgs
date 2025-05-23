{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule rec {
  pname = "os-agent";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "home-assistant";
    repo = "os-agent";
    tag = "${version}";
    hash = "sha256-nny4gmSW8U9jdW//GXTn/zlmRhMbhf+4dbxju9Qs7zA=";
  };

  vendorHash = "sha256-9boWe/mvJ/C/I8B7b4hJgz2dEDgpKCNTE/8pVAsNTxg=";

  ldFlags = [
    "-X main.version="
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Daemon allowing to control OS features through D-Bus";
    homepage = "https://github.com/home-assistant/os-agent";
    changelog = "https://github.com/home-assistant/os-agent/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ genga898 ];
    mainProgram = "os-agent";
  };
}
