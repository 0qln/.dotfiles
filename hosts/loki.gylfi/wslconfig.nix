# `.wslconfig` is read by the WSL host service on Windows, not by this NixOS
# system: it lives at %UserProfile%\.wslconfig, outside of any distro, and
# configures the VM that every WSL 2 distro shares -- here that is NixOS plus
# two Ubuntu distros, so these values are not this system's alone to set.
#
# Kept here because every value is a decision about this specific machine, and
# a copy that exists only on the Windows filesystem has nothing keeping it
# honest. Activation writes it back out; see dendrites/wsl for the mechanism.
#
# Transcribed from the file that was already on the Windows side, verbatim.
{...}: {
  modules.wsl.wslconfig = {
    # This host's Windows profile, rather than the `User` default.
    windowsProfile = "/mnt/c/Users/LinusNagel";

    text = ''
      # WSL2 global config - tuned for: i7-1355U (2P+8E / 12T), 32 GB RAM, NVMe
      # Applies to all WSL2 distros (NixOS, Ubuntu, ubuntu2).
      # Per-distro settings live in /etc/wsl.conf inside the distro.
      # Apply changes with: wsl --shutdown   (then wait ~8s before relaunching)

      [wsl2]

      # --- Resources -------------------------------------------------------------
      # Ceiling, not a reservation: WSL only commits what it actually touches.
      # 20 GB leaves ~12 GB for Windows + VBS/Credential Guard + enterprise agents.
      memory=20GB

      # Headroom for link steps / nixos-rebuild spikes without hitting the OOM killer.
      swap=8GB

      # processors: left at default (12 = all logical CPUs). On this U-series chip,
      # capping costs build throughput more than it buys UI responsiveness.
      # If heavy parallel builds make Windows stutter, uncomment:
      #processors=10

      # --- Networking (mirrored mode) --------------------------------------------
      # Mirrored gives the VM the host's interfaces - required for WireGuard/OpenVPN
      # tunnels to be visible inside WSL. Note: localhostForwarding is ignored here.
      networkingMode=mirrored

      # Proxies DNS over the host resolver instead of a NAT nameserver. This is what
      # makes name resolution survive VPN connect/disconnect. (Default true; explicit
      # because it is load-bearing with the WireGuard tunnels on this machine.)
      dnsTunneling=true

      # Windows Firewall + Hyper-V rules apply to WSL traffic.
      firewall=true

      # Pick up Windows' HTTP proxy settings. No proxy configured today; harmless
      # now, and correct automatically if corp policy ever pushes one.
      autoProxy=true

      # --- Misc ------------------------------------------------------------------
      # Nested virt stays on (default) - needed for containers/KVM inside NixOS.
      nestedVirtualization=true

      # Cap crash dumps so they cannot quietly eat disk.
      maxCrashDumpCount=3

      [experimental]

      # Return freed page cache to Windows instead of vmmemWSL growing and never
      # shrinking. "gradual" over the "dropCache" default: dropCache reclaims
      # immediately and throws away warm build caches, which hurts on repeat builds.
      autoMemoryReclaim=gradual

      # sparseVhd is deliberately NOT enabled. Microsoft gated sparse VHDs behind
      # an --allow-unsafe flag in WSL 2.5.6 after reports of ext4 corruption, and
      # as of 2.7.3 the root cause was still never published. Setting it here
      # force-enables that same unsafe path for every newly created VHD -- and on
      # this machine that is three distros' worth of store, not one.
      #
      # It is also self-defeating: `diskpart compact vdisk` refuses sparse files
      # outright ("must not be sparse"), so turning this on trades a reclaim
      # method that works for one that risks the disk. To shrink a VHD, shut WSL
      # down and compact it with diskpart instead.
      #
      # Dropping the flag only governs VHDs created from here on. Any disk that
      # was already made sparse while it was set stays sparse until it is
      # converted back with `wsl --manage <distro> --set-sparse false`.

      # Mirrored-mode: let WSL reach Windows services (and vice versa) on any IP
      # assigned to the host, not just 127.0.0.1.
      hostAddressLoopback=true

      # If a Linux service ever fails to bind because Windows holds the port,
      # list it here, e.g.: ignoredPorts=53,5432
      #ignoredPorts=
    '';
  };
}
