{ lib
, stdenvNoCC
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation {
  pname = "aleo-fonts";
  version = "unstable-2023-06-03";

  src = fetchFromGitHub {
    owner = "AlessioLaiso";
    repo = "aleo";
    rev = "ce875e48d9983031648e87f38b7a269f4fbf5eb5";
    hash = "sha256-HSxP5/sLHQTujBVt1u93625EXEc42lxpt8W1//6ngWM=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 fonts/variable/*.ttf -t $out/share/fonts/truetype/AleoFonts

    runHook postInstall
  '';

  meta = with lib; {
    description = "Slab serif typeface designed by Alessio Laiso";
    homepage = "https://github.com/AlessioLaiso/aleo";
    license = licenses.ofl;
    maintainers = with maintainers; [ donovanglover ];
    platforms = platforms.all;
  };
}
