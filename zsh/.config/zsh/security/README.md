# Security Features for Shell Configuration

This directory contains security enhancements for your shell environment.

## History Security (`history-security.zsh`)

Provides functions to protect against accidentally saving sensitive information in shell history.

### Available Functions

#### `clear_history_pattern <pattern>`

Remove all history entries matching a specific pattern. Creates a backup before deletion.

```bash
# Example: Clear all entries containing 'password123'
clear_history_pattern 'password123'

# Backup will be saved to: ~/.zsh_history.backup.TIMESTAMP
```

#### `secure <command>`

Run a command without saving it to history.

```bash
# Example: Export API key without saving to history
secure export API_KEY=secret123

# Example: Connect to database without saving credentials
secure mysql -u root -p secretpassword
```

#### `history_off` / `history_on`

Temporarily disable and re-enable history saving.

```bash
# Disable history
history_off

# Run sensitive commands (not saved)
export API_TOKEN=abc123
export DB_PASSWORD=secret

# Re-enable history
history_on
```

### Best Practices

1. **Prefix sensitive commands with space** (if `HIST_IGNORE_SPACE` is set):
   ```bash
    export API_TOKEN=secret123  # Note the leading space - won't be saved
   ```

2. **Use the `secure` wrapper** for one-off sensitive commands:
   ```bash
   secure curl -H "Authorization: Bearer $TOKEN" api.example.com
   ```

3. **Disable history** when working with secrets for extended period:
   ```bash
   history_off
   # Work with secrets...
   history_on
   ```

4. **Audit your history regularly**:
   ```bash
   bash _scripts/unix/tools/audit-history.sh
   ```

5. **Use environment files** instead of exporting in shell:
   - Put secrets in `~/.env` or `~/.envrc` (gitignored)
   - These files are automatically loaded by direnv or in shell config

## Security Audit Tool

Run the security audit tool to check your history for potentially leaked secrets:

```bash
bash _scripts/unix/tools/audit-history.sh
```

This will scan for common patterns like:
- password, token, secret, api_key
- AWS access keys (AKIA...)
- GitHub tokens (ghp_...)
- Base64-encoded secrets

## Related Documentation

- [SECURITY-DOTFILES.md](../../../SECURITY-DOTFILES.md) - Complete security audit
- [SECURITY-ISSUES.md](../../../SECURITY-ISSUES.md) - Security issues backlog

## Contributing

If you find security issues or want to add more security features, please:
1. Review the security audit documentation
2. Create an issue using the template from SECURITY-ISSUES.md
3. Submit a PR with security improvements

## License

Part of the dotfiles repository. See main LICENSE file.
