NETWORK=mainnet

build:
	npx truffle build

deploy-rtoken: build
	npx truffle exec --network $(NETWORK) scripts/deploy-rtoken.js

deploy-rdai: build
	npx truffle exec --network $(NETWORK) scripts/deploy-rdai.js

.PHONY: build deploy-rtoken deploy-rdai
