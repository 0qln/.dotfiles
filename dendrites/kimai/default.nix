{
  inputs,
  self,
  ...
}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.kimai = {config, ...}: let
    cfg = config.modules.kimai;
  in {
    options.modules.kimai = {
      enable = mkEnableOption "Kimai distrobox system dependencies";
    };

    imports = [
      self.nixosModules.distrobox
    ];

    config = mkIf cfg.enable {
      modules.distrobox.enable = true;
    };
  };

  flake.homeModules.kimai = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.modules.kimai;
    containerName = "kimai_ubuntu";
    containerHome = "${config.home.homeDirectory}/.distrobox/${containerName}";
    inherit (config.home) username;
  in {
    options.modules.kimai = {
      enable = mkEnableOption "kimai";
      containerName = mkOption {
        type = types.str;
        default = "kimai_ubuntu";
        description = "Name of the distrobox container running Kimai.";
      };
      branch = mkOption {
        type = types.str;
        default = "main";
        description = "Kimai git branch to clone.";
      };
      dbName = mkOption {
        type = types.str;
        default = "kimai_dev";
        description = "MySQL database name for the Kimai dev instance.";
      };
    };

    imports = [
      self.homeModules.distrobox
    ];

    config = mkIf cfg.enable {
      home.activation = {
        kimai-distrobox-config_ssh = config.utils.mkCopy {
          source = "${config.home.homeDirectory}/.ssh";
          destPath = "${containerHome}/.ssh";
          newMode = "700";
          deps = ["mutableFileGeneration" "writeBoundary"];
        };

        kimai-distrobox-config_git = config.utils.mkCopy {
          source = "${config.xdg.configHome}/git";
          destPath = "${containerHome}/.config/git";
          newMode = "700";
          deps = ["mutableFileGeneration" "writeBoundary"];
        };
      };

      home.file.".distrobox/${containerName}/setup-container.sh" = {
        executable = true;
        force = true;
        text =
          # bash
          ''
            #!/usr/bin/env bash

            set -e

            sudo apt-get update -y

            # install PHP 8.2, required extensions, and dev tools
            sudo apt-get install -y \
              software-properties-common \
              lsb-release \
              apt-transport-https \
              ca-certificates

            sudo add-apt-repository -y ppa:ondrej/php
            sudo apt-get update -y

            sudo apt-get install -y \
              php8.2 \
              php8.2-cli \
              php8.2-curl \
              php8.2-gd \
              php8.2-intl \
              php8.2-mbstring \
              php8.2-mysql \
              php8.2-sqlite3 \
              php8.2-xml \
              php8.2-zip \
              php8.2-opcache \
              php8.2-bcmath \
              php8.2-pdo \
              unzip \
              git \
              curl \
              mariadb-server \
              mariadb-client \
              nodejs \
              npm

            # install composer
            if ! command -v composer &>/dev/null; then
              EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
              php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
              ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
              if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
                echo "Composer installer checksum mismatch" >&2
                rm composer-setup.php
                exit 1
              fi
              sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
              rm composer-setup.php
            fi

            # set up MariaDB
            sudo service mariadb start
            sudo mysql -e "CREATE DATABASE IF NOT EXISTS ${cfg.dbName} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || true
            sudo mysql -e "CREATE USER IF NOT EXISTS '${username}'@'localhost' IDENTIFIED BY 'kimai';" 2>/dev/null || true
            sudo mysql -e "GRANT ALL PRIVILEGES ON ${cfg.dbName}.* TO '${username}'@'localhost'; FLUSH PRIVILEGES;" 2>/dev/null || true

            # clone kimai source if not already present
            if [ ! -d "${containerHome}/repos/kimai" ]; then
              mkdir -p "${containerHome}/repos"
              git clone \
                --branch ${cfg.branch} \
                --single-branch \
                https://github.com/kimai/kimai.git \
                "${containerHome}/repos/kimai"
            fi

            # install PHP dependencies
            cd "${containerHome}/repos/kimai"
            composer install --no-interaction --optimize-autoloader

            # write .env.local if not present
            if [ ! -f .env.local ]; then
              cat > .env.local << 'ENVEOF'
            APP_ENV=dev
            APP_SECRET=$(openssl rand -hex 16)
            DATABASE_URL="mysql://${username}:kimai@127.0.0.1:3306/${cfg.dbName}?serverVersion=mariadb-10.6.0&charset=utf8mb4"
            ENVEOF
            fi

            # install assets
            npm install
            npm run build

            # run database migrations
            sudo service mariadb start
            php bin/console doctrine:migrations:migrate --no-interaction

            # create an initial admin user (skip if already exists)
            php bin/console kimai:user:create admin admin@example.com ROLE_SUPER_ADMIN kimai_admin 2>/dev/null || true

            # add ~/bin to PATH
            if ! grep -qF 'PATH="$HOME/bin:$PATH"' ~/.bashrc; then
              echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
            fi

            echo "Kimai setup complete. Run start-kimai.sh to start the dev server."
          '';
      };

      home.file.".distrobox/${containerName}/bin/start-kimai" = {
        executable = true;
        force = true;
        text =
          # bash
          ''
            #!/usr/bin/env bash

            set -e

            sudo service mariadb start

            cd "${containerHome}/repos/kimai"
            php bin/console server:start 0.0.0.0:8001 "$@"
          '';
      };

      home.file.".config/distrobox/distrobox.ini".text =
        # ini
        ''
          [${containerName}]
          image=docker.io/library/ubuntu:24.04
          pull=true
          home=${containerHome}

          init_hooks=${containerHome}/setup-container.sh
        '';
    };
  };
}
