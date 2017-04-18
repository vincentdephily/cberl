# Copyright 2012 Erlware, LLC. All Rights Reserved.
#
# This file is provided to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file
# except in compliance with the License.  You may obtain
# a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

DEPS_PLT=$(CURDIR)/_build/default/rebar3_*_plt

# =============================================================================
# Verify that the programs we need to run are installed on this system
# =============================================================================
ERL = $(shell which erl)

ifeq ($(ERL),)
$(error "Erlang not available on this system")
endif

REBAR=$(CURDIR)/rebar3

ifeq ($(REBAR),)
$(error "Rebar not available on this system")
endif

.PHONY: all compile doc clean test dialyzer typer shell distclean pdf \
  update-deps clean-common-test-data rebuild

all: deps compile dialyzer test

# =============================================================================
# Rules to build the system
# =============================================================================

deps:
	$(REBAR) get-deps
	$(REBAR) compile

update-deps:
	$(REBAR) update-deps
	$(REBAR) compile

compile:
	$(REBAR) compile

doc:
	$(REBAR) edoc

eunit: compile clean-common-test-data
	$(REBAR) eunit

test: compile eunit

dialyzer:
	$(REBAR) dialyzer

typer:
	typer --plt $(DEPS_PLT) -r ./src -I ./include

shell: deps compile
# You often want *rebuilt* rebar tests to be available to the
# shell you have to call eunit (to get the tests
# rebuilt). However, eunit runs the tests, which probably
# fails (thats probably why You want them in the shell). This
# runs eunit but tells make to ignore the result.
	- @$(REBAR) eunit
	$(REBAR) shell

pdf:
	pandoc README.md -o README.pdf

clean:
	$(REBAR) clean

distclean: clean
	rm -rf _build

rebuild: distclean deps compile escript dialyzer test
