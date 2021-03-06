#!/usr/bin/env bash

# set -Eeo pipefail

############
# 
# This file defines and exports a set of helpful bash functions.
# 
# Before executing, each of these functions will read the .env file in your
# rapids-compose repo. It is safe to edit the .env file while the container
# is running and re-execute any of these commands. The edited value will be
# reflected in the command execution.
# 
# Note: The (✝) character at the beginning of a command's description denotes
#       the command can be run from any directory.
# 
# Note: All commands accept the following optional arguments. These arguments
#       will take precedence over .env configurations. If an argument is
#       omitted, the corresponding .env configuration will be used.
# 
# --rmm         Build librmm and rmm
# --cudf        Build libcudf and cudf (implies --rmm)
# --cuml        Build libcuml and cuml (implies --cudf)
# --cugraph     Build libcugraph and cugraph (implies --cudf)
# --cuspatial   Build libcuspatial and cuspatial (implies --cudf)
# -b, --bench   Build C++ benchmarks
# -t, --tests   Build C++ unit tests
#     --legacy  Build cuDF legacy C++ tests
# -d, --debug   Build C++ with CMAKE_BUILD_TYPE=Debug
# -r, --release Build C++ with CMAKE_BUILD_TYPE=Release
# 
# Examples:
#   build-rmm-cpp --release        Build the librmm C++ library in release mode
#   build-rmm-cpp --debug --tests  Build the librmm C++ library and tests in debug mode
#   clean-rmm-cpp --release        Clean the librmm C++ release mode build artifacts
#                                  for the current git branch, leaving any debug mode
#                                  build artifacts for the current git branch in tact
###
# Project-wide commands:
#
# build-rapids - (✝) Build each enabled RAPIDS project from source in the order
#                    determined by their dependence on each other. For example,
#                    RMM will be built before cuDF because cuDF depends on RMM.
# clean-rapids - (✝) Remove build artifacts for each enabled RAPIDS project
# lint-rapids  - (✝) Lint/fix Cython/Python for each enabled RAPIDS project
#
###
# Commands to build each project separately:
# 
# build-rmm-cpp          - (✝) Build the librmm C++ library
# build-cudf-cpp         - (✝) Build the libcudf C++ library
# build-cuml-cpp         - (✝) Build the libcuml C++ library
# build-cugraph-cpp      - (✝) Build the libcugraph C++ library
# build-cuspatial-cpp    - (✝) Build the libcuspatial C++ library
# 
# build-rmm-python       - (✝) Build the rmm Cython bindings
# build-cudf-python      - (✝) Build the cudf Cython bindings
# build-cuml-python      - (✝) Build the cuml Cython bindings
# build-cugraph-python   - (✝) Build the cugraph Cython bindings
# build-cuspatial-python - (✝) Build the cuspatial Cython bindings
# 
###
# Commands to clean each project separately:
# 
# clean-rmm-cpp          - (✝) Clean the librmm C++ build artifacts for the current git branch
# clean-cudf-cpp         - (✝) Clean the libcudf C++ build artifacts for the current git branch
# clean-cuml-cpp         - (✝) Clean the libcuml C++ build artifacts for the current git branch
# clean-cugraph-cpp      - (✝) Clean the libcugraph C++ build artifacts for the current git branch
# clean-cuspatial-cpp    - (✝) Clean the libcuspatial C++ build artifacts for the current git branch
# 
# clean-rmm-python       - (✝) Clean the rmm Cython build assets
# clean-cudf-python      - (✝) Clean the cudf Cython build assets
# clean-cuml-python      - (✝) Clean the cuml Cython build assets
# clean-cugraph-python   - (✝) Clean the cugraph Cython build assets
# clean-cuspatial-python - (✝) Clean the cuspatial Cython build assets
# 
###
# Commands to lint each Python project separately:
# 
# lint-rmm-python        - (✝) Lint/fix the rmm Cython and Python source files
# lint-cudf-python       - (✝) Lint/fix the cudf Cython and Python source files
# lint-cuml-python       - (✝) Lint/fix the cuml Cython and Python source files
# lint-cugraph-python    - (✝) Lint/fix the cugraph Cython and Python source files
# lint-cuspatial-python  - (✝) Lint/fix the cuspatial Cython and Python source files
# 
###
# Commands to run each project's pytests:
# 
# Note: These commands automatically change into the correct directory before executing `pytest`.
# Note: Pass --debug to use with the VSCode debugger `ptvsd`. All other arguments are forwarded to pytest.
# Note: Arguments that end in '.py' are assumed to be pytest files used to reduce the number of tests
#       collected on startup by pytest. These arguments will be expanded out to their full paths relative
#       to the directory where pytests is run.
# 
# test-rmm-python        - (✝) Run rmm pytests
# test-cudf-python       - (✝) Run cudf pytests
# test-cuml-python       - (✝) Run cuml pytests
# test-cugraph-python    - (✝) Run cugraph pytests
# test-cuspatial-python  - (✝) Run cuspatial pytests
# 
# Usage:
# test-cudf-python -n <num_cores>                               - Run all pytests in parallel with `pytest-xdist`
# test-cudf-python -v -x -k 'a_test_function_name'              - Run all tests named 'a_test_function_name', be verbose, and exit on first fail
# test-cudf-python -v -x -k 'a_test_function_name' --debug      - Run all tests named 'a_test_function_name', and start ptvsd for VSCode debugging
# test-cudf-python -v -x -k 'test_a or test_b' foo/test_file.py - Run all tests named 'test_a' or 'test_b' in file paths matching foo/test_file.py
# 
###
# Misc
# 
# cpp-build-type               - (✝) Function to print the C++ CMAKE_BUILD_TYPE
# cpp-build-dir                - (✝) Function to print the C++ build path relative to a project's C++ source directory
# make-symlink                 - (✝) Function to safely make non-dereferenced symlinks
# update-environment-variables - (✝) Reads the rapids-compose .env file and updates the current shell with the latest values
###

should-build-rmm() {
    update-environment-variables $@ >/dev/null;
    $(should-build-cudf) || [ "$BUILD_RMM" == "YES" ] && echo true || echo false;
}

export -f should-build-rmm;

should-build-cudf() {
    update-environment-variables $@ >/dev/null;
    $(should-build-cuml) || $(should-build-cugraph) || $(should-build-cuspatial) || [ "$BUILD_CUDF" == "YES" ] && echo true || echo false;
}

export -f should-build-cudf;

should-build-cuml() {
    update-environment-variables $@ >/dev/null;
    [ "$BUILD_CUML" == "YES" ] && echo true || echo false;
}

export -f should-build-cuml;

should-build-cugraph() {
    update-environment-variables $@ >/dev/null;
    [ "$BUILD_CUGRAPH" == "YES" ] && echo true || echo false;
}

export -f should-build-cugraph;

should-build-cuspatial() {
    update-environment-variables $@ >/dev/null;
    [ "$BUILD_CUSPATIAL" == "YES" ] && echo true || echo false;
}

export -f should-build-cuspatial;

build-rapids() {
    (
        set -Eeo pipefail
        print-heading "\
Building RAPIDS projects: \
RMM: $(should-build-rmm $@), \
cuDF: $(should-build-cudf $@), \
cuML: $(should-build-cuml $@), \
cuGraph: $(should-build-cugraph $@), \
cuSpatial: $(should-build-cuspatial $@)";
        if [ $(should-build-rmm) == true ]; then build-rmm-cpp $@ || exit 1; fi;
        if [ $(should-build-cudf) == true ]; then build-cudf-cpp $@ || exit 1; fi;
        if [ $(should-build-cuml) == true ]; then build-cuml-cpp $@ || exit 1; fi;
        if [ $(should-build-cugraph) == true ]; then build-cugraph-cpp $@ || exit 1; fi;
        if [ $(should-build-cuspatial) == true ]; then build-cuspatial-cpp $@ || exit 1; fi;
        if [ $(should-build-rmm) == true ]; then build-rmm-python $@ || exit 1; fi;
        if [ $(should-build-cudf) == true ]; then build-cudf-python $@ || exit 1; fi;
        if [ $(should-build-cuml) == true ]; then build-cuml-python $@ || exit 1; fi;
        if [ $(should-build-cugraph) == true ]; then build-cugraph-python $@ || exit 1; fi;
        if [ $(should-build-cuspatial) == true ]; then build-cuspatial-python $@ || exit 1; fi;
    )
}

export -f build-rapids;

clean-rapids() {
    (
        set -Eeo pipefail
        print-heading "\
Cleaning RAPIDS projects: \
RMM: $(should-build-rmm $@), \
cuDF: $(should-build-cudf $@), \
cuML: $(should-build-cuml $@), \
cuGraph: $(should-build-cugraph $@), \
cuSpatial: $(should-build-cuspatial $@)";
        if [ $(should-build-rmm) == true ]; then clean-rmm-cpp $@ || exit 1; fi
        if [ $(should-build-cudf) == true ]; then clean-cudf-cpp $@ || exit 1; fi
        if [ $(should-build-cuml) == true ]; then clean-cuml-cpp $@ || exit 1; fi
        if [ $(should-build-cugraph) == true ]; then clean-cugraph-cpp $@ || exit 1; fi
        if [ $(should-build-cuspatial) == true ]; then clean-cuspatial-cpp $@ || exit 1; fi
        if [ $(should-build-rmm) == true ]; then clean-rmm-python $@ || exit 1; fi
        if [ $(should-build-cudf) == true ]; then clean-cudf-python $@ || exit 1; fi
        if [ $(should-build-cuml) == true ]; then clean-cuml-python $@ || exit 1; fi
        if [ $(should-build-cugraph) == true ]; then clean-cugraph-python $@ || exit 1; fi
        if [ $(should-build-cuspatial) == true ]; then clean-cuspatial-python $@ || exit 1; fi
    )
}

export -f clean-rapids;

lint-rapids() {
    (
        set -Eeo pipefail
        print-heading "\
Linting RAPIDS projects: \
RMM: $(should-build-rmm $@), \
cuDF: $(should-build-cudf $@)";
        if [ $(should-build-rmm) == true ]; then lint-rmm-python $@ || exit 1; fi
        if [ $(should-build-cudf) == true ]; then lint-cudf-python $@ || exit 1; fi
        # if [ $(should-cuml-rmm) ]; then lint-cuml-python $@ || exit 1; fi
        # if [ $(should-cugraph-cudf) ]; then lint-cugraph-python $@ || exit 1; fi
        # if [ $(should-cuspatial-cudf) ]; then lint-cuspatial-python $@ || exit 1; fi
    )
}

export -f lint-rapids;

build-rmm-cpp() {
    update-environment-variables $@ >/dev/null;
    print-heading "Configuring librmm";
    configure-cpp "$RMM_HOME" $@;
    print-heading "Building librmm";
    build-cpp "$RMM_HOME" "all";
}

export -f build-rmm-cpp;

build-cudf-cpp() {
    update-environment-variables $@ >/dev/null;
    print-heading "Configuring libnvstrings and libcudf";

    configure-cpp "$CUDF_HOME/cpp" $@;

    print-heading "Building libnvstrings";

    [ "$BUILD_TESTS" != "ON" ] && \
        BUILD_TARGETS="nvstrings" || \
        BUILD_TARGETS="nvstrings build_tests_nvstrings";

    # temporary:
    # build nvstrings cpp and python before building libcudf, since
    # libcudf depends on libnvstrings having already been built
    build-cpp "$CUDF_HOME/cpp" "$BUILD_TARGETS";
    build-nvstrings-python $@;

    print-heading "Building libcudf";

    [ "$BUILD_TESTS" != "ON" ] && \
        BUILD_TARGETS="cudf" || \
        BUILD_TARGETS="cudf build_tests_cudf";

    # build-cpp "$CUDF_HOME/cpp" "cudf" $@;
    build-cpp "$CUDF_HOME/cpp" "$BUILD_TARGETS";

    if [ "$BUILD_BENCHMARKS" == "ON" ]; then
        build-cpp "$CUDF_HOME/cpp" "benchmarks/all" || true;
    fi
}

export -f build-cudf-cpp;

build-cuml-cpp() {
    update-environment-variables $@ >/dev/null;
    print-heading "Configuring libcuml";
    configure-cpp "$CUML_HOME/cpp" $@;
    print-heading "Building libcuml";
    build-cpp "$CUML_HOME/cpp" "all";
}

export -f build-cuml-cpp;

build-cugraph-cpp() {
    update-environment-variables $@ >/dev/null;
    print-heading "Configuring libcugraph";
    configure-cpp "$CUGRAPH_HOME/cpp" $@;
    print-heading "Building libcugraph";
    build-cpp "$CUGRAPH_HOME/cpp" "all";
}

export -f build-cugraph-cpp;

build-cuspatial-cpp() {
    update-environment-variables $@ >/dev/null;
    print-heading "Configuring libcuspatial";
    configure-cpp "$CUSPATIAL_HOME/cpp" $@;
    print-heading "Building libcuspatial";
    build-cpp "$CUSPATIAL_HOME/cpp" "all";
}

export -f build-cuspatial-cpp;

build-rmm-python() {
    update-environment-variables $@ >/dev/null;
    print-heading "Building rmm";
    build-python "$RMM_HOME/python" --inplace;
}

export -f build-rmm-python;

build-nvstrings-python() {
    update-environment-variables $@ >/dev/null;
    print-heading "Building nvstrings";
    nvstrings_py_dir="$CUDF_HOME/python/nvstrings";
    cfile=$(find "$nvstrings_py_dir/build" -type f -name 'CMakeCache.txt' 2> /dev/null | head -n1);
    [ -z "$(grep $CUDA_VERSION "$cfile" 2> /dev/null)" ] && rm -rf "$nvstrings_py_dir/build";

    PARALLEL_LEVEL=1 \
    build-python "$nvstrings_py_dir" \
        --build-lib="$nvstrings_py_dir" \
        --library-dir="$NVSTRINGS_ROOT" ;
}

export -f build-nvstrings-python;

build-cudf-python() {
    update-environment-variables $@ >/dev/null;
    print-heading "Building cudf";
    build-python "$CUDF_HOME/python/cudf" --inplace;
}

export -f build-cudf-python;

build-cuml-python() {
    update-environment-variables $@ >/dev/null;
    print-heading "Building cuml";
    build-python "$CUML_HOME/python" --inplace;
}

export -f build-cuml-python;

build-cugraph-python() {
    update-environment-variables $@ >/dev/null;
    print-heading "Building cugraph";
    build-python "$CUGRAPH_HOME/python" --inplace;
}

export -f build-cugraph-python;

build-cuspatial-python() {
    update-environment-variables $@ >/dev/null;
    print-heading "Building cuspatial";
    build-python "$CUSPATIAL_HOME/python/cuspatial" --inplace;
}

export -f build-cuspatial-python;

clean-rmm-cpp() {
    update-environment-variables $@ >/dev/null;
    print-heading "Cleaning librmm";
    rm -rf "$RMM_ROOT_ABS";
    find "$RMM_HOME" -type d -name '.clangd' -print0 | xargs -0 -I {} /bin/rm -rf "{}";
}

export -f clean-rmm-cpp;

clean-cudf-cpp() {
    update-environment-variables $@ >/dev/null;
    print-heading "Cleaning libcudf";
    rm -rf "$CUDF_ROOT_ABS" \
           "$CUDF_HOME/python/nvstrings/dist" \
           "$CUDF_HOME/python/nvstrings/build" \
           "$CUDF_HOME/python/nvstrings/.hypothesis" \
           "$CUDF_HOME/python/nvstrings/.pytest_cache";
    find "$CUDF_HOME/python/nvstrings" -type f -name '*.so' -delete;
    find "$CUDF_HOME/python/nvstrings" -type f -name '*.pyc' -delete;
    find "$CUDF_HOME/python/nvstrings" -type d -name '__pycache__' -delete;
    find "$CUDF_HOME" -type d -name '.clangd' -print0 | xargs -0 -I {} /bin/rm -rf "{}";
}

export -f clean-cudf-cpp;

clean-cuml-cpp() {
    update-environment-variables $@ >/dev/null;
    print-heading "Cleaning libcuml";
    rm -rf "$CUML_ROOT_ABS";
    find "$CUML_HOME" -type d -name '.clangd' -print0 | xargs -0 -I {} /bin/rm -rf "{}";
}

export -f clean-cuml-cpp;

clean-cugraph-cpp() {
    update-environment-variables $@ >/dev/null;
    print-heading "Cleaning libcugraph";
    rm -rf "$CUGRAPH_ROOT_ABS";
    find "$CUGRAPH_HOME" -type d -name '.clangd' -print0 | xargs -0 -I {} /bin/rm -rf "{}";
}

export -f clean-cugraph-cpp;

clean-cuspatial-cpp() {
    update-environment-variables $@ >/dev/null;
    print-heading "Cleaning libcuspatial";
    rm -rf "$CUSPATIAL_ROOT_ABS";
    find "$CUSPATIAL_HOME" -type d -name '.clangd' -print0 | xargs -0 -I {} /bin/rm -rf "{}";
}

export -f clean-cuspatial-cpp;

clean-rmm-python() {
    update-environment-variables $@ >/dev/null;
    print-heading "Cleaning rmm";
    rm -rf "$RMM_HOME/python/dist" \
           "$RMM_HOME/python/build";
    find "$RMM_HOME" -type f -name '*.pyc' -delete;
    find "$RMM_HOME" -type d -name '__pycache__' -delete;
}

export -f clean-rmm-python;

clean-cudf-python() {
    update-environment-variables $@ >/dev/null;
    print-heading "Cleaning cudf";
    rm -rf "$CUDF_HOME/.pytest_cache" \
           "$CUDF_HOME/python/cudf/dist" \
           "$CUDF_HOME/python/cudf/build" \
           "$CUDF_HOME/python/.hypothesis" \
           "$CUDF_HOME/python/.pytest_cache" \
           "$CUDF_HOME/python/cudf/.hypothesis" \
           "$CUDF_HOME/python/cudf/.pytest_cache" \
           "$CUDF_HOME/python/dask_cudf/.hypothesis" \
           "$CUDF_HOME/python/dask_cudf/.pytest_cache";
    find "$CUDF_HOME" -type f -name '*.pyc' -delete;
    find "$CUDF_HOME" -type d -name '__pycache__' -delete;
    find "$CUDF_HOME/python/cudf/cudf" -type f -name '*.so' -delete;
    find "$CUDF_HOME/python/cudf/cudf" -type f -name '*.cpp' -delete;
}

export -f clean-cudf-python;

clean-cuml-python() {
    update-environment-variables $@ >/dev/null;
    print-heading "Cleaning cuml";
    rm -rf "$CUML_HOME/python/dist" \
           "$CUML_HOME/python/build" \
           "$CUML_HOME/python/.hypothesis" \
           "$CUML_HOME/python/.pytest_cache" \
           "$CUML_HOME/python/external_repositories";
    find "$CUML_HOME" -type f -name '*.pyc' -delete;
    find "$CUML_HOME" -type d -name '__pycache__' -delete;
    find "$CUML_HOME/python/cuml" -type f -name '*.so' -delete;
    find "$CUML_HOME/python/cuml" -type f -name '*.cpp' -delete;
}

export -f clean-cuml-python;

clean-cugraph-python() {
    update-environment-variables $@ >/dev/null;
    print-heading "Cleaning cugraph";
    rm -rf "$CUGRAPH_HOME/python/dist" \
           "$CUGRAPH_HOME/python/build" \
           "$CUGRAPH_HOME/python/.hypothesis" \
           "$CUGRAPH_HOME/python/.pytest_cache";
    find "$CUGRAPH_HOME" -type f -name '*.pyc' -delete;
    find "$CUGRAPH_HOME" -type d -name '__pycache__' -delete;
    find "$CUGRAPH_HOME/python/cugraph" -type f -name '*.so' -delete;
    find "$CUGRAPH_HOME/python/cugraph" -type f -name '*.cpp' -delete;
}

export -f clean-cugraph-python;

clean-cuspatial-python() {
    update-environment-variables $@ >/dev/null;
    print-heading "Cleaning cuspatial";
    rm -rf "$CUSPATIAL_HOME/python/.hypothesis" \
           "$CUSPATIAL_HOME/python/.pytest_cache" \
           "$CUSPATIAL_HOME/python/cuspatial/dist" \
           "$CUSPATIAL_HOME/python/cuspatial/build" \
           "$CUSPATIAL_HOME/python/cuspatial/.hypothesis" \
           "$CUSPATIAL_HOME/python/cuspatial/.pytest_cache";
    find "$CUSPATIAL_HOME" -type f -name '*.pyc' -delete;
    find "$CUSPATIAL_HOME" -type d -name '__pycache__' -delete;
    find "$CUSPATIAL_HOME/python/cuspatial/cuspatial" -type f -name '*.so' -delete;
    find "$CUSPATIAL_HOME/python/cuspatial/cuspatial" -type f -name '*.cpp' -delete;
}

export -f clean-cuspatial-python;

lint-rmm-python() {
    print-heading "Linting rmm" && lint-python "$RMM_HOME";
}

export -f lint-rmm-python;

lint-cudf-python() {
    print-heading "Linting cudf" && lint-python "$CUDF_HOME";
}

export -f lint-cudf-python;

lint-cuml-python() {
    print-heading "Linting cuml" && lint-python "$CUML_HOME";
}

export -f lint-cuml-python;

lint-cugraph-python() {
    print-heading "Linting cugraph" && lint-python "$CUGRAPH_HOME";
}

export -f lint-cugraph-python;

lint-cuspatial-python() {
    print-heading "Linting cuspatial" && lint-python "$CUSPATIAL_HOME";
}

export -f lint-cuspatial-python;

test-rmm-python() {
    test-python "$RMM_HOME/python" $@;
}

export -f test-rmm-python;

test-cudf-python() {
    test-python "$CUDF_HOME/python/cudf" $@;
}

export -f test-cudf-python;

test-dask-cudf-python() {
    test-python "$CUDF_HOME/python/dask_cudf" $@;
}

export -f test-dask-cudf-python;

test-cuml-python() {
    test-python "$CUML_HOME/python" $@;
}

export -f test-cuml-python;

test-cugraph-python() {
    test-python "$CUGRAPH_HOME/python" $@;
}

export -f test-cugraph-python;

test-cuspatial-python() {
    test-python "$CUSPATIAL_HOME/python/cuspatial" $@;
}

export -f test-cuspatial-python;

configure-cpp() {
    (
        set -Eeo pipefail
        D_CMAKE_ARGS=$(update-environment-variables ${@:2});

        PROJECT_CPP_HOME="$(find-cpp-home $1)";
        PROJECT_HOME="$(find-project-home $PROJECT_CPP_HOME)";
        PROJECT_CPP_BUILD_DIR="$(find-cpp-build-home $PROJECT_CPP_HOME)";
        BUILD_DIR="$PROJECT_CPP_HOME/$(cpp-build-dir $PROJECT_CPP_HOME)";
        mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";

        D_CMAKE_ARGS="$D_CMAKE_ARGS
            -D GPU_ARCHS=
            -D CONDA_BUILD=0
            -D CMAKE_CXX11_ABI=ON
            -D ARROW_USE_CCACHE=ON
            -D CMAKE_EXPORT_COMPILE_COMMANDS=ON
            -D BUILD_TESTS=${BUILD_TESTS:-OFF}
            -D BUILD_BENCHMARKS=${BUILD_BENCHMARKS:-OFF}
            -D CMAKE_ENABLE_BENCHMARKS=${BUILD_BENCHMARKS:-OFF}
            -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-Release}
            -D BUILD_LEGACY_TESTS=${BUILD_LEGACY_TESTS:-OFF}
            -D RMM_LIBRARY=${RMM_LIBRARY}
            -D CUDF_LIBRARY=${CUDF_LIBRARY}
            -D CUDFTESTUTIL_LIBRARY=${CUDFTESTUTIL_LIBRARY}
            -D CUML_LIBRARY=${CUML_LIBRARY}
            -D CUGRAPH_LIBRARY=${CUGRAPH_LIBRARY}
            -D CUSPATIAL_LIBRARY=${CUSPATIAL_LIBRARY}
            -D NVSTRINGS_LIBRARY=${NVSTRINGS_LIBRARY}
            -D NVCATEGORY_LIBRARY=${NVCATEGORY_LIBRARY}
            -D NVTEXT_LIBRARY=${NVTEXT_LIBRARY}
            -D RMM_INCLUDE=${RMM_INCLUDE}
            -D CUDF_INCLUDE=${CUDF_INCLUDE}
            -D CUDF_TEST_INCLUDE=${CUDF_TEST_INCLUDE}
            -D CUML_INCLUDE_DIR=${CUML_INCLUDE}
            -D DLPACK_INCLUDE=${COMPOSE_INCLUDE}
            -D NVSTRINGS_INCLUDE=${NVSTRINGS_INCLUDE}
            -D CUGRAPH_INCLUDE=${CUGRAPH_INCLUDE}
            -D CUSPATIAL_INCLUDE=${CUSPATIAL_INCLUDE}
            -D PARALLEL_LEVEL=${PARALLEL_LEVEL}
            -D CMAKE_INSTALL_PREFIX=${PROJECT_CPP_BUILD_DIR}
            -D CMAKE_SYSTEM_PREFIX_PATH=${CONDA_HOME}/envs/rapids";

        CMAKE_GENERATOR="Ninja";

        if [ "${DISABLE_DEPRECATION_WARNINGS:-OFF}" == "ON" ]; then
            D_CMAKE_ARGS="$D_CMAKE_ARGS
            -D DISABLE_DEPRECATION_WARNING=ON
            -D CMAKE_C_FLAGS=-Wno-deprecated-declarations
            -D CMAKE_CXX_FLAGS=-Wno-deprecated-declarations
            -D CMAKE_CUDA_FLAGS=-Xcompiler=-Wno-deprecated-declarations";
        fi;

        if [ "$PROJECT_HOME" == "$CUGRAPH_HOME" ]; then
            D_CMAKE_ARGS="$D_CMAKE_ARGS
            -D LIBCYPHERPARSER_INCLUDE=${CONDA_HOME}/envs/rapids/include
            -D LIBCYPHERPARSER_LIBRARY=${CONDA_HOME}/envs/rapids/lib/libcypher-parser.a";
        elif [ "$PROJECT_HOME" == "$CUML_HOME" ]; then
            D_CMAKE_ARGS="$D_CMAKE_ARGS
            -D WITH_UCX=ON
            -D BUILD_CUML_TESTS=${BUILD_TESTS:-OFF}
            -D BUILD_PRIMS_TESTS=${BUILD_TESTS:-OFF}
            -D BUILD_CUML_MG_TESTS=${BUILD_TESTS:-OFF}
            -D BUILD_CUML_BENCH=${BUILD_BENCHMARKS:-OFF}
            -D BUILD_CUML_PRIMS_BENCH=${BUILD_BENCHMARKS:-OFF}
            -D BLAS_LIBRARIES=${CONDA_HOME}/envs/rapids/lib/libblas.so";
        elif [ "$PROJECT_HOME" == "$CUSPATIAL_HOME" ]; then
            D_CMAKE_ARGS="$D_CMAKE_ARGS
            -D CONDA_LINK_DIRS=${CONDA_HOME}/envs/rapids/lib
            -D CONDA_INCLUDE_DIRS=${CONDA_HOME}/envs/rapids/include";
        fi;

        # Create or remove ccache compiler symlinks
        set-gcc-version $GCC_VERSION;

        # CMAKE_CUDA_CREATE_ASSEMBLY_SOURCE and CMAKE_CUDA_CREATE_PREPROCESSED_SOURCE are
        # missing in CMake 3.17.0, but still used when -G"Unix Makefiles" is specified...?

        export CONDA_PREFIX_="$CONDA_PREFIX"; unset CONDA_PREFIX;
        JOBS=$PARALLEL_LEVEL                                                 \
        PARALLEL_LEVEL=$PARALLEL_LEVEL                                       \
        CMAKE_GENERATOR="$CMAKE_GENERATOR"                                   \
            cmake -G"$CMAKE_GENERATOR" $D_CMAKE_ARGS "$PROJECT_CPP_HOME"     \
                  -D CMAKE_CUDA_CREATE_ASSEMBLY_SOURCE='<CMAKE_CUDA_COMPILER> <DEFINES> <FLAGS> -ptx <SOURCE> -o <ASSEMBLY_SOURCE>'      \
                  -D CMAKE_CUDA_CREATE_PREPROCESSED_SOURCE='<CMAKE_CUDA_COMPILER> <DEFINES> <FLAGS> -E <SOURCE> > <PREPROCESSED_SOURCE>' \
        && fix-nvcc-clangd-compile-commands "$PROJECT_CPP_HOME" "$BUILD_DIR" \
        ;
        export CONDA_PREFIX="$CONDA_PREFIX_"; unset CONDA_PREFIX_;
    )
}

export -f configure-cpp;

build-cpp() {
    BUILD_TARGETS="${2:-all}";
    (
        set -Eeo pipefail;
        cd "$(find-cpp-home $1)";
        BUILD_DIR_PATH="$(find-cpp-build-home $1)"
        time cmake --build "$BUILD_DIR_PATH" -- $BUILD_TARGETS;
        [ $? == 0 ] && [[ "$(cpp-build-type)" == "release" || -z "$(create-cpp-launch-json)" || true ]];
    )
}

export -f build-cpp;

build-python() {
    (
        cd "$1";
        # Create or remove ccache compiler symlinks
        set-gcc-version $GCC_VERSION;
        CFLAGS_="${CFLAGS:-}";
        CFLAGS_="${CFLAGS_:+$CFLAGS_ }-Wno-reorder";
        CFLAGS_="${CFLAGS_:+$CFLAGS_ }-Wno-unknown-pragmas";
        CFLAGS_="${CFLAGS_:+$CFLAGS_ }-Wno-unused-variable";
        if [ "${DISABLE_DEPRECATION_WARNINGS:-OFF}" == "ON" ]; then
            CFLAGS_="${CFLAGS_:+$CFLAGS_ }-Wno-deprecated-declarations";
        fi;
        export CONDA_PREFIX_="$CONDA_PREFIX"; unset CONDA_PREFIX;
        time env CFLAGS="$CFLAGS_" \
             CXXFLAGS="${CXXFLAGS:+$CXXFLAGS }$CFLAGS_" \
             python setup.py build_ext -j${PARALLEL_LEVEL} ${@:2};
        export CONDA_PREFIX="$CONDA_PREFIX_"; unset CONDA_PREFIX_;
        rm -rf ./*.egg-info;
    )
}

export -f build-python;

lint-python() {
    (
        cd "$1";
        bash "$COMPOSE_HOME/etc/rapids/lint.sh" || true;
    )
}

export -f lint-python;

set-gcc-version() {
    V="${1:-}";
    if [[ $V != "5" && $V != "7" && $V != "8" ]]; then
        while true; do
            read -p "Please select GCC version 5, 7, or 8: " V </dev/tty
            case $V in
                [578]* ) break;;
                * ) >&2 echo "Invalid GCC version, please select 5, 7, or 8";;
            esac
        done
    fi
    echo "Using gcc-$V and g++-$V"
    export GCC_VERSION="$V"
    export CXX_VERSION="$V"
    export CC="/usr/local/bin/gcc-$GCC_VERSION"
    export CXX="/usr/local/bin/g++-$CXX_VERSION"
    echo "rapids" | sudo -S update-alternatives --set gcc /usr/bin/gcc-${GCC_VERSION} >/dev/null 2>&1;
    echo "rapids" | sudo -S update-alternatives --set g++ /usr/bin/g++-${CXX_VERSION} >/dev/null 2>&1;
    # Create or remove ccache compiler symlinks
    if [ "$USE_CCACHE" == "YES" ]; then
        export NVCC="/usr/local/bin/nvcc"
        echo "rapids" | sudo -S ln -s -f "$(which ccache)" "/usr/local/bin/gcc"                        >/dev/null 2>&1;
        echo "rapids" | sudo -S ln -s -f "$(which ccache)" "/usr/local/bin/nvcc"                       >/dev/null 2>&1;
        echo "rapids" | sudo -S ln -s -f "$(which ccache)" "/usr/local/bin/gcc-$GCC_VERSION"           >/dev/null 2>&1;
        echo "rapids" | sudo -S ln -s -f "$(which ccache)" "/usr/local/bin/g++-$CXX_VERSION"           >/dev/null 2>&1;
    else
        export NVCC="$CUDA_HOME/bin/nvcc"
        echo "rapids" | sudo -S rm "/usr/local/bin/nvcc"  || true                                      >/dev/null 2>&1;
        echo "rapids" | sudo -S ln -s -f "/usr/bin/gcc" "/usr/local/bin/gcc"                           >/dev/null 2>&1;
        echo "rapids" | sudo -S ln -s -f "/usr/bin/gcc-$GCC_VERSION" "/usr/local/bin/gcc-$GCC_VERSION" >/dev/null 2>&1;
        echo "rapids" | sudo -S ln -s -f "/usr/bin/g++-$CXX_VERSION" "/usr/local/bin/g++-$CXX_VERSION" >/dev/null 2>&1;
    fi
}

export -f set-gcc-version;

test-python() {
    (
        args="";
        paths="";
        debug="false";
        py_regex='.*\.py$';
        arg_regex='^[\-]+';
        number_regex='^[0-9]+$';
        nprocs_regex='^\-n[0-9]*$';
        set -x; cd "$1"; { set +x; } 2>/dev/null; shift;
        while [[ "$#" -gt 0 ]]; do
            # match patterns: [-n, -n auto, -n<nprocs>, -n <nprocs>]
            if [[ $1 =~ $nprocs_regex ]]; then
                args="${args:+$args }$1";
                if [[ "${1#-n}" == "" ]]; then
                    if ! [[ $2 =~ $number_regex ]]; then
                        args="${args:+$args }auto";
                    else
                        args="${args:+$args }$2"; shift;
                    fi;
                fi;
            else
                # match all other pytest arguments/test file names
                case "$1" in
                    --debug) debug="true";;
                    # fuzzy-match test file names and expand to full paths
                    *.py) paths="${paths:+$paths }$(fuzzy-find $1)";;
                    # Match pytest args
                    -*) arr="";
                        args="${args:+$args }$1";
                        # greedy-match args until the next `-<arg>` or .py file
                        while ! [[ "$#" -lt 1 || $2 =~ $arg_regex || $2 =~ $py_regex ]]; do
                            arr="${arr:+$arr }$2"; shift;
                        done;
                        # if only found one sub-argument, append to pytest args list
                        # if multiple, wrap in single-quotes (e.g. -k 'this or that')
                        arr=(${arr});
                        [[ ${#arr[@]} -eq 1 ]] && args="$args ${arr[*]}";
                        [[ ${#arr[@]} -gt 1 ]] && args="$args '${arr[*]}'";
                        ;;
                    *) args="${args:+$args }$1";;
                esac;
            fi; shift;
        done;
        if [[ $debug != true ]]; then
            eval "set -x; pytest $args $paths";
        else
            eval "set -x; python -m ptvsd --host 0.0.0.0 --port 5678 --wait -m pytest $args $paths";
        fi
    )
}

export -f test-python;

fix-nvcc-clangd-compile-commands() {
    (
        set -Eeo pipefail;
        ###
        # Make a few modifications to the compile_commands.json file
        # produced by CMake. This file is used by clangd to provide fast
        # and smart intellisense, but `clang-10` doesn't yet support all
        # the nvcc compilation options. This block translates or removes
        # unsupported options, so `clangd` has an easier time producing
        # usable intellisense results.
        ###
        CC_JSON="$2/compile_commands.json";
        CC_JSON_LINK="$1/compile_commands.json";
        CC_JSON_CLANGD="$2/compile_commands.clangd.json";

        # todo: should define `-D__CUDACC__` here?

        CUDA_VERSION_MAJOR=$(echo $CUDA_SHORT_VERSION | tr -d '.' | cut -c 1-2);
        CUDA_VERSION_MINOR=$(echo $CUDA_SHORT_VERSION | tr -d '.' | cut -c 3);

        CLANG_NVCC_OPTIONS="-I$CUDA_HOME/include";
        CLANG_CUDA_OPTIONS=$(echo $(echo "
            -nocudalib
            -nodefaultlibs
            --no-cuda-version-check
            -D__CUDACC_VER_MAJOR__=$CUDA_VERSION_MAJOR
            -D__CUDACC_VER_MINOR__=$CUDA_VERSION_MINOR"));
        CLANG_CUDA_OPTIONS="-x cuda $CLANG_CUDA_OPTIONS";
        ALLOWED_WARNINGS=$(echo $(echo '
            -Wno-unknown-pragmas
            -Wno-c++17-extensions
            -Wno-unevaluated-expression'));

        REPLACE_CROSS_EXECUTION_SPACE_CALL="-Wno-unevaluated-expression=cross-execution-space-call/";
        REPLACE_DEPRECATED_DECL_WARNINGS=",-Wno-error=deprecated-declarations/ -Wno-deprecated-declarations";

        GPU_GENCODE_COMPUTE="-gencode=arch=([^\-])* ";
        GPU_ARCH_SM="-gencode=arch=compute_.*,code=sm_";

        # 1. Remove the second compiler invocation following the `&&`
        # 2. Transform -gencode arch=compute_X,sm_Y to --cuda-gpu-arch=sm_Y
        # 3. Remove unsupported -gencode options
        # 4. Remove unsupported --expt-extended-lambda option
        # 5. Remove unsupported --expt-relaxed-constexpr option
        # 6. Rewrite `-Wall,-Werror` to be `-Wall -Werror`
        # 7. Change `-x cu` to `-x cuda`, plus other clangd cuda options
        # 8. Add `-I$CUDA_HOME/include` to nvcc invocations
        # 9. Add flags to disable certain warnings for intellisense
        # 10. Replace -Wno-error=deprecated-declarations
        # 11. Remove -Wno-unevaluated-expression=cross-execution-space-call
        # 12. Remove -forward-unknown-to-host-compiler
        # 13. Rewrite `-Xcompiler=` to `-Xcompiler `
        # 14. Rewrite `-Xcompiler` to `-Xarch_host`
        # 15. Rewrite /usr/local/bin/gcc to /usr/bin/gcc
        # 16. Rewrite /usr/local/bin/g++ to /usr/bin/g++
        # 17. Rewrite /usr/local/bin/nvcc to /usr/local/cuda/bin/nvcc
        cat "$CC_JSON"                                         \
        | sed -r "s/ &&.*[^\$DEP_FILE]/\",/g"                  \
        | sed -r "s/$GPU_ARCH_SM/--cuda-gpu-arch=sm_/g"        \
        | sed -r "s/$GPU_GENCODE_COMPUTE//g"                   \
        | sed -r "s/ --expt-extended-lambda/ /g"               \
        | sed -r "s/ --expt-relaxed-constexpr/ /g"             \
        | sed -r "s/-Wall,-Werror/-Wall -Werror/g"             \
        | sed -r "s! -x cu ! $CLANG_CUDA_OPTIONS !g"           \
        | sed -r "s!nvcc !nvcc $CLANG_NVCC_OPTIONS !g"         \
        | sed -r "s/-Werror/-Werror $ALLOWED_WARNINGS/g"       \
        | sed -r "s/$REPLACE_DEPRECATED_DECL_WARNINGS/g"       \
        | sed -r "s/$REPLACE_CROSS_EXECUTION_SPACE_CALL/g"     \
        | sed -r "s/ -forward-unknown-to-host-compiler//g"     \
        | sed -r "s/-Xcompiler=/-Xcompiler /g"                 \
        | sed -r "s/-Xcompiler/-Xarch_host/g"                  \
        | sed -r "s@/usr/local/bin/gcc@/usr/bin/gcc@g"         \
        | sed -r "s@/usr/local/bin/g\+\+@/usr/bin/g\+\+@g"     \
        | sed -r "s@/usr/local/bin/nvcc@$CUDA_HOME/bin/nvcc@g" \
        > "$CC_JSON_CLANGD"                                    ;

        # symlink compile_commands.json to the project root so clangd can find it
        make-symlink "$CC_JSON_CLANGD" "$CC_JSON_LINK";
    )
}

export -f fix-nvcc-clangd-compile-commands;

fuzzy-find() {
    (
        for p in ${@}; do
            path="${p#./}"; # remove leading ./ (if exists)
            ext="${p##*.}"; # extract extension (if exists)
            if [[ $ext == $p ]];
                then echo $(find .                -print0 | grep -FzZ $path | tr '\0' '\n');
                else echo $(find . -name "*.$ext" -print0 | grep -FzZ $path | tr '\0' '\n');
            fi;
        done
    )
}

export -f fuzzy-find;

join-list-contents() {
    local IFS='' delim=$1; shift; echo -n "$1"; shift; echo -n "${*/#/$delim}";
}

export -f join-list-contents;

create-cpp-launch-json() {
    (
        cd "$(find-cpp-home ${1:-$PWD})"
        mkdir -p "$PWD/.vscode";
        BUILD_DIR=$(cpp-build-dir $PWD);
        TESTS_DIR="$PWD/build/debug/gtests";
        PROJECT_NAME="${PWD#$RAPIDS_HOME/}";
        TEST_NAMES=$(ls $TESTS_DIR 2>/dev/null || echo "");
        TEST_NAMES=$(echo \"$(join-list-contents '","' $TEST_NAMES)\");
        cat << EOF > "$PWD/.vscode/launch.json"
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "$PROJECT_NAME",
            "type": "cppdbg",
            "request": "launch",
            "stopAtEntry": false,
            "externalConsole": false,
            "cwd": "$PWD",
            "envFile": "\${workspaceFolder:compose}/.env",
            "MIMode": "gdb", "miDebuggerPath": "/usr/local/cuda/bin/cuda-gdb",
            "program": "$TESTS_DIR/\${input:TEST_NAME}",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "environment": []
        },
    ],
    "inputs": [
        {
            "id": "TEST_NAME",
            "type": "pickString",
            "description": "Please select a test to run",
            "options": [$TEST_NAMES]
        }
    ]
}
EOF
    )
}

export -f create-cpp-launch-json;

print-heading() {
    echo -e "\n\n################\n#\n# $1 \n#\n################\n\n"
}

export -f print-heading;

find-project-home() {
    PROJECT_HOMES="\
    $RMM_HOME
    $CUDF_HOME
    $CUML_HOME
    $CUGRAPH_HOME
    $CUSPATIAL_HOME
    $NOTEBOOKS_HOME
    $NOTEBOOKS_EXTENDED_HOME";
    CURDIR="$(realpath ${1:-$PWD})"
    for PROJECT_HOME in $PROJECT_HOMES; do
        if [ -n "$(echo "$CURDIR" | grep "$PROJECT_HOME" - || echo "")" ]; then
            echo "$PROJECT_HOME"; break;
        fi;
    done
}

export -f find-project-home;

find-cpp-home() {
    PROJECT_HOME="$(find-project-home $@)";
    if [ "$PROJECT_HOME" != "$RMM_HOME" ]; then
        PROJECT_HOME="$PROJECT_HOME/cpp"
    fi;
    echo "$PROJECT_HOME";
}

export -f find-cpp-home;

find-cpp-build-home() {
    echo "$(find-cpp-home $@)/build/$(cpp-build-type)";
}

export -f find-cpp-build-home;

cpp-build-type() {
    echo "${CMAKE_BUILD_TYPE:-Release}" | tr '[:upper:]' '[:lower:]'
}

export -f cpp-build-type;

cpp-build-dir() {
    (
        cd "$1"
        _BUILD_DIR="$(git branch --show-current)";
        _BUILD_DIR="cuda-$CUDA_VERSION/${_BUILD_DIR//\//__}"
        echo "build/$_BUILD_DIR/$(cpp-build-type)";
    )
}

export -f cpp-build-dir;

make-symlink() {
    SRC="$1"; DST="$2";
    CUR=$(readlink "$2" || echo "");
    [ -z "$SRC" ] || [ -z "$DST" ] || \
    [ "$CUR" = "$SRC" ] || ln -f -n -s "$SRC" "$DST"
}

export -f make-symlink;

update-environment-variables() {
    set -a && . "$COMPOSE_HOME/.env" && set +a;
    unset NVIDIA_VISIBLE_DEVICES;
    args=
    tests=
    bench=
    btype=
    build_rmm=
    build_cudf=
    build_cuml=
    build_cugraph=
    build_cuspatial=
    legacy_tests=
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -b|--bench) bench="${bench:-ON}";;
            -t|--tests) tests="${tests:-ON}";;
            -d|--debug) btype="${btype:-Debug}";;
            -r|--release) btype="${btype:-Release}";;
            --rmm) build_rmm="${build_rmm:-YES}";;
            --cudf) build_cudf="${build_cudf:-YES}";;
            --cuml) build_cuml="${build_cuml:-YES}";;
            --cugraph) build_cugraph="${build_cugraph:-YES}";;
            --cuspatial) build_cuspatial="${build_cuspatial:-YES}";;
            --legacy) legacy_tests="${legacy_tests:-ON}";;
            *) args="${args:+$args }$1";;
        esac; shift;
    done
    export BUILD_RMM="${build_rmm:-$BUILD_RMM}"
    export BUILD_CUDF="${build_cudf:-$BUILD_CUDF}"
    export BUILD_CUML="${build_cuml:-$BUILD_CUML}"
    export BUILD_CUGRAPH="${build_cugraph:-$BUILD_CUGRAPH}"
    export BUILD_CUSPATIAL="${build_cuspatial:-$BUILD_CUSPATIAL}"
    export BUILD_TESTS="${tests:-$BUILD_TESTS}";
    export BUILD_BENCHMARKS="${bench:-$BUILD_BENCHMARKS}";
    export CMAKE_BUILD_TYPE="${btype:-$CMAKE_BUILD_TYPE}";
    export BUILD_LEGACY_TESTS="${legacy_tests:-$BUILD_LEGACY_TESTS}";
    if [ ${CONDA_PREFIX:-""} != "" ]; then
        source "$CONDA_PREFIX/etc/conda/activate.d/env-vars.sh"
    fi
    # return the rest of the unparsed args
    echo "$args";
}

export -f update-environment-variables;

# set +Eeo pipefail
