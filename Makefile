.PHONY: setup
setup:
	./setup.sh

.PHONY: secrets
secrets:
	@command -v op >/dev/null || { echo "1Password CLI (op) is required"; exit 1; }
	op inject --account my.1password.com -i env_secret.template.sh -o $(HOME)/.zsh.d/env_secret
	chmod 600 $(HOME)/.zsh.d/env_secret
