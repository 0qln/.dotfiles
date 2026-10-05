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
      # language server, the debug adapter and these tasks all live in this
      # distro and see these paths unchanged. open the workspace, not a single
      # plugin, so that the three files below apply.
      # the two commands worth remembering, as buttons: the debug session owns
      # the server, starting it through preLaunchTask and killing it again
      # through postDebugTask, so the green arrow and the red square in the
      # debug toolbar are the whole interface.
      home.file."${pluginsDirRel}/.vscode/tasks.json" = {
        force = true;
        text =
          # json
          ''
            {
              "version": "2.0.0",
              "tasks": [
                {
                  "label": "kimai: serve (xdebug)",
                  "type": "shell",
                  "command": "distrobox enter ${containerName} -- env KIMAI_DEBUG_PORT=9003 kimai-wrap",
                  // the server never exits, so vscode has to be told to stop
                  // waiting for it. the matcher never matches anything: it is
                  // here only to carry the two patterns that bracket startup,
                  // and the end one is php's own line as it binds the port.
                  "isBackground": true,
                  "problemMatcher": {
                    "owner": "kimai",
                    "pattern": [
                      {
                        "regexp": "$^",
                        "file": 1,
                        "line": 2,
                        "message": 3
                      }
                    ],
                    "background": {
                      "activeOnStart": true,
                      "beginsPattern": "^database:",
                      "endsPattern": "Development Server \\(.*\\) started"
                    }
                  },
                  "presentation": {
                    "panel": "dedicated",
                    "reveal": "always",
                    "clear": true
                  }
                },
                {
                  "label": "kimai: console command (xdebug)",
                  "type": "shell",
                  // start the listener first: xdebug dials out, and a command
                  // that finds nobody there simply runs to completion.
                  "command": "distrobox enter ${containerName} -- env KIMAI_DEBUG_PORT=9003 kimai-wrap console ''${input:kimaiConsoleCommand}",
                  "problemMatcher": [],
                  "presentation": {
                    "panel": "dedicated",
                    "reveal": "always",
                    "clear": true
                  }
                },
                {
                  "label": "kimai: stop",
                  "type": "shell",
                  // ending the debug session runs this. the wrapper kills the
                  // pid it recorded when it started, so this works whether or
                  // not the server was started with xdebug enabled.
                  "command": "distrobox enter ${containerName} -- kimai-wrap stop",
                  "problemMatcher": [],
                  "presentation": {
                    "panel": "shared",
                    "reveal": "silent",
                    "close": true
                  }
                }
              ],
              "inputs": [
                {
                  "id": "kimaiConsoleCommand",
                  "type": "promptString",
                  "description": "bin/console arguments",
                  "default": "list"
                }
              ]
            }
          '';
      };

      home.file."${pluginsDirRel}/.vscode/launch.json" = {
        force = true;
        text =
          # json
          ''
            {
              // xdebug dials the editor rather than the other way round, so this
              // listens, and the port has to be the KIMAI_DEBUG_PORT the serve
              // task passes. no pathMappings: the adapter runs in this distro
              // and the container's paths are already these paths.
              "version": "0.2.0",
              "configurations": [
                {
                  "name": "kimai: serve and debug",
                  "type": "php",
                  "request": "launch",
                  "port": 9003,
                  "preLaunchTask": "kimai: serve (xdebug)",
                  "postDebugTask": "kimai: stop"
                },
                {
                  // the same listener without the server attached to it, for a
                  // server already running in a terminal, or for debugging a
                  // console command, which starts and ends on its own.
                  "name": "kimai: listen for xdebug",
                  "type": "php",
                  "request": "launch",
                  "port": 9003
                }
              ]
            }
          '';
      };

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
            PID_FILE="$KIMAI_DIR/var/kimai-wrap.pid"

            # `kimai-wrap stop` is the other half of the vscode task pair. the
            # pid file is exact, which a pattern is not: with KIMAI_DEBUG_PORT
            # set the command line reads `php -d xdebug... -S 0.0.0.0:8001`, so
            # anything matching on `php -S` quietly misses the debug server.
            if [ "''${1:-}" = "stop" ]; then
              if [ -s "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
                kill "$(cat "$PID_FILE")"
                rm -f "$PID_FILE"
                echo "stopped" >&2
              # a server from before this wrote pid files, or one started by
              # hand. the bracket keeps the pattern off this command's own
              # argv, which pkill can see: distrobox shares the host pid
              # namespace, so the two sides watch the same process table.
              elif pkill -f -- '-S 0[.]0.0.0:8001'; then
                rm -f "$PID_FILE"
                echo "stopped (found by port)" >&2
              else
                echo "no server running" >&2
              fi
              exit 0
            fi

            # the same flags arm the debugger for the server and for a console
            # command: xdebug dials the editor, so all it needs is the port the
            # listener sits on. without them a php process here has no debugger
            # at all, since xdebug.mode is off container-wide.
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

            # `kimai-wrap console <command ...>` is `bin/console` with those
            # flags in front of it. the plugin links are left alone: a console
            # command runs against whatever the server last set up.
            if [ "''${1:-}" = "console" ]; then
              shift
              sudo service mariadb start >/dev/null
              cd "$KIMAI_DIR"
              exec php "''${PHP_ARGS[@]}" bin/console "$@"
            fi

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

            # symfony dropped server:start years ago; php's own server is what is
            # left, and it is enough for one developer and one debug session.
            # wsl forwards localhost, so this is http://localhost:$PORT on windows.
            # exec hands this shell's pid straight to php, so $$ written here is
            # the pid `kimai-wrap stop` will signal.
            echo $$ > "$PID_FILE"

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
            # to be able to read the sources it indexes. the caches belong to
            # the same problem: composer and npm wrote them as root, and the
            # user that runs them next cannot.
            for path in \
              "${containerHome}/repos" \
              "${containerHome}/.local" \
              "${containerHome}/.cache" \
              "${containerHome}/.npm" \
              "${containerHome}/.config/composer"; do
              if [ -e "$path" ]; then
                sudo chown -R ${username}:${username} "$path"
              fi
            done

            # add ~/bin to PATH
            if ! grep -qF 'PATH="$HOME/bin:$PATH"' ~/.bashrc; then
              echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
            fi

            # that only covers interactive shells. `distrobox enter -- cmd` runs
            # no profile at all and comes with the stock PATH, so the wrapper
            # also goes where that PATH already looks. the link points at the
            # stable ~/bin path, not at the nix store path behind it, so it
            # survives a new home-manager generation.
            sudo ln -sf "$HOME/bin/kimai-wrap" /usr/local/bin/kimai-wrap

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
