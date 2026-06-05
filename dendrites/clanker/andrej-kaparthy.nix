{pkgs, ...}:
pkgs.fetchurl {
  url = "https://github.com/multica-ai/andrej-karpathy-skills/raw/refs/heads/main/CLAUDE.md";
  hash = "sha256-aUotch5Bw4Xz20koOMIymYJt9bqYCeOwchqscAIeGWo=";
}
