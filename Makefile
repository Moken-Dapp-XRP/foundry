# LOADING ENV FILE
-include .env

.PHONY: moken property setup

# DEFAULT VARIABLES
START_LOG = @echo "==================== START OF LOG ===================="
END_LOG = @echo "==================== END OF LOG ======================"

define deploy_moken
	$(START_LOG)
	@forge test
	@forge script script/DeployMoken.s.sol --rpc-url $(RPC_URL) --broadcast -vvv
	$(END_LOG)
endef

define deploy_property
	$(START_LOG)
	@forge test
	@forge script script/DeployProperty.s.sol --rpc-url $(RPC_URL) --broadcast -vvvvv
	$(END_LOG)
endef

setup: .env.tmpl
	forge install
	cp .env.tmpl .env

moken:
	@echo "Deploying moken..."
	@$(deploy_moken)

property:
	@echo "Deploying properties..."
	@$(deploy_property)
