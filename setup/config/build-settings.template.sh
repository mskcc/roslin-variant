export BUILD_THREADS="{{ build_threads }}"
export INSTALL_CORE="{{ build_core }}"
export BUILD_DOCKER="{{ build_docker }}"
export BUILD_SINGULARITY="{{ build_singularity }}"
export DOCKER_REGISTRY="{{ docker_registry }}"
export DOCKER_PUSH="{{ docker_push }}"
export USE_VAGRANT="{{ use_vagrant }}"
export BUILD_CACHE="{{ build_cache }}"
{{ load_singularity }}
singularity_bin_path=`dirname $ROSLIN_SINGULARITY_PATH`
export PATH=$singularity_bin_path:$PATH
