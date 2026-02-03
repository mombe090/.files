# Nushell Hooks Configuration

export def get_hooks [] {
    {
        pre_prompt: [{ null }]
        pre_execution: [{ null }]
        env_change: {
            PWD: []
        }
        display_output: "if (term size).columns >= 100 { table -e } else { table }"
        command_not_found: { null }
    }
}
