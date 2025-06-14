
#       ____                      _       _                        .--.      ___________
#      |  _ \  __ _ _ ____      _(_)_ __ (_)_  __    ,--./,-.     |o_o |    |     |     |
#      | | | |/ _` | '__\ \ /\ / / | '_ \| \ \/ /   / #      \    |:_/ |    |     |     |
#      | |_| | (_| | |   \ V  V /| | | | | |>  <   |          |  //   \ \   |_____|_____|
#      |____/ \__,_|_|    \_/\_/ |_|_| |_|_/_/\_\   \        /  (|     | )  |     |     |
#                                                    `._,._,'  /'\_   _/`\  |     |     |
#      Solving the "Not on my machine" problem well.           \___)=(___/  |_____|_____|

# Most modern development is done on Linux, but Macs are Unix. If you think Homebrew and Docker
# are the solution, you're wrong. Welcome to the world of Nix Flakes! This file defines a complete,
# reproducible development environment. It's like a recipe for your perfect workspace, ensuring
# everyone on your team has the exact same setup, every time. As a bonus, you can use Nix flakes on
# Windows under WSL. Plus, whatever you make will be deployable to the cloud.
#
# This flake offers multiple shell environments:
# - A feature-rich interactive shell for human developers with welcome banners and verbose feedback
# - A streamlined "quiet" shell designed specifically for AI assistants and automation tools
#   that eliminates verbose output while maintaining identical functionality
#
# Access these shells with:
# - `nix develop` (or `nix develop .#default`) for the standard interactive experience
# - `nix develop .#quiet` for AI assistants and automation to avoid output clutter

{
  # This description helps others understand the purpose of this Flake
  description = "A flake that reports the OS using separate scripts with optional CUDA support and unfree packages allowed, now using uv for Python dependencies.";
  
  # Inputs are the dependencies for our Flake
  # They're pinned to specific versions to ensure reproducibility
  inputs = {
    # nixpkgs is the main repository of Nix packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # flake-utils provides helpful functions for working with Flakes
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Outputs define what our Flake produces
  # In this case, it's a development shell that works across different systems
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # We're creating a custom instance of nixpkgs
        # This allows us to enable unfree packages like CUDA
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;  # This is necessary for CUDA support
          };
        };

        # These helpers let us adjust our setup based on the OS
        isDarwin = pkgs.stdenv.isDarwin;
        isLinux = pkgs.stdenv.isLinux;

        # Common packages that we want available in our environment
        # regardless of the operating system
        commonPackages = with pkgs; [
          python313Full  # Python 3.13 interpreter
          uv             # Modern Python dependency manager replacing virtualenv and pip
          figlet         # For creating ASCII art welcome messages
          tmux           # Terminal multiplexer for managing sessions
          zlib           # Compression library for data compression
          git            # Version control system for tracking changes
          curl           # Command-line tool for transferring data with URLs
          wget           # Utility for non-interactive download of files from the web
          cmake          # Cross-platform build system generator
          htop           # Interactive process viewer for Unix systems
        ] ++ (with pkgs; pkgs.lib.optionals isLinux [
          gcc            # GNU Compiler Collection for compiling C/C++ code
          stdenv.cc.cc.lib  # Standard C library for Linux systems
        ]);

        # This script sets up our Python environment and project
        runScript = pkgs.writeShellScriptBin "run-script" ''
          #!/usr/bin/env bash
          
          # Activate the virtual environment
          source .venv/bin/activate

          # Create a fancy welcome message
          REPO_NAME=$(basename "$PWD")
          PROPER_REPO_NAME=$(echo "$REPO_NAME" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
          figlet "$PROPER_REPO_NAME"
          echo "Welcome to the $PROPER_REPO_NAME development environment on ${system}!"
          echo 

          # Install Python packages from requirements.txt using uv
          # This allows flexibility to use the latest PyPI packages
          # Note: This makes the environment less deterministic
          echo "- Installing pip packages with uv..."
          if uv pip install --upgrade pip --quiet && \
            uv pip install -r requirements.txt --quiet; then
              package_count=$(pip list --format=freeze | wc -l)
              echo "- Done. $package_count pip packages installed."
          else
              echo "Warning: An error occurred during uv pip setup."
          fi

          # Check if numpy is properly installed
          if python -c "import numpy" 2>/dev/null; then
            echo "- numpy is importable (good to go!)"
            echo
            echo "To start marimo, type: start"
            echo "To stop marimo, type: stop"
            echo
          else
            echo "Error: numpy could not be imported. Check your installation."
          fi

          # Create convenience scripts for managing JupyterLab
          # Note: We've disabled token and password for easier access, especially in WSL environments
          cat << EOF > .venv/bin/start
          #!/bin/sh
          echo "A marimo tab will open in your default browser."
          tmux kill-session -t marimo 2>/dev/null || echo "No tmux session named 'marimo' is running."
          tmux new-session -d -s marimo 'source .venv/bin/activate && marimo edit --watch --port 4000'
          echo "If no tab opens, visit http://localhost:4000"
          echo "To view marimo server: tmux attach -t marimo"
          echo "To stop marimo server: stop"
          EOF
          chmod +x .venv/bin/start

          cat << EOF > .venv/bin/stop
          #!/bin/sh
          echo "Stopping tmux session 'marimo'..."
          tmux kill-session -t marimo 2>/dev/null || echo "No tmux session named 'marimo' is running."
          echo "The tmux session 'marimo' has been stopped."
          EOF
          chmod +x .venv/bin/stop
        '';

        # Base shell hook that just sets up the environment without any output
        baseEnvSetup = pkgs: ''
          # Set up the Python virtual environment with uv
          test -d .venv || ${pkgs.uv}/bin/uv venv .venv
          export VIRTUAL_ENV="$(pwd)/.venv"
          export PATH="$VIRTUAL_ENV/bin:$PATH"
          export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath commonPackages}:$LD_LIBRARY_PATH

          # Set up CUDA env vars if available (no output message)
          if command -v nvidia-smi &> /dev/null; then
            export CUDA_HOME=${pkgs.cudatoolkit}
            export PATH=$CUDA_HOME/bin:$PATH
            export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
          fi
        '';

        # Function to create shells for each OS
        mkLinuxShells = pkgs: {
          # Default shell with the full interactive setup for human use
          default = pkgs.mkShell {
            buildInputs = commonPackages ++ (with pkgs; pkgs.lib.optionals (builtins.pathExists "/usr/bin/nvidia-smi") cudaPackages);
            shellHook = ''
              ${baseEnvSetup pkgs}
              
              # Set up CUDA if available (with output message)
              if command -v nvidia-smi &> /dev/null; then
                echo "CUDA hardware detected."
              else
                echo "No CUDA hardware detected."
              fi

              # Run the full interactive script
              ${runScript}/bin/run-script
            '';
          };
          
          # Quiet shell for AI assistants, automation and scripting
          quiet = pkgs.mkShell {
            buildInputs = commonPackages ++ (with pkgs; pkgs.lib.optionals (builtins.pathExists "/usr/bin/nvidia-smi") cudaPackages);
            shellHook = ''
              ${baseEnvSetup pkgs}
              # Minimal confirmation message
              echo "Quiet Nix environment activated."
            '';
          };
        };
        
        # Function to create Darwin/macOS shells
        mkDarwinShells = pkgs: {
          # Default shell with the full interactive setup for human use
          default = pkgs.mkShell {
            buildInputs = commonPackages;
            shellHook = ''
              ${baseEnvSetup pkgs}
              
              # Run the full interactive script
              ${runScript}/bin/run-script
            '';
          };
          
          # Quiet shell for AI assistants, automation and scripting
          quiet = pkgs.mkShell {
            buildInputs = commonPackages;
            shellHook = ''
              ${baseEnvSetup pkgs}
              # Minimal confirmation message
              echo "Quiet Nix environment activated."
            '';
          };
        };

        # Get the appropriate shells for the current OS
        shells = if isLinux then mkLinuxShells pkgs else mkDarwinShells pkgs;

      in {
        # Multiple devShells for different use cases
        devShells = shells;
        
        # The default devShell (when just running 'nix develop')
        devShell = shells.default;
      });
}