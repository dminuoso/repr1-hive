This will complaing about the fact that the submodule appears empty.

```
colmena eval \
  -f "git+file:///path/to/repr1-hive?submodules=1" \
  -E '{ nodes, ...}: nodes.test.config.system.build.toplevel'
```

Compare with the following command, which evaluates just fine

```
nix eval \
  "git+file:///path/to/repr1hive?submodules=1#nixosConfigurations.test.config.system.build.toplevel"
```
