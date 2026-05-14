.PHONY: setup
setup:
	./setup.sh

.PHONY: secrets
secrets:
	@command -v op >/dev/null || { echo "1Password CLI (op) is required"; exit 1; }
	op inject --account my.1password.com -f -i env_secret.template.sh -o $(HOME)/.zsh.d/env_secret
	chmod 600 $(HOME)/.zsh.d/env_secret

.PHONY: ssh-config-private
ssh-config-private:
	@command -v op >/dev/null || { echo "1Password CLI (op) is required"; exit 1; }
	@mkdir -p $(HOME)/.ssh/config.d
	@chmod 700 $(HOME)/.ssh/config.d
	op inject --account my.1password.com -f -i ssh-config-private.template -o $(HOME)/.ssh/config.d/private
	chmod 600 $(HOME)/.ssh/config.d/private
