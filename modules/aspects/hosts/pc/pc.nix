{den, ...}: {
  den.aspects.pc = {
    includes = with den.aspects; [
      workstation
      bootloader.lanzaboote
      kernel.cachyos-bore-lto
      firmware.amd
      graphics.nvidia
      cpu.balanced

      # Desk hardware
      peripherals.keyboard
      peripherals.monitor
      peripherals.tablet
      peripherals.razer
      dms.razer
      audio.presets

      secrets
      dms.home-assistant
      services.beszel
      extra.streaming
      ai.local
      nix.serve
      nix.builds-on-laptop
      nix.update

      ssh.from-laptop
      ssh.from-pixel
      backup.from-homelab
    ];
  };
}
