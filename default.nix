{stdenv, haskellPackages, makeWrapper, clang}:

let
  haskell = haskellPackages.ghcWithPackages (pkgs: with pkgs; [ turtle ]);
in
stdenv.mkDerivation {
  name    = "c++lint";
  version = "0.1.0";
  src     = ./.;

  buildInputs = [ haskell makeWrapper clang ];
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  CC_VERSION = stdenv.cc.cc.version;

  buildPhase = ''
    ghc -O2 -threaded c++lint.hs -o c++lint
  '';

  installPhase = ''
    mkdir -p $out/{bin,libexec}
    install -m 555 c++lint "$out/libexec"
    CC_INCLUDE="${stdenv.cc.cc}/include/c++/$CC_VERSION"
    # FIX_ME how to get 'x86_64-unknown-linux-gnu' in a portable way?
    makeWrapper "$out/libexec/c++lint" "$out/bin/c++lint" \
      --suffix CPPLINT_INCLUDE_DIRS : "$CC_INCLUDE/" \
      --suffix CPPLINT_INCLUDE_DIRS : "$CC_INCLUDE/x86_64-unknown-linux-gnu/" \
      --suffix CPPLINT_INCLUDE_DIRS : "${stdenv.cc.libc_dev}/include/"
  '';
}
