#!/bin/bash

set -e

dub build
./tools/build_snippets.d
