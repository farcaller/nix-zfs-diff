{
  description = "A flake for running less insane zfs diffs in nix";

  outputs = { self, nixpkgs }: {
    nixosModule = { config, lib, pkgs, ... }: {
      environment.systemPackages = [ self.defaultPackage.x86_64-linux ];
    };
    nixosModules.default = self.nixosModule;

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.nix-zfs-diff;

    packages.x86_64-linux.nix-zfs-diff =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      in
      pkgs.writeShellScriptBin "nix-zfs-diff" ''
        if [ "$1" == "" ]; then
          echo "usage: nix-zfs-diff <snapshot>"
          exit 2
        fi
        exec ${pkgs.zfs}/bin/zfs diff "$1" | \
        ${pkgs.ruby}/bin/ruby -ne \
        'BEGIN{data={}}; \
        op,file=$_.split(/\s+/); \
        data[file] ||= op; \
        data[file] = "@" if data[file] != op; \
        END{data.sort.each{|file,op| puts "#{op}\t#{file}"}}'
      '';
  };
}
