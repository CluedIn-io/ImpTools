# Convenience Scripts

note: scripts assumpe you  already have your current context namespace set to cluedin - run [set_ns_to_cluedin.ps1](set_ns_to_cluedin.ps1) to do just that.

Rudi: The intent of this folder is to store common CluedIn specific kubectl and the like commands as used by the implementation team. Please feel free to add yours.

Please turn it into an example .ps1 file and feel free to commit to the above... bonus points for putting some comments in the script ;)

All the port forward scripts use labels rather than pod names to ensure the scripts work across many different instances. Labels are used whereever possible.

# kubectl-aliases-powershell
https://github.com/shanoor/kubectl-aliases-powershell

"This repository contains a script to generate hundreds of convenient kubectl PowerShell aliases programmatically."

Roman: *"I personally use this (forked from this https://github.com/ahmetb/kubectl-aliases) but fairly speaking, I prefer to memoize the native commands instead of custom aliases. So the only thing I use heavily is `k` instead of `kubectl`"*

# Rudi TODOs
- add example session using scripts
- create a table that lists script name vs function