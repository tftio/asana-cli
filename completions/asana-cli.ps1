# Shell completion for asana-cli
#
# To enable completions, add this to your shell config:
#
# For powershell:
#   asana-cli completions powershell > /path/to/completions/_asana-cli


using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName 'asana-cli' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'asana-cli'
        for ($i = 1; $i -lt $commandElements.Count; $i++) {
            $element = $commandElements[$i]
            if ($element -isnot [StringConstantExpressionAst] -or
                $element.StringConstantType -ne [StringConstantType]::BareWord -or
                $element.Value.StartsWith('-') -or
                $element.Value -eq $wordToComplete) {
                break
        }
        $element.Value
    }) -join ';'

    $completions = @(switch ($command) {
        'asana-cli' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('version', 'version', [CompletionResultType]::ParameterValue, 'Show version information')
            [CompletionResult]::new('license', 'license', [CompletionResultType]::ParameterValue, 'Show license information')
            [CompletionResult]::new('config', 'config', [CompletionResultType]::ParameterValue, 'Manage persisted configuration')
            [CompletionResult]::new('task', 'task', [CompletionResultType]::ParameterValue, 'Task operations')
            [CompletionResult]::new('project', 'project', [CompletionResultType]::ParameterValue, 'Project operations')
            [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate shell completion scripts')
            [CompletionResult]::new('manpage', 'manpage', [CompletionResultType]::ParameterValue, 'Generate the man page (roff output)')
            [CompletionResult]::new('doctor', 'doctor', [CompletionResultType]::ParameterValue, 'Check health and configuration')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update to the latest version')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;version' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;license' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;config' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('set', 'set', [CompletionResultType]::ParameterValue, 'Store configuration values')
            [CompletionResult]::new('get', 'get', [CompletionResultType]::ParameterValue, 'Display the current configuration (token redacted)')
            [CompletionResult]::new('test', 'test', [CompletionResultType]::ParameterValue, 'Validate the stored Personal Access Token against the Asana API')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;config;set' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('token', 'token', [CompletionResultType]::ParameterValue, 'Store the Personal Access Token')
            [CompletionResult]::new('workspace', 'workspace', [CompletionResultType]::ParameterValue, 'Store the default workspace gid')
            [CompletionResult]::new('assignee', 'assignee', [CompletionResultType]::ParameterValue, 'Store the default assignee identifier')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;config;set;token' {
            [CompletionResult]::new('--token', '--token', [CompletionResultType]::ParameterName, 'Personal Access Token value; omit to be prompted securely')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;config;set;workspace' {
            [CompletionResult]::new('--workspace', '--workspace', [CompletionResultType]::ParameterName, 'Workspace gid to use when none is supplied on the command line')
            [CompletionResult]::new('--clear', '--clear', [CompletionResultType]::ParameterName, 'Clear the stored default workspace')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;config;set;assignee' {
            [CompletionResult]::new('--assignee', '--assignee', [CompletionResultType]::ParameterName, 'Identifier (email or gid) that should replace the `me` alias')
            [CompletionResult]::new('--clear', '--clear', [CompletionResultType]::ParameterName, 'Clear the stored default assignee')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;config;set;help' {
            [CompletionResult]::new('token', 'token', [CompletionResultType]::ParameterValue, 'Store the Personal Access Token')
            [CompletionResult]::new('workspace', 'workspace', [CompletionResultType]::ParameterValue, 'Store the default workspace gid')
            [CompletionResult]::new('assignee', 'assignee', [CompletionResultType]::ParameterValue, 'Store the default assignee identifier')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;config;set;help;token' {
            break
        }
        'asana-cli;config;set;help;workspace' {
            break
        }
        'asana-cli;config;set;help;assignee' {
            break
        }
        'asana-cli;config;set;help;help' {
            break
        }
        'asana-cli;config;get' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;config;test' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;config;help' {
            [CompletionResult]::new('set', 'set', [CompletionResultType]::ParameterValue, 'Store configuration values')
            [CompletionResult]::new('get', 'get', [CompletionResultType]::ParameterValue, 'Display the current configuration (token redacted)')
            [CompletionResult]::new('test', 'test', [CompletionResultType]::ParameterValue, 'Validate the stored Personal Access Token against the Asana API')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;config;help;set' {
            [CompletionResult]::new('token', 'token', [CompletionResultType]::ParameterValue, 'Store the Personal Access Token')
            [CompletionResult]::new('workspace', 'workspace', [CompletionResultType]::ParameterValue, 'Store the default workspace gid')
            [CompletionResult]::new('assignee', 'assignee', [CompletionResultType]::ParameterValue, 'Store the default assignee identifier')
            break
        }
        'asana-cli;config;help;set;token' {
            break
        }
        'asana-cli;config;help;set;workspace' {
            break
        }
        'asana-cli;config;help;set;assignee' {
            break
        }
        'asana-cli;config;help;get' {
            break
        }
        'asana-cli;config;help;test' {
            break
        }
        'asana-cli;config;help;help' {
            break
        }
        'asana-cli;task' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List tasks with optional filtering')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Display detailed information about a task')
            [CompletionResult]::new('create', 'create', [CompletionResultType]::ParameterValue, 'Create a new task')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update an existing task')
            [CompletionResult]::new('delete', 'delete', [CompletionResultType]::ParameterValue, 'Delete a task')
            [CompletionResult]::new('create-batch', 'create-batch', [CompletionResultType]::ParameterValue, 'Create multiple tasks from structured input')
            [CompletionResult]::new('update-batch', 'update-batch', [CompletionResultType]::ParameterValue, 'Update multiple tasks from structured input')
            [CompletionResult]::new('complete-batch', 'complete-batch', [CompletionResultType]::ParameterValue, 'Complete multiple tasks from structured input')
            [CompletionResult]::new('search', 'search', [CompletionResultType]::ParameterValue, 'Search for tasks with fuzzy matching')
            [CompletionResult]::new('subtasks', 'subtasks', [CompletionResultType]::ParameterValue, 'Manage subtasks')
            [CompletionResult]::new('depends-on', 'depends-on', [CompletionResultType]::ParameterValue, 'Manage dependencies (tasks this task depends on)')
            [CompletionResult]::new('blocks', 'blocks', [CompletionResultType]::ParameterValue, 'Manage dependents (tasks blocked by this task)')
            [CompletionResult]::new('projects', 'projects', [CompletionResultType]::ParameterValue, 'Manage project memberships')
            [CompletionResult]::new('followers', 'followers', [CompletionResultType]::ParameterValue, 'Manage task followers')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;task;list' {
            [CompletionResult]::new('--workspace', '--workspace', [CompletionResultType]::ParameterName, 'Workspace identifier filter')
            [CompletionResult]::new('--project', '--project', [CompletionResultType]::ParameterName, 'Project identifier filter')
            [CompletionResult]::new('--section', '--section', [CompletionResultType]::ParameterName, 'Section identifier filter')
            [CompletionResult]::new('--assignee', '--assignee', [CompletionResultType]::ParameterName, 'Assignee identifier or email filter')
            [CompletionResult]::new('--completed', '--completed', [CompletionResultType]::ParameterName, 'Filter by completion state')
            [CompletionResult]::new('--due-before', '--due-before', [CompletionResultType]::ParameterName, 'Only include tasks due on or before the provided date')
            [CompletionResult]::new('--due-after', '--due-after', [CompletionResultType]::ParameterName, 'Only include tasks due on or after the provided date')
            [CompletionResult]::new('--limit', '--limit', [CompletionResultType]::ParameterName, 'Maximum number of tasks to retrieve')
            [CompletionResult]::new('--sort', '--sort', [CompletionResultType]::ParameterName, 'Sort order (`name`, `due_on`, `created_at`, `modified_at`, `assignee`)')
            [CompletionResult]::new('--fields', '--fields', [CompletionResultType]::ParameterName, 'Additional fields to request from the API')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format override')
            [CompletionResult]::new('--include-subtasks', '--include-subtasks', [CompletionResultType]::ParameterName, 'Include subtasks in the listing response')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;task;show' {
            [CompletionResult]::new('--fields', '--fields', [CompletionResultType]::ParameterName, 'Additional fields to request from the API')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format override')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;task;create' {
            [CompletionResult]::new('--name', '--name', [CompletionResultType]::ParameterName, 'Task name; required unless `--interactive`')
            [CompletionResult]::new('--workspace', '--workspace', [CompletionResultType]::ParameterName, 'Workspace identifier')
            [CompletionResult]::new('--project', '--project', [CompletionResultType]::ParameterName, 'Project identifiers to associate with the task')
            [CompletionResult]::new('--section', '--section', [CompletionResultType]::ParameterName, 'Section identifier within the first project')
            [CompletionResult]::new('--parent', '--parent', [CompletionResultType]::ParameterName, 'Parent task identifier to create a subtask')
            [CompletionResult]::new('--assignee', '--assignee', [CompletionResultType]::ParameterName, 'Assignee identifier (gid or email)')
            [CompletionResult]::new('--notes', '--notes', [CompletionResultType]::ParameterName, 'Task notes in plain text')
            [CompletionResult]::new('--html-notes', '--html-notes', [CompletionResultType]::ParameterName, 'Task notes in HTML format')
            [CompletionResult]::new('--due-on', '--due-on', [CompletionResultType]::ParameterName, 'Due date (natural language accepted)')
            [CompletionResult]::new('--due-at', '--due-at', [CompletionResultType]::ParameterName, 'Due date/time (natural language accepted)')
            [CompletionResult]::new('--start-on', '--start-on', [CompletionResultType]::ParameterName, 'Start date (natural language accepted)')
            [CompletionResult]::new('--start-at', '--start-at', [CompletionResultType]::ParameterName, 'Start date/time (natural language accepted)')
            [CompletionResult]::new('--tag', '--tag', [CompletionResultType]::ParameterName, 'Tags to apply to the task')
            [CompletionResult]::new('--follower', '--follower', [CompletionResultType]::ParameterName, 'Followers to subscribe to notifications')
            [CompletionResult]::new('--custom-field', '--custom-field', [CompletionResultType]::ParameterName, 'Custom field assignments in KEY=VALUE form')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format override')
            [CompletionResult]::new('--interactive', '--interactive', [CompletionResultType]::ParameterName, 'Prompt for missing values interactively')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;task;update' {
            [CompletionResult]::new('--name', '--name', [CompletionResultType]::ParameterName, 'New task name')
            [CompletionResult]::new('--notes', '--notes', [CompletionResultType]::ParameterName, 'Replace notes with plain text content')
            [CompletionResult]::new('--html-notes', '--html-notes', [CompletionResultType]::ParameterName, 'Replace notes with HTML content')
            [CompletionResult]::new('--assignee', '--assignee', [CompletionResultType]::ParameterName, 'Assign the task to the specified user (gid or email)')
            [CompletionResult]::new('--due-on', '--due-on', [CompletionResultType]::ParameterName, 'Set all-day due date (natural language accepted)')
            [CompletionResult]::new('--due-at', '--due-at', [CompletionResultType]::ParameterName, 'Set due date/time (natural language accepted)')
            [CompletionResult]::new('--start-on', '--start-on', [CompletionResultType]::ParameterName, 'Set start date (natural language accepted)')
            [CompletionResult]::new('--start-at', '--start-at', [CompletionResultType]::ParameterName, 'Set start date/time (natural language accepted)')
            [CompletionResult]::new('--parent', '--parent', [CompletionResultType]::ParameterName, 'Set parent task identifier')
            [CompletionResult]::new('--tag', '--tag', [CompletionResultType]::ParameterName, 'Replace tags with provided identifiers')
            [CompletionResult]::new('--follower', '--follower', [CompletionResultType]::ParameterName, 'Replace followers with provided identifiers')
            [CompletionResult]::new('--project', '--project', [CompletionResultType]::ParameterName, 'Replace project associations')
            [CompletionResult]::new('--custom-field', '--custom-field', [CompletionResultType]::ParameterName, 'Custom field updates in KEY=VALUE form')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format override')
            [CompletionResult]::new('--clear-notes', '--clear-notes', [CompletionResultType]::ParameterName, 'Clear existing plain text notes')
            [CompletionResult]::new('--clear-html-notes', '--clear-html-notes', [CompletionResultType]::ParameterName, 'Clear existing HTML notes')
            [CompletionResult]::new('--clear-assignee', '--clear-assignee', [CompletionResultType]::ParameterName, 'Remove the current assignee')
            [CompletionResult]::new('--complete', '--complete', [CompletionResultType]::ParameterName, 'Mark the task complete')
            [CompletionResult]::new('--incomplete', '--incomplete', [CompletionResultType]::ParameterName, 'Mark the task incomplete')
            [CompletionResult]::new('--clear-due-on', '--clear-due-on', [CompletionResultType]::ParameterName, 'Clear the all-day due date')
            [CompletionResult]::new('--clear-due-at', '--clear-due-at', [CompletionResultType]::ParameterName, 'Clear the due date/time')
            [CompletionResult]::new('--clear-start-on', '--clear-start-on', [CompletionResultType]::ParameterName, 'Clear the start date')
            [CompletionResult]::new('--clear-start-at', '--clear-start-at', [CompletionResultType]::ParameterName, 'Clear the start date/time')
            [CompletionResult]::new('--clear-parent', '--clear-parent', [CompletionResultType]::ParameterName, 'Remove the parent task')
            [CompletionResult]::new('--clear-tags', '--clear-tags', [CompletionResultType]::ParameterName, 'Remove all tags')
            [CompletionResult]::new('--clear-followers', '--clear-followers', [CompletionResultType]::ParameterName, 'Remove all followers')
            [CompletionResult]::new('--clear-projects', '--clear-projects', [CompletionResultType]::ParameterName, 'Remove all project associations')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;task;delete' {
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Skip confirmation prompt')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;task;create-batch' {
            [CompletionResult]::new('--file', '--file', [CompletionResultType]::ParameterName, 'Path to JSON or CSV batch file')
            [CompletionResult]::new('--format', '--format', [CompletionResultType]::ParameterName, 'Override detected input format (`json` or `csv`)')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format for created tasks')
            [CompletionResult]::new('--continue-on-error', '--continue-on-error', [CompletionResultType]::ParameterName, 'Continue processing after an error')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;task;update-batch' {
            [CompletionResult]::new('--file', '--file', [CompletionResultType]::ParameterName, 'Path to JSON or CSV batch file')
            [CompletionResult]::new('--format', '--format', [CompletionResultType]::ParameterName, 'Override detected input format (`json` or `csv`)')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format for updated tasks')
            [CompletionResult]::new('--continue-on-error', '--continue-on-error', [CompletionResultType]::ParameterName, 'Continue processing after an error')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;task;complete-batch' {
            [CompletionResult]::new('--file', '--file', [CompletionResultType]::ParameterName, 'Path to JSON or CSV batch file')
            [CompletionResult]::new('--format', '--format', [CompletionResultType]::ParameterName, 'Override detected input format (`json` or `csv`)')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format for resulting tasks')
            [CompletionResult]::new('--continue-on-error', '--continue-on-error', [CompletionResultType]::ParameterName, 'Continue processing after an error')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;task;search' {
            [CompletionResult]::new('--workspace', '--workspace', [CompletionResultType]::ParameterName, 'Workspace to scope the search')
            [CompletionResult]::new('--limit', '--limit', [CompletionResultType]::ParameterName, 'Limit number of matches retrieved from the API')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format override')
            [CompletionResult]::new('--recent-only', '--recent-only', [CompletionResultType]::ParameterName, 'Only show recently accessed tasks')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;task;subtasks' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List subtasks for a parent task')
            [CompletionResult]::new('create', 'create', [CompletionResultType]::ParameterValue, 'Create a new subtask beneath a parent')
            [CompletionResult]::new('convert', 'convert', [CompletionResultType]::ParameterValue, 'Convert a task to a subtask or detach it')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;task;subtasks;list' {
            [CompletionResult]::new('--fields', '--fields', [CompletionResultType]::ParameterName, 'Additional fields to request')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format override')
            [CompletionResult]::new('--recursive', '--recursive', [CompletionResultType]::ParameterName, 'Traverse subtasks recursively')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;task;subtasks;create' {
            [CompletionResult]::new('--name', '--name', [CompletionResultType]::ParameterName, 'Task name; required unless `--interactive`')
            [CompletionResult]::new('--assignee', '--assignee', [CompletionResultType]::ParameterName, 'Assignee identifier (gid or email)')
            [CompletionResult]::new('--due-on', '--due-on', [CompletionResultType]::ParameterName, 'Due date (natural language accepted)')
            [CompletionResult]::new('--due-at', '--due-at', [CompletionResultType]::ParameterName, 'Due date/time (natural language accepted)')
            [CompletionResult]::new('--start-on', '--start-on', [CompletionResultType]::ParameterName, 'Start date (natural language accepted)')
            [CompletionResult]::new('--start-at', '--start-at', [CompletionResultType]::ParameterName, 'Start date/time (natural language accepted)')
            [CompletionResult]::new('--tag', '--tag', [CompletionResultType]::ParameterName, 'Tags to apply')
            [CompletionResult]::new('--follower', '--follower', [CompletionResultType]::ParameterName, 'Followers to notify')
            [CompletionResult]::new('--custom-field', '--custom-field', [CompletionResultType]::ParameterName, 'Custom field assignments in KEY=VALUE form')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format override')
            [CompletionResult]::new('--interactive', '--interactive', [CompletionResultType]::ParameterName, 'Prompt for missing values interactively')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;task;subtasks;convert' {
            [CompletionResult]::new('--parent', '--parent', [CompletionResultType]::ParameterName, 'New parent task identifier')
            [CompletionResult]::new('--root', '--root', [CompletionResultType]::ParameterName, 'Convert the task back to a top-level task')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;task;subtasks;help' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List subtasks for a parent task')
            [CompletionResult]::new('create', 'create', [CompletionResultType]::ParameterValue, 'Create a new subtask beneath a parent')
            [CompletionResult]::new('convert', 'convert', [CompletionResultType]::ParameterValue, 'Convert a task to a subtask or detach it')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;task;subtasks;help;list' {
            break
        }
        'asana-cli;task;subtasks;help;create' {
            break
        }
        'asana-cli;task;subtasks;help;convert' {
            break
        }
        'asana-cli;task;subtasks;help;help' {
            break
        }
        'asana-cli;task;depends-on' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List dependencies')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add dependencies')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove dependencies')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;task;depends-on;list' {
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format override')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;task;depends-on;add' {
            [CompletionResult]::new('--dependency', '--dependency', [CompletionResultType]::ParameterName, 'Dependency identifiers to add/remove')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;task;depends-on;remove' {
            [CompletionResult]::new('--dependency', '--dependency', [CompletionResultType]::ParameterName, 'Dependency identifiers to add/remove')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;task;depends-on;help' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List dependencies')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add dependencies')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove dependencies')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;task;depends-on;help;list' {
            break
        }
        'asana-cli;task;depends-on;help;add' {
            break
        }
        'asana-cli;task;depends-on;help;remove' {
            break
        }
        'asana-cli;task;depends-on;help;help' {
            break
        }
        'asana-cli;task;blocks' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List dependents')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add dependents')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove dependents')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;task;blocks;list' {
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format override')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;task;blocks;add' {
            [CompletionResult]::new('--dependent', '--dependent', [CompletionResultType]::ParameterName, 'Dependent identifiers to add/remove')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;task;blocks;remove' {
            [CompletionResult]::new('--dependent', '--dependent', [CompletionResultType]::ParameterName, 'Dependent identifiers to add/remove')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;task;blocks;help' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List dependents')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add dependents')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove dependents')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;task;blocks;help;list' {
            break
        }
        'asana-cli;task;blocks;help;add' {
            break
        }
        'asana-cli;task;blocks;help;remove' {
            break
        }
        'asana-cli;task;blocks;help;help' {
            break
        }
        'asana-cli;task;projects' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add the task to a project')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove the task from a project')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;task;projects;add' {
            [CompletionResult]::new('--project', '--project', [CompletionResultType]::ParameterName, 'Project identifier to add')
            [CompletionResult]::new('--section', '--section', [CompletionResultType]::ParameterName, 'Optional section identifier')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;task;projects;remove' {
            [CompletionResult]::new('--project', '--project', [CompletionResultType]::ParameterName, 'Project identifier to remove')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;task;projects;help' {
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add the task to a project')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove the task from a project')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;task;projects;help;add' {
            break
        }
        'asana-cli;task;projects;help;remove' {
            break
        }
        'asana-cli;task;projects;help;help' {
            break
        }
        'asana-cli;task;followers' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add followers to the task')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove followers from the task')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;task;followers;add' {
            [CompletionResult]::new('--follower', '--follower', [CompletionResultType]::ParameterName, 'Followers to add or remove')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;task;followers;remove' {
            [CompletionResult]::new('--follower', '--follower', [CompletionResultType]::ParameterName, 'Followers to add or remove')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;task;followers;help' {
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add followers to the task')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove followers from the task')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;task;followers;help;add' {
            break
        }
        'asana-cli;task;followers;help;remove' {
            break
        }
        'asana-cli;task;followers;help;help' {
            break
        }
        'asana-cli;task;help' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List tasks with optional filtering')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Display detailed information about a task')
            [CompletionResult]::new('create', 'create', [CompletionResultType]::ParameterValue, 'Create a new task')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update an existing task')
            [CompletionResult]::new('delete', 'delete', [CompletionResultType]::ParameterValue, 'Delete a task')
            [CompletionResult]::new('create-batch', 'create-batch', [CompletionResultType]::ParameterValue, 'Create multiple tasks from structured input')
            [CompletionResult]::new('update-batch', 'update-batch', [CompletionResultType]::ParameterValue, 'Update multiple tasks from structured input')
            [CompletionResult]::new('complete-batch', 'complete-batch', [CompletionResultType]::ParameterValue, 'Complete multiple tasks from structured input')
            [CompletionResult]::new('search', 'search', [CompletionResultType]::ParameterValue, 'Search for tasks with fuzzy matching')
            [CompletionResult]::new('subtasks', 'subtasks', [CompletionResultType]::ParameterValue, 'Manage subtasks')
            [CompletionResult]::new('depends-on', 'depends-on', [CompletionResultType]::ParameterValue, 'Manage dependencies (tasks this task depends on)')
            [CompletionResult]::new('blocks', 'blocks', [CompletionResultType]::ParameterValue, 'Manage dependents (tasks blocked by this task)')
            [CompletionResult]::new('projects', 'projects', [CompletionResultType]::ParameterValue, 'Manage project memberships')
            [CompletionResult]::new('followers', 'followers', [CompletionResultType]::ParameterValue, 'Manage task followers')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;task;help;list' {
            break
        }
        'asana-cli;task;help;show' {
            break
        }
        'asana-cli;task;help;create' {
            break
        }
        'asana-cli;task;help;update' {
            break
        }
        'asana-cli;task;help;delete' {
            break
        }
        'asana-cli;task;help;create-batch' {
            break
        }
        'asana-cli;task;help;update-batch' {
            break
        }
        'asana-cli;task;help;complete-batch' {
            break
        }
        'asana-cli;task;help;search' {
            break
        }
        'asana-cli;task;help;subtasks' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List subtasks for a parent task')
            [CompletionResult]::new('create', 'create', [CompletionResultType]::ParameterValue, 'Create a new subtask beneath a parent')
            [CompletionResult]::new('convert', 'convert', [CompletionResultType]::ParameterValue, 'Convert a task to a subtask or detach it')
            break
        }
        'asana-cli;task;help;subtasks;list' {
            break
        }
        'asana-cli;task;help;subtasks;create' {
            break
        }
        'asana-cli;task;help;subtasks;convert' {
            break
        }
        'asana-cli;task;help;depends-on' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List dependencies')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add dependencies')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove dependencies')
            break
        }
        'asana-cli;task;help;depends-on;list' {
            break
        }
        'asana-cli;task;help;depends-on;add' {
            break
        }
        'asana-cli;task;help;depends-on;remove' {
            break
        }
        'asana-cli;task;help;blocks' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List dependents')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add dependents')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove dependents')
            break
        }
        'asana-cli;task;help;blocks;list' {
            break
        }
        'asana-cli;task;help;blocks;add' {
            break
        }
        'asana-cli;task;help;blocks;remove' {
            break
        }
        'asana-cli;task;help;projects' {
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add the task to a project')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove the task from a project')
            break
        }
        'asana-cli;task;help;projects;add' {
            break
        }
        'asana-cli;task;help;projects;remove' {
            break
        }
        'asana-cli;task;help;followers' {
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add followers to the task')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove followers from the task')
            break
        }
        'asana-cli;task;help;followers;add' {
            break
        }
        'asana-cli;task;help;followers;remove' {
            break
        }
        'asana-cli;task;help;help' {
            break
        }
        'asana-cli;project' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List projects with optional filtering')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Display detailed information about a project')
            [CompletionResult]::new('create', 'create', [CompletionResultType]::ParameterValue, 'Create a new project')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update an existing project')
            [CompletionResult]::new('delete', 'delete', [CompletionResultType]::ParameterValue, 'Delete a project')
            [CompletionResult]::new('members', 'members', [CompletionResultType]::ParameterValue, 'Manage project members')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;project;list' {
            [CompletionResult]::new('--workspace', '--workspace', [CompletionResultType]::ParameterName, 'Workspace identifier to filter by')
            [CompletionResult]::new('--team', '--team', [CompletionResultType]::ParameterName, 'Team identifier to filter by')
            [CompletionResult]::new('--archived', '--archived', [CompletionResultType]::ParameterName, 'Filter projects by archived flag')
            [CompletionResult]::new('--sort', '--sort', [CompletionResultType]::ParameterName, 'Sort field (`name`, `created_at`, `modified_at`)')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format override')
            [CompletionResult]::new('--filter', '--filter', [CompletionResultType]::ParameterName, 'Inline filter expressions (field=value, field!=value, field~regex, field:substring)')
            [CompletionResult]::new('--filter-saved', '--filter-saved', [CompletionResultType]::ParameterName, 'Include filters saved to disk')
            [CompletionResult]::new('--save-filter', '--save-filter', [CompletionResultType]::ParameterName, 'Persist the provided filter expressions for reuse')
            [CompletionResult]::new('--limit', '--limit', [CompletionResultType]::ParameterName, 'Maximum number of projects to retrieve')
            [CompletionResult]::new('--fields', '--fields', [CompletionResultType]::ParameterName, 'Additional fields to request from the API')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;project;show' {
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format override')
            [CompletionResult]::new('--fields', '--fields', [CompletionResultType]::ParameterName, 'Additional fields to request from the API')
            [CompletionResult]::new('--status-limit', '--status-limit', [CompletionResultType]::ParameterName, 'Number of recent status updates to show (0 to disable)')
            [CompletionResult]::new('--by-name', '--by-name', [CompletionResultType]::ParameterName, 'Treat the project argument as a name instead of gid')
            [CompletionResult]::new('--include-members', '--include-members', [CompletionResultType]::ParameterName, 'Include members in the output')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;project;create' {
            [CompletionResult]::new('--name', '--name', [CompletionResultType]::ParameterName, 'Project name (required unless --interactive or template supplies it)')
            [CompletionResult]::new('--workspace', '--workspace', [CompletionResultType]::ParameterName, 'Workspace identifier')
            [CompletionResult]::new('--team', '--team', [CompletionResultType]::ParameterName, 'Team identifier')
            [CompletionResult]::new('--notes', '--notes', [CompletionResultType]::ParameterName, 'Project notes/description')
            [CompletionResult]::new('--color', '--color', [CompletionResultType]::ParameterName, 'Project color slug')
            [CompletionResult]::new('--start-on', '--start-on', [CompletionResultType]::ParameterName, 'Start date (YYYY-MM-DD)')
            [CompletionResult]::new('--due-on', '--due-on', [CompletionResultType]::ParameterName, 'Due date (YYYY-MM-DD)')
            [CompletionResult]::new('--owner', '--owner', [CompletionResultType]::ParameterName, 'Owner identifier (gid or email)')
            [CompletionResult]::new('--public', '--public', [CompletionResultType]::ParameterName, 'Visibility flag')
            [CompletionResult]::new('--template', '--template', [CompletionResultType]::ParameterName, 'Template name or path')
            [CompletionResult]::new('--member', '--member', [CompletionResultType]::ParameterName, 'Additional members to add (gid or email)')
            [CompletionResult]::new('--custom-field', '--custom-field', [CompletionResultType]::ParameterName, 'Custom field assignments in KEY=VALUE form')
            [CompletionResult]::new('--var', '--var', [CompletionResultType]::ParameterName, 'Template variables in KEY=VALUE form')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output format override')
            [CompletionResult]::new('--interactive', '--interactive', [CompletionResultType]::ParameterName, 'Prompt for missing values interactively')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;project;update' {
            [CompletionResult]::new('--name', '--name', [CompletionResultType]::ParameterName, 'name')
            [CompletionResult]::new('--notes', '--notes', [CompletionResultType]::ParameterName, 'notes')
            [CompletionResult]::new('--color', '--color', [CompletionResultType]::ParameterName, 'color')
            [CompletionResult]::new('--start-on', '--start-on', [CompletionResultType]::ParameterName, 'start-on')
            [CompletionResult]::new('--due-on', '--due-on', [CompletionResultType]::ParameterName, 'due-on')
            [CompletionResult]::new('--owner', '--owner', [CompletionResultType]::ParameterName, 'owner')
            [CompletionResult]::new('--public', '--public', [CompletionResultType]::ParameterName, 'public')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'output')
            [CompletionResult]::new('--by-name', '--by-name', [CompletionResultType]::ParameterName, 'Treat the project argument as a name')
            [CompletionResult]::new('--archive', '--archive', [CompletionResultType]::ParameterName, 'archive')
            [CompletionResult]::new('--unarchive', '--unarchive', [CompletionResultType]::ParameterName, 'unarchive')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;project;delete' {
            [CompletionResult]::new('--by-name', '--by-name', [CompletionResultType]::ParameterName, 'Treat the project argument as a name')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Skip confirmation prompts')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;project;members' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List project members')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add members to the project')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove members from the project')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update an existing member''s role')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;project;members;list' {
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'output')
            [CompletionResult]::new('--by-name', '--by-name', [CompletionResultType]::ParameterName, 'Treat the project argument as a name')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;project;members;add' {
            [CompletionResult]::new('--role', '--role', [CompletionResultType]::ParameterName, 'role')
            [CompletionResult]::new('--by-name', '--by-name', [CompletionResultType]::ParameterName, 'Treat the project argument as a name')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;project;members;remove' {
            [CompletionResult]::new('--by-name', '--by-name', [CompletionResultType]::ParameterName, 'Treat the project argument as a name')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;project;members;update' {
            [CompletionResult]::new('--membership', '--membership', [CompletionResultType]::ParameterName, 'membership')
            [CompletionResult]::new('--member', '--member', [CompletionResultType]::ParameterName, 'member')
            [CompletionResult]::new('--role', '--role', [CompletionResultType]::ParameterName, 'role')
            [CompletionResult]::new('--by-name', '--by-name', [CompletionResultType]::ParameterName, 'Treat the project argument as a name')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'asana-cli;project;members;help' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List project members')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add members to the project')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove members from the project')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update an existing member''s role')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;project;members;help;list' {
            break
        }
        'asana-cli;project;members;help;add' {
            break
        }
        'asana-cli;project;members;help;remove' {
            break
        }
        'asana-cli;project;members;help;update' {
            break
        }
        'asana-cli;project;members;help;help' {
            break
        }
        'asana-cli;project;help' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List projects with optional filtering')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Display detailed information about a project')
            [CompletionResult]::new('create', 'create', [CompletionResultType]::ParameterValue, 'Create a new project')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update an existing project')
            [CompletionResult]::new('delete', 'delete', [CompletionResultType]::ParameterValue, 'Delete a project')
            [CompletionResult]::new('members', 'members', [CompletionResultType]::ParameterValue, 'Manage project members')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;project;help;list' {
            break
        }
        'asana-cli;project;help;show' {
            break
        }
        'asana-cli;project;help;create' {
            break
        }
        'asana-cli;project;help;update' {
            break
        }
        'asana-cli;project;help;delete' {
            break
        }
        'asana-cli;project;help;members' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List project members')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add members to the project')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove members from the project')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update an existing member''s role')
            break
        }
        'asana-cli;project;help;members;list' {
            break
        }
        'asana-cli;project;help;members;add' {
            break
        }
        'asana-cli;project;help;members;remove' {
            break
        }
        'asana-cli;project;help;members;update' {
            break
        }
        'asana-cli;project;help;help' {
            break
        }
        'asana-cli;completions' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;manpage' {
            [CompletionResult]::new('--dir', '--dir', [CompletionResultType]::ParameterName, 'Output directory for the generated man page (defaults to stdout)')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;doctor' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;update' {
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Specific version to install')
            [CompletionResult]::new('--install-dir', '--install-dir', [CompletionResultType]::ParameterName, 'Custom installation directory')
            [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Force update even if already up-to-date')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Force update even if already up-to-date')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'asana-cli;help' {
            [CompletionResult]::new('version', 'version', [CompletionResultType]::ParameterValue, 'Show version information')
            [CompletionResult]::new('license', 'license', [CompletionResultType]::ParameterValue, 'Show license information')
            [CompletionResult]::new('config', 'config', [CompletionResultType]::ParameterValue, 'Manage persisted configuration')
            [CompletionResult]::new('task', 'task', [CompletionResultType]::ParameterValue, 'Task operations')
            [CompletionResult]::new('project', 'project', [CompletionResultType]::ParameterValue, 'Project operations')
            [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate shell completion scripts')
            [CompletionResult]::new('manpage', 'manpage', [CompletionResultType]::ParameterValue, 'Generate the man page (roff output)')
            [CompletionResult]::new('doctor', 'doctor', [CompletionResultType]::ParameterValue, 'Check health and configuration')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update to the latest version')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'asana-cli;help;version' {
            break
        }
        'asana-cli;help;license' {
            break
        }
        'asana-cli;help;config' {
            [CompletionResult]::new('set', 'set', [CompletionResultType]::ParameterValue, 'Store configuration values')
            [CompletionResult]::new('get', 'get', [CompletionResultType]::ParameterValue, 'Display the current configuration (token redacted)')
            [CompletionResult]::new('test', 'test', [CompletionResultType]::ParameterValue, 'Validate the stored Personal Access Token against the Asana API')
            break
        }
        'asana-cli;help;config;set' {
            [CompletionResult]::new('token', 'token', [CompletionResultType]::ParameterValue, 'Store the Personal Access Token')
            [CompletionResult]::new('workspace', 'workspace', [CompletionResultType]::ParameterValue, 'Store the default workspace gid')
            [CompletionResult]::new('assignee', 'assignee', [CompletionResultType]::ParameterValue, 'Store the default assignee identifier')
            break
        }
        'asana-cli;help;config;set;token' {
            break
        }
        'asana-cli;help;config;set;workspace' {
            break
        }
        'asana-cli;help;config;set;assignee' {
            break
        }
        'asana-cli;help;config;get' {
            break
        }
        'asana-cli;help;config;test' {
            break
        }
        'asana-cli;help;task' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List tasks with optional filtering')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Display detailed information about a task')
            [CompletionResult]::new('create', 'create', [CompletionResultType]::ParameterValue, 'Create a new task')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update an existing task')
            [CompletionResult]::new('delete', 'delete', [CompletionResultType]::ParameterValue, 'Delete a task')
            [CompletionResult]::new('create-batch', 'create-batch', [CompletionResultType]::ParameterValue, 'Create multiple tasks from structured input')
            [CompletionResult]::new('update-batch', 'update-batch', [CompletionResultType]::ParameterValue, 'Update multiple tasks from structured input')
            [CompletionResult]::new('complete-batch', 'complete-batch', [CompletionResultType]::ParameterValue, 'Complete multiple tasks from structured input')
            [CompletionResult]::new('search', 'search', [CompletionResultType]::ParameterValue, 'Search for tasks with fuzzy matching')
            [CompletionResult]::new('subtasks', 'subtasks', [CompletionResultType]::ParameterValue, 'Manage subtasks')
            [CompletionResult]::new('depends-on', 'depends-on', [CompletionResultType]::ParameterValue, 'Manage dependencies (tasks this task depends on)')
            [CompletionResult]::new('blocks', 'blocks', [CompletionResultType]::ParameterValue, 'Manage dependents (tasks blocked by this task)')
            [CompletionResult]::new('projects', 'projects', [CompletionResultType]::ParameterValue, 'Manage project memberships')
            [CompletionResult]::new('followers', 'followers', [CompletionResultType]::ParameterValue, 'Manage task followers')
            break
        }
        'asana-cli;help;task;list' {
            break
        }
        'asana-cli;help;task;show' {
            break
        }
        'asana-cli;help;task;create' {
            break
        }
        'asana-cli;help;task;update' {
            break
        }
        'asana-cli;help;task;delete' {
            break
        }
        'asana-cli;help;task;create-batch' {
            break
        }
        'asana-cli;help;task;update-batch' {
            break
        }
        'asana-cli;help;task;complete-batch' {
            break
        }
        'asana-cli;help;task;search' {
            break
        }
        'asana-cli;help;task;subtasks' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List subtasks for a parent task')
            [CompletionResult]::new('create', 'create', [CompletionResultType]::ParameterValue, 'Create a new subtask beneath a parent')
            [CompletionResult]::new('convert', 'convert', [CompletionResultType]::ParameterValue, 'Convert a task to a subtask or detach it')
            break
        }
        'asana-cli;help;task;subtasks;list' {
            break
        }
        'asana-cli;help;task;subtasks;create' {
            break
        }
        'asana-cli;help;task;subtasks;convert' {
            break
        }
        'asana-cli;help;task;depends-on' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List dependencies')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add dependencies')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove dependencies')
            break
        }
        'asana-cli;help;task;depends-on;list' {
            break
        }
        'asana-cli;help;task;depends-on;add' {
            break
        }
        'asana-cli;help;task;depends-on;remove' {
            break
        }
        'asana-cli;help;task;blocks' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List dependents')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add dependents')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove dependents')
            break
        }
        'asana-cli;help;task;blocks;list' {
            break
        }
        'asana-cli;help;task;blocks;add' {
            break
        }
        'asana-cli;help;task;blocks;remove' {
            break
        }
        'asana-cli;help;task;projects' {
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add the task to a project')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove the task from a project')
            break
        }
        'asana-cli;help;task;projects;add' {
            break
        }
        'asana-cli;help;task;projects;remove' {
            break
        }
        'asana-cli;help;task;followers' {
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add followers to the task')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove followers from the task')
            break
        }
        'asana-cli;help;task;followers;add' {
            break
        }
        'asana-cli;help;task;followers;remove' {
            break
        }
        'asana-cli;help;project' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List projects with optional filtering')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Display detailed information about a project')
            [CompletionResult]::new('create', 'create', [CompletionResultType]::ParameterValue, 'Create a new project')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update an existing project')
            [CompletionResult]::new('delete', 'delete', [CompletionResultType]::ParameterValue, 'Delete a project')
            [CompletionResult]::new('members', 'members', [CompletionResultType]::ParameterValue, 'Manage project members')
            break
        }
        'asana-cli;help;project;list' {
            break
        }
        'asana-cli;help;project;show' {
            break
        }
        'asana-cli;help;project;create' {
            break
        }
        'asana-cli;help;project;update' {
            break
        }
        'asana-cli;help;project;delete' {
            break
        }
        'asana-cli;help;project;members' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List project members')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add members to the project')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove members from the project')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update an existing member''s role')
            break
        }
        'asana-cli;help;project;members;list' {
            break
        }
        'asana-cli;help;project;members;add' {
            break
        }
        'asana-cli;help;project;members;remove' {
            break
        }
        'asana-cli;help;project;members;update' {
            break
        }
        'asana-cli;help;completions' {
            break
        }
        'asana-cli;help;manpage' {
            break
        }
        'asana-cli;help;doctor' {
            break
        }
        'asana-cli;help;update' {
            break
        }
        'asana-cli;help;help' {
            break
        }
    })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}
