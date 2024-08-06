# This Makefile provides convenient methods for common git operations

.PHONY: add commit push build-docs

# The default commit message
MESSAGE = "updated: `date '+%Y-%m-%d %H:%M:%S'`"

# Add all changes to the staging area
add:
	git add .

# Commit changes with the provided message
commit:
	git commit -m $(MESSAGE)

# Push changes to the master branch
push:
	git push origin master

# Run add, commit, and push in one command
all: add commit push
