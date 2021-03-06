# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        efibootmgr = {
          canTouchEfVariables = true;
          efiDisk = "/dev/sda1";
        };
      };
    };
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_AU.UTF-8";
  };

  time.timeZone = "Australia/Brisbane";

  environment.systemPackages = with pkgs; [
    gitAndTools.gitFull
    ranger
    silver-searcher
    tree
    vim
    wget
  ];

  networking = {
    hostName = "nixos-clone";
    firewall.enable = false;
  };

  services = {
    openssh.enable = true;
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        theme = "steeef";
      };
    };
  };

  users.extraUsers.talk = {
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    home = "/home/talk";
    extraGroups = ["wheel" "docker" "networkmanager"];
    shell = pkgs.zsh; 
  };

  system.stateVersion = "17.03";

}
