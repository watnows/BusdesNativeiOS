if mint list | grep -q 'SwiftLint'; then
    mint run swiftlint
else
    echo "warning: SwiftLint not installed."
fi
