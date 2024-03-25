{
  # Using fork do avoid error on nix 2.21: https://github.com/hall/kubenix/issues/57
  inputs.kubenix.url = "github:adrian-gierakowski/kubenix?ref=fix-undefined-variable-in-nix-2_21";
  outputs = { self, kubenix, ... }: let
    system = "x86_64-linux";
  in {
    packages.${system} = {
      kubenix = kubenix.packages.${system}.default.override {
        module = { kubenix, ... }: {
          imports = [ kubenix.modules.k8s ];
          kubernetes.kubeconfig = "$HOME/.kube/config";
          kubernetes.resources.namespaces.test-namespace = { };
          kubernetes.resources.pods.example = {
            metadata.namespace = "test-namespace";
            spec.containers.nginx.image = "nginx";
          };
        };
        # optional; pass custom values to the kubenix module
        specialArgs = { flake = self; };
      };
    };
  };
}