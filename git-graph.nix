{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "git-graph";
  version = "v0.7.0";

  src = fetchFromGitHub {
    owner = "mlange-42";
    repo = "git-graph";
    tag = version;
    hash = "sha256-9GFwxWYDnH3kKDWpxgh7ciSLB1Zr2zExxIrIrhycmZY=";
  };

  cargoHash = "sha256-hKCEAXZj2ExSamvtl10RnAiuV9w6yOYdnsXm0gplFSU=";

  meta = with lib; {
    description = "Command line tool to show clear git graphs arranged for your branching model";
    homepage = "https://github.com/mlange-42/git-graph";
    license = licenses.mit;
    maintainers = with maintainers; [
      cafkafk
      matthiasbeyer
    ];
    mainProgram = "git-graph";
  };
}