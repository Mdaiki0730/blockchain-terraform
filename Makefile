.PHONY: init-dev
init-dev:
	@cd ./develop ;\
	terraform init ;\

.PHONY: plan-dev
plan-dev:
	@cd ./develop ;\
	terraform plan ;\

.PHONY: apply-dev
apply-dev:
	@cd ./develop ;\
	terraform apply ;\

.PHONY: destroy-dev
destroy-dev:
	@cd ./develop ;\
	terraform destroy ;\

.PHONY: fmt
fmt:
	@terraform fmt ./develop ;\
	terraform fmt ./modules/network ;\
