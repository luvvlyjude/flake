{
  hm = {
    # Client-agnostic MCP servers. Each client opts in with its own
    # `enableMcpIntegration`; servers that only make sense for one client stay
    # in that client's own config instead.
    programs.mcp = {
      enable = true;

      # Hosted, keyless, rate limited per IP. Every classification leaves the
      # machine, so nothing private goes through it.
      servers.classifier.url = "https://classifier.dev/mcp";
    };
  };
}
