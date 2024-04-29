if mint list | grep -q 'R.swift'; then
  mint run R.swift rswift generate "$SRCROOT/BusdesNativeiOS/Generated/R.generated.swift"
else
  echo "error: R.swift not installed; run 'mint bootstrap' to install"
  return -1
fi       
