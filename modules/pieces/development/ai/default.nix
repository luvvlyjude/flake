{ self, ... }:
{
  flake.homeModules.ai = {
    imports = [
      self.homeModules.claude
      self.homeModules.mcp
    ];
  };
}
