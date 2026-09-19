{ runCommand }:

runCommand "luvvly-assets" { } ''
  mkdir -p $out/icons
  cp ${./icons}/*.png $out/icons/
''
