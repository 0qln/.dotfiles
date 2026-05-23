profile: {pkgs, ...}: {
  programs.vscode.profiles.${profile} = {
    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # {
      #   name = "background-cover";
      #   publisher = "manasxx";
      #   version = "2.7.0";
      #   sha256 = "sha256-5sFtFiq0ocV0x/OfhW50hvSz0IXXRn8MK5Jd6zC5F48=";
      # }
      # {
      #   name = "background";
      #   publisher = "thomaszhang";
      #   version = "1.1.1";
      #   sha256 = "sha256-aB1rdCp2csyDIV7XgGMJnP6bKUiENI5Ortt2dnE960M=";
      # }
      # {
      #   name = "background";
      #   publisher = "shalldie";
      #   version = "2.0.3";
      #   sha256 = "sha256-tvGHJvU3vJqlx5bHP8xxTfdKw9s9etevV1pLo2Xd8DI=";
      # }
      # {
      #   name = "code-background";
      #   publisher = "katsute";
      #   version = "3.1.1";
      #   sha256 = "sha256-HCSQi1EIXD1O/cIpM35HG+gmahKpDN+mt4FG0qT10lc=";
      # }
    ];

    userSettings = {
      # "background.useInvertedOpacity" = true;
      # "background.autoInstall" = false;
    };
  };
}
