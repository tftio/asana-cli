# Shell completion for asana-cli
#
# To enable completions, add this to your shell config:
#
# For fish (~/.config/fish/config.fish):
#   asana-cli completions fish | source

# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_asana_cli_global_optspecs
	string join \n h/help V/version
end

function __fish_asana_cli_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_asana_cli_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_asana_cli_using_subcommand
	set -l cmd (__fish_asana_cli_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c asana-cli -n "__fish_asana_cli_needs_command" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_needs_command" -s V -l version -d 'Print version'
complete -c asana-cli -n "__fish_asana_cli_needs_command" -f -a "version" -d 'Show version information'
complete -c asana-cli -n "__fish_asana_cli_needs_command" -f -a "license" -d 'Show license information'
complete -c asana-cli -n "__fish_asana_cli_needs_command" -f -a "config" -d 'Manage persisted configuration'
complete -c asana-cli -n "__fish_asana_cli_needs_command" -f -a "task" -d 'Task operations'
complete -c asana-cli -n "__fish_asana_cli_needs_command" -f -a "project" -d 'Project operations'
complete -c asana-cli -n "__fish_asana_cli_needs_command" -f -a "completions" -d 'Generate shell completion scripts'
complete -c asana-cli -n "__fish_asana_cli_needs_command" -f -a "manpage" -d 'Generate the man page (roff output)'
complete -c asana-cli -n "__fish_asana_cli_needs_command" -f -a "doctor" -d 'Check health and configuration'
complete -c asana-cli -n "__fish_asana_cli_needs_command" -f -a "update" -d 'Update to the latest version'
complete -c asana-cli -n "__fish_asana_cli_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand version" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand license" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and not __fish_seen_subcommand_from set get test help" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and not __fish_seen_subcommand_from set get test help" -f -a "set" -d 'Store configuration values'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and not __fish_seen_subcommand_from set get test help" -f -a "get" -d 'Display the current configuration (token redacted)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and not __fish_seen_subcommand_from set get test help" -f -a "test" -d 'Validate the stored Personal Access Token against the Asana API'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and not __fish_seen_subcommand_from set get test help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and __fish_seen_subcommand_from set" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and __fish_seen_subcommand_from set" -f -a "token" -d 'Store the Personal Access Token'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and __fish_seen_subcommand_from set" -f -a "workspace" -d 'Store the default workspace gid'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and __fish_seen_subcommand_from set" -f -a "assignee" -d 'Store the default assignee identifier'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and __fish_seen_subcommand_from set" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and __fish_seen_subcommand_from get" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and __fish_seen_subcommand_from test" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "set" -d 'Store configuration values'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "get" -d 'Display the current configuration (token redacted)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "test" -d 'Validate the stored Personal Access Token against the Asana API'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "list" -d 'List tasks with optional filtering'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "show" -d 'Display detailed information about a task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "create" -d 'Create a new task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "update" -d 'Update an existing task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "delete" -d 'Delete a task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "create-batch" -d 'Create multiple tasks from structured input'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "update-batch" -d 'Update multiple tasks from structured input'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "complete-batch" -d 'Complete multiple tasks from structured input'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "search" -d 'Search for tasks with fuzzy matching'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "subtasks" -d 'Manage subtasks'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "depends-on" -d 'Manage dependencies (tasks this task depends on)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "blocks" -d 'Manage dependents (tasks blocked by this task)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "projects" -d 'Manage project memberships'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "followers" -d 'Manage task followers'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and not __fish_seen_subcommand_from list show create update delete create-batch update-batch complete-batch search subtasks depends-on blocks projects followers help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from list" -l workspace -d 'Workspace identifier filter' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from list" -l project -d 'Project identifier filter' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from list" -l section -d 'Section identifier filter' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from list" -l assignee -d 'Assignee identifier or email filter' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from list" -l completed -d 'Filter by completion state' -r -f -a "true\t''
false\t''"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from list" -l due-before -d 'Only include tasks due on or before the provided date' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from list" -l due-after -d 'Only include tasks due on or after the provided date' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from list" -l limit -d 'Maximum number of tasks to retrieve' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from list" -l sort -d 'Sort order (`name`, `due_on`, `created_at`, `modified_at`, `assignee`)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from list" -l fields -d 'Additional fields to request from the API' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from list" -l output -d 'Output format override' -r -f -a "table\t'Automatically selected table (default when interactive)'
json\t'JSON representation suitable for scripting'
csv\t'Comma separated value export'
markdown\t'Markdown friendly tables'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from list" -l include-subtasks -d 'Include subtasks in the listing response'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from show" -l fields -d 'Additional fields to request from the API' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from show" -l output -d 'Output format override' -r -f -a "table\t'Automatically selected table (default when interactive)'
json\t'JSON representation suitable for scripting'
csv\t'Comma separated value export'
markdown\t'Markdown friendly tables'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from show" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l name -d 'Task name; required unless `--interactive`' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l workspace -d 'Workspace identifier' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l project -d 'Project identifiers to associate with the task' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l section -d 'Section identifier within the first project' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l parent -d 'Parent task identifier to create a subtask' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l assignee -d 'Assignee identifier (gid or email)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l notes -d 'Task notes in plain text' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l html-notes -d 'Task notes in HTML format' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l due-on -d 'Due date (natural language accepted)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l due-at -d 'Due date/time (natural language accepted)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l start-on -d 'Start date (natural language accepted)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l start-at -d 'Start date/time (natural language accepted)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l tag -d 'Tags to apply to the task' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l follower -d 'Followers to subscribe to notifications' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l custom-field -d 'Custom field assignments in KEY=VALUE form' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l output -d 'Output format override' -r -f -a "table\t'Automatically selected table (default when interactive)'
json\t'JSON representation suitable for scripting'
csv\t'Comma separated value export'
markdown\t'Markdown friendly tables'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -l interactive -d 'Prompt for missing values interactively'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l name -d 'New task name' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l notes -d 'Replace notes with plain text content' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l html-notes -d 'Replace notes with HTML content' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l assignee -d 'Assign the task to the specified user (gid or email)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l due-on -d 'Set all-day due date (natural language accepted)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l due-at -d 'Set due date/time (natural language accepted)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l start-on -d 'Set start date (natural language accepted)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l start-at -d 'Set start date/time (natural language accepted)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l parent -d 'Set parent task identifier' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l tag -d 'Replace tags with provided identifiers' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l follower -d 'Replace followers with provided identifiers' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l project -d 'Replace project associations' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l custom-field -d 'Custom field updates in KEY=VALUE form' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l output -d 'Output format override' -r -f -a "table\t'Automatically selected table (default when interactive)'
json\t'JSON representation suitable for scripting'
csv\t'Comma separated value export'
markdown\t'Markdown friendly tables'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l clear-notes -d 'Clear existing plain text notes'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l clear-html-notes -d 'Clear existing HTML notes'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l clear-assignee -d 'Remove the current assignee'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l complete -d 'Mark the task complete'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l incomplete -d 'Mark the task incomplete'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l clear-due-on -d 'Clear the all-day due date'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l clear-due-at -d 'Clear the due date/time'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l clear-start-on -d 'Clear the start date'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l clear-start-at -d 'Clear the start date/time'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l clear-parent -d 'Remove the parent task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l clear-tags -d 'Remove all tags'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l clear-followers -d 'Remove all followers'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -l clear-projects -d 'Remove all project associations'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from delete" -l force -d 'Skip confirmation prompt'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from delete" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create-batch" -l file -d 'Path to JSON or CSV batch file' -r -F
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create-batch" -l format -d 'Override detected input format (`json` or `csv`)' -r -f -a "json\t'JSON array of objects'
csv\t'CSV file with headers'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create-batch" -l output -d 'Output format for created tasks' -r -f -a "table\t'Automatically selected table (default when interactive)'
json\t'JSON representation suitable for scripting'
csv\t'Comma separated value export'
markdown\t'Markdown friendly tables'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create-batch" -l continue-on-error -d 'Continue processing after an error'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from create-batch" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update-batch" -l file -d 'Path to JSON or CSV batch file' -r -F
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update-batch" -l format -d 'Override detected input format (`json` or `csv`)' -r -f -a "json\t'JSON array of objects'
csv\t'CSV file with headers'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update-batch" -l output -d 'Output format for updated tasks' -r -f -a "table\t'Automatically selected table (default when interactive)'
json\t'JSON representation suitable for scripting'
csv\t'Comma separated value export'
markdown\t'Markdown friendly tables'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update-batch" -l continue-on-error -d 'Continue processing after an error'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from update-batch" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from complete-batch" -l file -d 'Path to JSON or CSV batch file' -r -F
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from complete-batch" -l format -d 'Override detected input format (`json` or `csv`)' -r -f -a "json\t'JSON array of objects'
csv\t'CSV file with headers'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from complete-batch" -l output -d 'Output format for resulting tasks' -r -f -a "table\t'Automatically selected table (default when interactive)'
json\t'JSON representation suitable for scripting'
csv\t'Comma separated value export'
markdown\t'Markdown friendly tables'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from complete-batch" -l continue-on-error -d 'Continue processing after an error'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from complete-batch" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from search" -l workspace -d 'Workspace to scope the search' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from search" -l limit -d 'Limit number of matches retrieved from the API' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from search" -l output -d 'Output format override' -r -f -a "table\t'Automatically selected table (default when interactive)'
json\t'JSON representation suitable for scripting'
csv\t'Comma separated value export'
markdown\t'Markdown friendly tables'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from search" -l recent-only -d 'Only show recently accessed tasks'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from search" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from subtasks" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from subtasks" -f -a "list" -d 'List subtasks for a parent task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from subtasks" -f -a "create" -d 'Create a new subtask beneath a parent'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from subtasks" -f -a "convert" -d 'Convert a task to a subtask or detach it'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from subtasks" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from depends-on" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from depends-on" -f -a "list" -d 'List dependencies'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from depends-on" -f -a "add" -d 'Add dependencies'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from depends-on" -f -a "remove" -d 'Remove dependencies'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from depends-on" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from blocks" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from blocks" -f -a "list" -d 'List dependents'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from blocks" -f -a "add" -d 'Add dependents'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from blocks" -f -a "remove" -d 'Remove dependents'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from blocks" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from projects" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from projects" -f -a "add" -d 'Add the task to a project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from projects" -f -a "remove" -d 'Remove the task from a project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from projects" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from followers" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from followers" -f -a "add" -d 'Add followers to the task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from followers" -f -a "remove" -d 'Remove followers from the task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from followers" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "list" -d 'List tasks with optional filtering'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "show" -d 'Display detailed information about a task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "create" -d 'Create a new task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "update" -d 'Update an existing task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "delete" -d 'Delete a task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "create-batch" -d 'Create multiple tasks from structured input'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "update-batch" -d 'Update multiple tasks from structured input'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "complete-batch" -d 'Complete multiple tasks from structured input'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "search" -d 'Search for tasks with fuzzy matching'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "subtasks" -d 'Manage subtasks'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "depends-on" -d 'Manage dependencies (tasks this task depends on)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "blocks" -d 'Manage dependents (tasks blocked by this task)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "projects" -d 'Manage project memberships'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "followers" -d 'Manage task followers'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand task; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and not __fish_seen_subcommand_from list show create update delete members help" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and not __fish_seen_subcommand_from list show create update delete members help" -f -a "list" -d 'List projects with optional filtering'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and not __fish_seen_subcommand_from list show create update delete members help" -f -a "show" -d 'Display detailed information about a project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and not __fish_seen_subcommand_from list show create update delete members help" -f -a "create" -d 'Create a new project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and not __fish_seen_subcommand_from list show create update delete members help" -f -a "update" -d 'Update an existing project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and not __fish_seen_subcommand_from list show create update delete members help" -f -a "delete" -d 'Delete a project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and not __fish_seen_subcommand_from list show create update delete members help" -f -a "members" -d 'Manage project members'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and not __fish_seen_subcommand_from list show create update delete members help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from list" -l workspace -d 'Workspace identifier to filter by' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from list" -l team -d 'Team identifier to filter by' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from list" -l archived -d 'Filter projects by archived flag' -r -f -a "true\t''
false\t''"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from list" -l sort -d 'Sort field (`name`, `created_at`, `modified_at`)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from list" -l output -d 'Output format override' -r -f -a "table\t'Automatically selected table (default when interactive)'
json\t'JSON representation suitable for scripting'
csv\t'Comma separated value export'
markdown\t'Markdown friendly tables'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from list" -l filter -d 'Inline filter expressions (field=value, field!=value, field~regex, field:substring)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from list" -l filter-saved -d 'Include filters saved to disk' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from list" -l save-filter -d 'Persist the provided filter expressions for reuse' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from list" -l limit -d 'Maximum number of projects to retrieve' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from list" -l fields -d 'Additional fields to request from the API' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from show" -l output -d 'Output format override' -r -f -a "table\t'Automatically selected table (default when interactive)'
json\t'JSON representation suitable for scripting'
csv\t'Comma separated value export'
markdown\t'Markdown friendly tables'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from show" -l fields -d 'Additional fields to request from the API' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from show" -l status-limit -d 'Number of recent status updates to show (0 to disable)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from show" -l by-name -d 'Treat the project argument as a name instead of gid'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from show" -l include-members -d 'Include members in the output'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from show" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l name -d 'Project name (required unless --interactive or template supplies it)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l workspace -d 'Workspace identifier' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l team -d 'Team identifier' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l notes -d 'Project notes/description' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l color -d 'Project color slug' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l start-on -d 'Start date (YYYY-MM-DD)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l due-on -d 'Due date (YYYY-MM-DD)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l owner -d 'Owner identifier (gid or email)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l public -d 'Visibility flag' -r -f -a "true\t''
false\t''"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l template -d 'Template name or path' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l member -d 'Additional members to add (gid or email)' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l custom-field -d 'Custom field assignments in KEY=VALUE form' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l var -d 'Template variables in KEY=VALUE form' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l output -d 'Output format override' -r -f -a "table\t'Automatically selected table (default when interactive)'
json\t'JSON representation suitable for scripting'
csv\t'Comma separated value export'
markdown\t'Markdown friendly tables'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -l interactive -d 'Prompt for missing values interactively'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from create" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from update" -l name -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from update" -l notes -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from update" -l color -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from update" -l start-on -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from update" -l due-on -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from update" -l owner -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from update" -l public -r -f -a "true\t''
false\t''"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from update" -l output -r -f -a "table\t'Automatically selected table (default when interactive)'
json\t'JSON representation suitable for scripting'
csv\t'Comma separated value export'
markdown\t'Markdown friendly tables'"
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from update" -l by-name -d 'Treat the project argument as a name'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from update" -l archive
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from update" -l unarchive
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from update" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from delete" -l by-name -d 'Treat the project argument as a name'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from delete" -l force -d 'Skip confirmation prompts'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from delete" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from members" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from members" -f -a "list" -d 'List project members'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from members" -f -a "add" -d 'Add members to the project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from members" -f -a "remove" -d 'Remove members from the project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from members" -f -a "update" -d 'Update an existing member\'s role'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from members" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from help" -f -a "list" -d 'List projects with optional filtering'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from help" -f -a "show" -d 'Display detailed information about a project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from help" -f -a "create" -d 'Create a new project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from help" -f -a "update" -d 'Update an existing project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from help" -f -a "delete" -d 'Delete a project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from help" -f -a "members" -d 'Manage project members'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand project; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand completions" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand manpage" -l dir -d 'Output directory for the generated man page (defaults to stdout)' -r -F
complete -c asana-cli -n "__fish_asana_cli_using_subcommand manpage" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand doctor" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand update" -l version -d 'Specific version to install' -r
complete -c asana-cli -n "__fish_asana_cli_using_subcommand update" -l install-dir -d 'Custom installation directory' -r -F
complete -c asana-cli -n "__fish_asana_cli_using_subcommand update" -s f -l force -d 'Force update even if already up-to-date'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand update" -s h -l help -d 'Print help'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and not __fish_seen_subcommand_from version license config task project completions manpage doctor update help" -f -a "version" -d 'Show version information'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and not __fish_seen_subcommand_from version license config task project completions manpage doctor update help" -f -a "license" -d 'Show license information'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and not __fish_seen_subcommand_from version license config task project completions manpage doctor update help" -f -a "config" -d 'Manage persisted configuration'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and not __fish_seen_subcommand_from version license config task project completions manpage doctor update help" -f -a "task" -d 'Task operations'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and not __fish_seen_subcommand_from version license config task project completions manpage doctor update help" -f -a "project" -d 'Project operations'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and not __fish_seen_subcommand_from version license config task project completions manpage doctor update help" -f -a "completions" -d 'Generate shell completion scripts'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and not __fish_seen_subcommand_from version license config task project completions manpage doctor update help" -f -a "manpage" -d 'Generate the man page (roff output)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and not __fish_seen_subcommand_from version license config task project completions manpage doctor update help" -f -a "doctor" -d 'Check health and configuration'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and not __fish_seen_subcommand_from version license config task project completions manpage doctor update help" -f -a "update" -d 'Update to the latest version'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and not __fish_seen_subcommand_from version license config task project completions manpage doctor update help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "set" -d 'Store configuration values'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "get" -d 'Display the current configuration (token redacted)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "test" -d 'Validate the stored Personal Access Token against the Asana API'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "list" -d 'List tasks with optional filtering'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "show" -d 'Display detailed information about a task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "create" -d 'Create a new task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "update" -d 'Update an existing task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "delete" -d 'Delete a task'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "create-batch" -d 'Create multiple tasks from structured input'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "update-batch" -d 'Update multiple tasks from structured input'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "complete-batch" -d 'Complete multiple tasks from structured input'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "search" -d 'Search for tasks with fuzzy matching'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "subtasks" -d 'Manage subtasks'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "depends-on" -d 'Manage dependencies (tasks this task depends on)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "blocks" -d 'Manage dependents (tasks blocked by this task)'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "projects" -d 'Manage project memberships'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from task" -f -a "followers" -d 'Manage task followers'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from project" -f -a "list" -d 'List projects with optional filtering'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from project" -f -a "show" -d 'Display detailed information about a project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from project" -f -a "create" -d 'Create a new project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from project" -f -a "update" -d 'Update an existing project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from project" -f -a "delete" -d 'Delete a project'
complete -c asana-cli -n "__fish_asana_cli_using_subcommand help; and __fish_seen_subcommand_from project" -f -a "members" -d 'Manage project members'
