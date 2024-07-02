if [ $(uname -m) = "arm64" ]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:${PATH+:$PATH}";
fi

# Mintでrswiftを実行
if which mint >/dev/null; then
  xcrun --sdk macosx mint run R.swift rswift generate "${SRCROOT}/R.generated.swift"
else
  echo "warning: Mint not installed"
fi
