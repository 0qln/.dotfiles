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

    # the plugin checkouts stay out here rather than in the container home:
    # init_hooks run as root, so anything the container creates is owned by a
    # subuid and is read-only from this side, which is the side the editor
    # runs on. the workspace is bind-mounted into the container at this very
    # same path, so a symlink into var/plugins resolves in both namespaces.
    pluginsDirRel = "repos/ws-kimai";
    pluginsDir = "${config.home.homeDirectory}/${pluginsDirRel}";

    kimaiDir = "${containerHome}/repos/kimai";
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

      # vscode runs on the windows side through the wsl extension, so the
      # language server lives in this distro and sees these paths unchanged.
      # open the workspace, not a single plugin, so that this applies. the
      # debug configuration is user level, in the windows settings.json, next
      # to the odoo one.
      home.file."${pluginsDirRel}/.vscode/settings.json" = {
        force = true;
        text =
          # json
          ''
            {
              // a plugin checkout carries none of the kimai or symfony sources
              // its classes extend, so intelephense is pointed at the checkout
              // in the container home. reading it from out here is fine; it is
              // only writes that the podman user namespace blocks.
              "intelephense.environment.phpVersion": "8.2.0",
              "intelephense.environment.includePaths": [
                "${kimaiDir}/src",
                "${kimaiDir}/vendor"
              ]
            }
          '';
      };

      home.file.".distrobox/${containerName}/bin/kimai-wrap" = {
        executable = true;
        force = true;
        text =
          # bash
          ''
            #!/usr/bin/env bash

            set -euo pipefail

            KIMAI_DIR="$HOME/repos/kimai"
            WS_DIR="${pluginsDir}"
            PORT="''${KIMAI_PORT:-8001}"

            sudo service mariadb start >/dev/null

            # kimai discovers a plugin as a directory named *Bundle sitting
            # directly in var/plugins. a workspace checkout is either the bundle
            # itself (EfecteSyncBundle/) or a repository that wraps one
            # (Worksimple.KimaiEfecteSyncPlugin/EfecteSyncBundle), so the bundles
            # are the *Bundle directories carrying a composer.json.
            ws_bundles() {
              find "$WS_DIR" -mindepth 1 -maxdepth 2 -type d -name '*Bundle' \
                -exec test -f '{}/composer.json' \; -print | sort -u
            }

            mkdir -p "$KIMAI_DIR/var/plugins"

            # links whose checkout left the workspace would abort the kernel
            # boot, so clear the dangling ones before relinking.
            find "$KIMAI_DIR/var/plugins" -maxdepth 1 -type l ! -exec test -e '{}' \; -delete

            while read -r bundle; do
              [ -n "$bundle" ] || continue
              ln -sfn "$bundle" "$KIMAI_DIR/var/plugins/$(basename "$bundle")"
            done < <(ws_bundles)

            echo "database:    ${cfg.dbName}" >&2
            echo "kimai:       $KIMAI_DIR" >&2
            echo "plugins:     $(ws_bundles | xargs -r -n1 basename | paste -sd, -)" >&2

            cd "$KIMAI_DIR"

            # the bundle list is baked into the compiled container, so a changed
            # set of links only takes effect after kimai drops its caches.
            php bin/console kimai:reload --env=dev

            # a plugin ships its public assets inside the bundle; symlinking
            # them into public/bundles keeps an edit live instead of needing
            # this to be rerun after every change.
            php bin/console assets:install --symlink

            PHP_ARGS=()
            if [ -n "''${KIMAI_DEBUG_PORT:-}" ]; then
              echo "xdebug:      connecting to a client on 127.0.0.1:$KIMAI_DEBUG_PORT" >&2
              PHP_ARGS+=(
                -d xdebug.mode=debug
                -d xdebug.start_with_request=yes
                -d xdebug.discover_client_host=false
                -d xdebug.client_host=127.0.0.1
                -d xdebug.client_port="$KIMAI_DEBUG_PORT"
              )
            fi

            # symfony dropped server:start years ago; php's own server is what is
            # left, and it is enough for one developer and one debug session.
            # wsl forwards localhost, so this is http://localhost:$PORT on windows.
            echo "serving:     http://0.0.0.0:$PORT" >&2
            exec php "''${PHP_ARGS[@]}" -S "0.0.0.0:$PORT" -t public
          '';
      };

      home.file.".distrobox/${containerName}/start-kimai.sh" = {
        executable = true;
        force = true;
        text =
          # bash
          ''
            #!/usr/bin/env bash
            exec "$HOME/bin/kimai-wrap" "$@"
          '';
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
              php8.2-xdebug \
              unzip \
              git \
              curl \
              mariadb-server \
              mariadb-client

            # ubuntu 24.04 ships node 18, but the kimai frontend build needs 20.9
            # or newer: css-minimizer and serialize-javascript reach for the
            # global `crypto`, which older node does not have, and webpack dies
            # with "ReferenceError: crypto is not defined" halfway through.
            # nodesource's package carries npm, so ubuntu's npm stays out of it.
            curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
            sudo apt-get install -y nodejs

            # xdebug ships enabled in develop mode, which taxes every request
            # for stack traces nobody asked for. kimai-wrap turns the debugger
            # on per run instead, via -d flags.
            echo 'xdebug.mode=off' | sudo tee /etc/php/8.2/mods-available/xdebug-mode.ini >/dev/null
            sudo phpenmod xdebug-mode

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
            if [ ! -d "${kimaiDir}" ]; then
              mkdir -p "${containerHome}/repos"
              git clone \
                --branch ${cfg.branch} \
                --single-branch \
                https://github.com/kimai/kimai.git \
                "${kimaiDir}"
            fi

            # install PHP dependencies
            cd "${kimaiDir}"
            composer install --no-interaction --optimize-autoloader

            # write .env.local if not present
            if [ ! -f .env.local ]; then
              app_secret="$(openssl rand -hex 16)"
              cat > .env.local << ENVEOF
            APP_ENV=dev
            APP_SECRET=$app_secret
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

            # init_hooks run as root, so everything above landed root-owned.
            # kimai-wrap runs as ${username} and has to write var/cache, var/log
            # and the var/plugins links, and the editor out on the host side has
            # to be able to read the sources it indexes.
            sudo chown -R ${username}:${username} "${containerHome}/repos"

            # add ~/bin to PATH
            if ! grep -qF 'PATH="$HOME/bin:$PATH"' ~/.bashrc; then
              echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
            fi

            echo "Kimai setup complete. Run start-kimai.sh to start the dev server."
          '';
      };

      home.file.".config/distrobox/distrobox.ini".text =
        # ini
        ''
          [${containerName}]
          image=docker.io/library/ubuntu:24.04
          pull=true
          home=${containerHome}
          volume=${pluginsDir}:${pluginsDir}

          init_hooks=${containerHome}/setup-container.sh
        '';
    };
  };
}
