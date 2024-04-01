{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:bluskript/stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    sakaya = {
      url = "github:donovanglover/sakaya";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... } @ attrs: with nixpkgs.lib; {
    nixosConfigurations = {
      nixos = nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./.
          {
            nixpkgs.overlays = builtins.attrValues self.overlays;
            imports = builtins.attrValues self.nixosModules;
            home-manager.sharedModules = builtins.attrValues self.homeManagerModules;
          }
        ];
      };
    };
  } //
    (builtins.listToAttrs
      (builtins.map
        (attr: {
          name = attr;
          value = let
            directory = builtins.replaceStrings
              ["nixosModules" "homeManagerModules"]
              ["modules" "home"]
              attr;
            function = if directory == "packages"
              then nixpkgs.legacyPackages.x86_64-linux.callPackage
              else import;
            filesMap = (builtins.listToAttrs
              (builtins.map
                (filename: {
                  name = builtins.replaceStrings [".nix"] [""] filename;
                  value = function ./${directory}/${filename}; })
                (builtins.attrNames
                (builtins.readDir ./${directory}))));
            callP = (builtins.listToAttrs
              (builtins.map
                (filename: {
                  name = builtins.replaceStrings [".nix"] [""] filename;
                  value = function ./${directory}/${filename} { }; })
                (builtins.attrNames
                (builtins.readDir ./${directory}))));
            val = if directory == "packages"
              then { x86_64-linux = callP; }
              else filesMap;
          in (val); })
      ["overlays" "nixosModules" "homeManagerModules" "packages"]));
}
