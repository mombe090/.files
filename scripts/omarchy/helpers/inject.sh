#!/usr/bin/env bash
# Idempotent source injection utilities

# Inject a source line into a config file idempotently
inject_source() {
    local config_file="$1"
    local source_line="$2"
    local marker="${3:-}"  # Optional marker comment
    
    # Create config file if it doesn't exist
    if [[ ! -f "$config_file" ]]; then
        mkdir -p "$(dirname "$config_file")"
        touch "$config_file"
        log_info "Created config file: $config_file"
    fi
    
    # Check if source line already exists
    if grep -Fxq "$source_line" "$config_file" 2>/dev/null; then
        log_info "Source already present: $source_line"
        return 0
    fi
    
    # Backup original
    backup_file "$config_file"
    
    # Add marker comment if provided and not present
    if [[ -n "$marker" ]]; then
        if ! grep -Fq "$marker" "$config_file" 2>/dev/null; then
            echo "" >> "$config_file"
            echo "$marker" >> "$config_file"
        fi
    fi
    
    # Inject source line
    echo "$source_line" >> "$config_file"
    log_success "Injected: $source_line"
}

# Remove a specific source line from config
remove_source() {
    local config_file="$1"
    local source_line="$2"
    
    if [[ ! -f "$config_file" ]]; then
        log_warn "Config file not found: $config_file"
        return 1
    fi
    
    # Check if source line exists
    if ! grep -Fxq "$source_line" "$config_file"; then
        log_info "Source line not present: $source_line"
        return 0
    fi
    
    # Backup before modification
    backup_file "$config_file"
    
    # Remove the line
    grep -Fxv "$source_line" "$config_file" > "$config_file.tmp"
    mv "$config_file.tmp" "$config_file"
    
    log_success "Removed: $source_line"
}

# Remove all custom sources (from marker to end)
remove_custom_sources() {
    local config_file="$1"
    local marker="$2"
    
    if [[ ! -f "$config_file" ]]; then
        log_warn "Config file not found: $config_file"
        return 1
    fi
    
    # Check if marker exists
    if ! grep -Fq "$marker" "$config_file"; then
        log_info "Marker not found: $marker"
        return 0
    fi
    
    # Backup before modification
    backup_file "$config_file"
    
    # Remove everything from marker to end
    sed -i "/$marker/,\$d" "$config_file"
    
    log_success "Removed custom sources from: $config_file"
}

# Verify that a source line is present
verify_source() {
    local config_file="$1"
    local source_line="$2"
    
    if grep -Fxq "$source_line" "$config_file" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}
