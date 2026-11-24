{
  den.aspects.git = {
    nixos = {
      self',
      pkgs,
      lib,
      ...
    }: let
      git = self'.packages.git;

      # gh only looks for extensions in its data dir; token stays in hosts.yml
      ghExtensions = pkgs.linkFarm "gh-extensions" {
        gh-dash = "${self'.packages.gh-dash}/bin";
        gh-f = "${pkgs.gh-f}/bin";
        gh-markdown-preview = "${pkgs.gh-markdown-preview}/bin";
        gh-poi = "${pkgs.gh-poi}/bin";
      };
    in {
      environment.systemPackages = [
        self'.packages.delta
        self'.packages.lazygit
        self'.packages.gh-dash
        self'.packages.tea-dash
        pkgs.gh
        pkgs.forgejo-cli
        pkgs.tea
        pkgs.git-absorb
      ];

      systemd.user.tmpfiles.rules = ["L+ %h/.local/share/gh/extensions - - - - ${ghExtensions}"];

      # gh reports usage by default
      environment.sessionVariables.GH_TELEMETRY = "0";

      # fj outside a repo
      environment.sessionVariables.FJ_FALLBACK_HOST = "https://codeberg.org";

      programs.git = {
        enable = true;
        package = git;
      };

      programs.fish.shellAbbrs = {
        gp = "git push";
        gP = "git pull";
        gsc = "git switch -c";
        gcl = "git clone";
        cbc = "codeberg-clone";
        gst = "git status -sb";
        glog = "git log --graph --pretty=compact";
        gundo = "git reset --soft HEAD~1";
        gpf = "git push --force-with-lease";
        gpF = "git push --force";
        gaa = "git add --all";
        gc = "git commit";
        gca = "git commit --amend";
        gcan = "git commit --amend --no-edit";
        gdf = "git diff";
        gds = "git diff --staged";
        gsw = "git switch";
        gb = "git branch";
        gf = "git fetch --all";
        gm = "git merge";
        grbc = "git rebase --continue";
        grba = "git rebase --abort";
        grs = "git restore";
        grss = "git restore --staged";
        gsh = "git stash";
        gshp = "git stash pop";
      };

      programs.fish.interactiveShellInit = ''
        abbr -a gcm --set-cursor 'git commit -m "%"'

        # for devShells that bring their own git
        set -gx GIT_CONFIG_GLOBAL ${git.configuration.constructFiles.gitconfig.outPath}

        # lazygit, then cd to wherever it was when it quit
        function lg
          set -x LAZYGIT_NEW_DIR_FILE ~/.lazygit/newdir
          command lazygit $argv
          if test -f $LAZYGIT_NEW_DIR_FILE
            cd (cat $LAZYGIT_NEW_DIR_FILE)
            rm -f $LAZYGIT_NEW_DIR_FILE
          end
        end

        bind ctrl-g 'lg; commandline -f repaint'

        function codeberg-clone --description 'git clone from codeberg, bare names are mine'
          set -l repo $argv[1]
          string match -q '*/*' -- $repo; or set repo nouritsu/$repo
          git clone git@codeberg.org:$repo $argv[2..]
        end

        # owner/ lists that owner's repos instead; the api pages at 50
        function __codeberg_repos
          set -l owner nouritsu
          set -l prefix '''
          if string match -q '*/*' -- (commandline -ct)
            set owner (string split -f1 / -- (commandline -ct))
            set prefix $owner/
          end
          for page in (seq 20)
            set -l repos (${lib.getExe pkgs.curl} -sf -m 3 "https://codeberg.org/api/v1/users/$owner/repos?limit=50&page=$page" | ${lib.getExe pkgs.jq} -r --arg p $prefix '.[] | "\($p)\(.name)\t\(.description)"')
            string join \n -- $repos
            test (count $repos) -eq 50; or break
          end
        end

        complete -c codeberg-clone -f
        complete -c codeberg-clone -n '__fish_is_nth_token 1' -a '(__codeberg_repos)'
      '';

      isup'.checks.github = {
        name = "GitHub";
        status = "https://www.githubstatus.com";
        components = ["Git Operations" "API Requests" "Issues" "Pull Requests" "Actions"];
        url = "https://github.com";
      };

      # its status page is uptime kuma, not statuspage.io
      isup'.checks.codeberg = {
        name = "Codeberg";
        url = "https://codeberg.org";
      };
    };
  };
}
