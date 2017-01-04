.PHONY: clean-pyc clean-build docs help
.DEFAULT_GOAL := help
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

clean: clean-build clean-pyc

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr *.egg-info

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +

lint: ## check style with flake8
	flake8 django_remote_submission tests

doclint: ## check documentation style with flake8
	flake8 --select=D --ignore=F django_remote_submission

test: ## run tests quickly with the default Python
	pytest

test-all: ## run tests on every Python version with tox
	tox

coverage: ## check code coverage quickly with the default Python
	coverage run --source django_remote_submission runtests.py tests
	coverage report -m
	coverage html
	open htmlcov/index.html

docs/.venv.secondary:
	python2.7 -m virtualenv docs/venv && \
	source docs/venv/bin/activate && \
	python2.7 -m pip install -r requirements_docs.txt
	touch $@

docs: docs/.venv.secondary  ## generate Sphinx HTML documentation, including API docs
	source docs/venv/bin/activate && \
	$(MAKE) -C docs clean && \
	$(MAKE) -C docs doctest && \
	$(MAKE) -C docs html && \
	$(BROWSER) docs/_build/html/index.html

release: clean ## package and upload a release
	python setup.py sdist upload
	python setup.py bdist_wheel upload

sdist: clean ## package
	python setup.py sdist
	ls -l dist

makemigrations: ## update migrations with new model changes
	cd example && \
	source venv/bin/activate && \
	python manage.py makemigrations django_remote_submission
