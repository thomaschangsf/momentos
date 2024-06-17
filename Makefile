# Makefile
SHELL = /bin/bash

.PHONY: help
help:
	@echo "Commands:"
	@echo "venv    : creates a virtual environment."
	@echo "static   : executes static analysis."
	@echo "style   : executes style formatting."
	@echo "clean   : cleans all unnecessary files."
	@echo "test    : execute tests on code, data and models."
	@echo "appJupyter : run jupyter notebook"
	@echo "appStreamlit : run streamlit app"
	@echo "appWeb  : run fastapi app"
	@echo "dockerBuildImage  : build docker image"
	@echo "dockerStartApps  : start docker apps"
	@echo "dockerStopApps  : stop docker apps"
	@echo "dockerCleanUp  : perform various docker cleanups (images, containers..)"




# Static Analysis with Radon
.PHONY: static
static:
	# Static analysis on app folder
	radon cc apps/streamlit/*.py -s


# Styling
.PHONY: style
style:
	black .
	flake8 apps captum_kernel
	isort .

# Environment
.ONESHELL:
venv:
	python3 -m venv venv
	source venv/bin/activate && \
	python3 -m pip install --upgrade pip setuptools wheel && \
	python3 -m pip install -e ".[dev]" && \
	pre-commit install && \
	pre-commit autoupdate

# Cleaning
.PHONY: clean
clean: style
	find . -type f -name "*.DS_Store" -ls -delete
	find . | grep -E "(__pycache__|\.pyc|\.pyo)" | xargs rm -rf
	find . | grep -E ".pytest_cache" | xargs rm -rf
	find . | grep -E ".ipynb_checkpoints" | xargs rm -rf
	find . | grep -E ".trash" | xargs rm -rf
	rm -f .coverage

# Test
.PHONY: test
test:
	pytest

.PHONY: dvc
dvc:
	dvc add data/projects.csv
	dvc add data/tags.csv
	dvc add data/labeled_projects.csv
	dvc push

.PHONY: appJupyter
appJupyter:
	venv/bin/jupyter notebook

.PHONY: appStreamlit
appStreamlit:
	streamlit  run apps/streamlit/app_textgen_openai.py

.PHONY: appWeb
appWeb:
	venv/bin/gunicorn -c config/gunicorn.py -k uvicorn.workers.UvicornWorker apps.web.api:app


.PHONY: appWebGoPythonClient
appWebGoPythonClient:
	venv/bin/python


.PHONY: dockerBuildImage
dockerBuildImage:
	docker rmi -f nebulakernel:latest
	docker build -t nebulakernel:latest -f devops/Dockerfile .
	docker images | grep nebulakernel

.PHONY: dockerStartApps
dockerStartApps:
	docker-compose -f devops/docker-compose.yml up -d

.PHONY: dockerStopApps
dockerStopApps:
	docker-compose -f devops/docker-compose.yml down

.PHONY: dockerCleanUp
dockerCleanUp:
	# Remove exited containers
	docker rm $(docker ps -a -f status=exited -q)

	# Remove dangling images; all images not associated with a container will be deleted. BE CAREFUL.
	#docker image prune -a

	# Even more aggressive; remove all stopped containers, unused network, and cache
	#docker system prune -a

