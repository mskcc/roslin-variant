package org.mskcc.bic.qcpdf;

public class QCConstants{
    protected static final String COVERAGE_FAIL = "CoverageFail" ;
    protected static final String COVERAGE_WARN = "CoverageWarn";
    protected static final String DUPLICATION_WARN = "DuplicationWarn"; 
    protected static final String MAJOR_CONTAMINATION_FAIL = "MajorContaminationFail"; 
    protected static final String MINOR_CONTAMINATION_FAIL = "MinorContaminationFail"; 

    protected static final Float IMPACT_COVERAGE_FAIL = new Float(50);
    protected static final Float IMPACT_COVERAGE_WARN = new Float(200);
    protected static final Float IMPACT_DUPLICATION_WARN = new Float(50);
    protected static final Float IMPACT_MAJOR_CONTAMINATION_FAIL = new Float(0.55);
    protected static final Float IMPACT_MINOR_CONTAMINATION_FAIL = new Float(0.02);



}
