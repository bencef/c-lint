{stdenv, haskellPackages, makeWrapper, clang}:

let
  haskell = haskellPackages.ghcWithPackages (pkgs: with pkgs; [ turtle ]);
in
stdenv.mkDerivation {
  name    = "c++lint";
  version = "0.1.0";
  src     = ./.;

  buildInputs = [ haskell makeWrapper clang ];
  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/{bin,libexec}
    install -m 555 c++lint "$out/libexec"
    makeWrapper "$out/libexec/c++lint" "$out/bin/c++lint" \
      --set CPPLINT_INCLUDE_DIRS "${stdenv.cc.cc}/include/c++/*/" \
      --suffix CPPLINT_INCLUDE_DIRS : "${stdenv.cc.cc}/include/c++/*/*-linux-*/" \
      --suffix CPPLINT_INCLUDE_DIRS : "${stdenv.cc.libc_dev}/include/"
  '';
}
