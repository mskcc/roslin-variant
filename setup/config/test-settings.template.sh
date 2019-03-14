export ROSLIN_TEST_ROOT="{{ test_root }}"
export ROSLIN_TEST_BATCHSYSTEM="{{ test_batchsystem }}"
export ROSLIN_TEST_CWL_BATCHSYSTEM="{{ test_cwl_batchsystem }}"
export ROSLIN_TEST_RUN_ARGS="{{ test_run_args }}"
export TMPDIR="{{ test_tmp }}"
export TMP="{{ test_tmp }}"
{{ test_env }}
if [[ $SINGULARITY_BIND == *"$TMPDIR"* && -n "$TMPDIR" ]]
then
	export SINGULARITY_BIND="$SINGULARITY_BIND,$TMPDIR"
fi

if [[ $SINGULARITY_BIND == *"$TMP"* && -n "$TMP" ]]
then
	export SINGULARITY_BIND="$SINGULARITY_BIND,$TMP"
fi