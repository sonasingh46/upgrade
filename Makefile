
# deps ensures fresh go.mod and go.sum.
.PHONY: deps
deps:
	@go mod tidy
	@go mod verify

.PHONY: test
test:
	go test ./...

# Specify the name for the binaries
UPGRADE=upgrade

# Specify the name of the docker repo for amd64
UPGRADE_REPO_NAME_AMD64="upgrade-amd64"

# Specify the name of the docker repo for arm64
UPGRADE_REPO_NAME_ARM64="upgrade-arm64"

# build upgrade binary
.PHONY: upgrade
upgrade:
	@echo "----------------------------"
	@echo "--> ${UPGRADE}              "
	@echo "----------------------------"
	@# PNAME is the sub-folder in ./bin where binary will be placed. 
	@# CTLNAME indicates the folder/pkg under cmd that needs to be built. 
	@# The output binary will be: ./bin/${PNAME}/<os-arch>/${CTLNAME}
	@# A copy of the binary will also be placed under: ./bin/${PNAME}/${CTLNAME}
	@PNAME=${UPGRADE} CTLNAME=${UPGRADE} CGO_ENABLED=0 sh -c "'$(PWD)/build/build.sh'"

# docker hub username
HUB_USER?=openebs

ifeq (${IMAGE_TAG}, )
  IMAGE_TAG = ci
  export IMAGE_TAG
endif


# build upgrade image
.PHONY: upgrade-image.amd64
upgrade-image.amd64: upgrade
	@echo "-----------------------------------------------"
	@echo "--> ${UPGRADE} image                           "
	@echo "${HUB_USER}/${UPGRADE_REPO_NAME}:${IMAGE_TAG}"
	@echo "-----------------------------------------------"
	@cp bin/${UPGRADE}/${UPGRADE} build/${UPGRADE}
	@cd build/${UPGRADE} && \
	 sudo docker build -t "${HUB_USER}/${UPGRADE_REPO_NAME_AMD64}:${IMAGE_TAG}" --build-arg BUILD_DATE=${BUILD_DATE} .
	@rm build/${UPGRADE}/${UPGRADE}

.PHONY: upgrade-image.arm64
upgrade-image.arm64: upgrade
	@echo "-----------------------------------------------"
	@echo "--> ${UPGRADE} image                           "
	@echo "${HUB_USER}/${UPGRADE_REPO_NAME_ARM64}:${IMAGE_TAG}"
	@echo "-----------------------------------------------"
	@cp bin/${UPGRADE}/${UPGRADE} build/${UPGRADE}
	@cd build/${UPGRADE} && \
	 sudo docker build -t "${HUB_USER}/${UPGRADE_REPO_NAME_ARM64}:${IMAGE_TAG}" --build-arg BUILD_DATE=${BUILD_DATE} .
	@rm build/${UPGRADE}/${UPGRADE}




# cleanup upgrade build
.PHONY: cleanup-upgrade
cleanup-upgrade: 
	rm -rf ${GOPATH}/bin/${UPGRADE}