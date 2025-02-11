# syntax = devthefuture/dockerfile-x
# The INCLUDE directive is provided by the devthefuture/dockerfile-x project

# Will copy in the base configuration for the build
INCLUDE ./docker/common/base.dockerfile

# Snippets
INCLUDE ./docker/snippets/micromamba.dockerfile

# Will copy in other common configurations for this build
INCLUDE ./docker/common/common.dockerfile

# Complete the build
INCLUDE ./docker/common/final.dockerfile
