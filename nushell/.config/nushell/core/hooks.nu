# Nushell Hooks Configuration

export def hooks [] {
    {
        pre_prompt: [{||
            # Direnv integration (if installed)
            if (which direnv | is-empty) {
                return
            }
            try {
                direnv export json | from json | default {} | load-env
                if 'PATH' in $env {
                    $env.PATH = ($env.PATH | split row (char esep))
                }
            } catch {}
        }]
        pre_execution: [{ null }]
        env_change: {
            PWD: [{|before, after| null }]
        }
        display_output: "if (term size).columns >= 100 { table -e } else { table }"
        command_not_found: { null }
    }
}
