#!/usr/bin/env python3

import argparse
import os
import yaml
import functools
from action import Action
from rulebook import Rulebook
import rulebook

rule_dir = os.path.expanduser("~/.config/here-script/rules/")

def incr_str(s):
	assert len(s) > 0
	head = s[:len(s) - 1]
	last = s[len(s) - 1]
	if last.isalpha() and last.upper() != 'Z':
		return head + chr(ord(last) + 1)
	elif last == 'Z':
		return head + 'a'
	elif last == 'z':
		return head + '0'
	elif last.isdigit() and last != '9':
		return head + chr(ord(last) + 1)
	else:
		return s + 'A'

def binding_dict(actions_iterable):
	d = {}
	for action in actions_iterable:
		b = action.binding
		while b in d:
			b = incr_str(b)
		d[b] = action
	return d

def filter_matching_rulebooks(rbs, directory):
	return filter(lambda d: d.rules_test(directory), rbs)

def get_actions(rulebooks_iterable):
	actions = []
	for rb in rulebooks_iterable:
		actions += rb.actions
	return actions

def here_script(directory, rbs, command):
	active_rbs = filter_matching_rulebooks(rbs, directory)
	actions = get_actions(active_rbs)
	actions = binding_dict(actions)

	if command in actions:
		try:
			os.chdir(directory)
			os.execl("/bin/sh", "sh", "-c", actions[command].shell)
		except:
			print("Failed to execute.", file=stderr)
	else:
		print('%s is undefined.' % command)

def available_scripts(directory, rbs, format):
	active_rbs = filter_matching_rulebooks(rbs, directory)
	actions = get_actions(active_rbs)
	actions = binding_dict(actions)

	if format == 'pretty':
		for binding, action in sorted(actions.items()):
			print('\t%s\t%s' % (binding, action.description))
	elif format == 'oneline':
		parts = ['%s %s' % (binding, action.title) for binding, action in actions.items()]
		print(', '.join(sorted(parts)))

# -w --what prints the available commands in different formats
# -C changes the target directory from the default, which is the current working directory

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description='Quickly launch scripts here.')
	parser.add_argument('-C', nargs='?', default=os.getcwd(), dest='directory', help='Run as if in DIRECTORY.')
	group = parser.add_mutually_exclusive_group(required=False)
	group.add_argument('-w', '--what', nargs='?', choices=['pretty', 'oneline'], const='pretty', help="Run no command and print available commands for the directory instead. Defaults to 'pretty'.")
	group.add_argument('command', nargs='?', default='default')
	args = parser.parse_args()

	rbs = rulebook.get_rulebooks()

	if args.what != None:
		available_scripts(args.directory, rbs, args.what)
	elif args.command != None:
		here_script(args.directory, rbs, args.command)
