/*
 *  * To change this template, choose Tools | Templates
 *   * and open the template in the editor.
 *    */
package org.mskcc.bic.qcpdf;

/**
 *  *
 *   * @author byrne
 *    */

import java.io.FileOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import java.util.Arrays;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

import java.text.DecimalFormat;


public class QCSummary {

    private static final String AUTO_STATUS_HEADER = "Auto-status";
    private static final String SAMPLE_HEADER = "Sample";
    private static final String UNEXPECTED_MATCHES_HEADER = "Unexpected Match(es)";
    private static final String UNEXPECTED_MISMATCHES_HEADER = "Unexpected Mismatch(es)";
    private static final String MAJOR_CONTAMINATION_HEADER = "Major Contamination";
    private static final String MINOR_CONTAMINATION_HEADER = "Minor Contamination";
    private static final String COVERAGE_HEADER = "Coverage";
    private static final String DUPLICATION_HEADER = "Duplication";
    private static final String LIBRARY_SIZE_HEADER = "Library Size (millions)";
    private static final String ON_BAIT_HEADER = "On Bait Bases (millions)";
    private static final String ALIGNED_READS_HEADER = "Aligned Reads (millions)";
    private static final String INSERT_PEAK_HEADER = "Insert Size Peak";
    private static final String TRIMMED_READS_HEADER = "Percentage Trimmed Reads";
    private static final String PROJECT_AVERAGE_INDICATOR = "Project Average";

    private static final List<String> ALL_METRICS = Arrays.asList(AUTO_STATUS_HEADER,UNEXPECTED_MATCHES_HEADER,UNEXPECTED_MISMATCHES_HEADER,
                                                                  MAJOR_CONTAMINATION_HEADER,MINOR_CONTAMINATION_HEADER,COVERAGE_HEADER,
                                                                  DUPLICATION_HEADER,LIBRARY_SIZE_HEADER,ON_BAIT_HEADER,ALIGNED_READS_HEADER,
                                                                  INSERT_PEAK_HEADER,TRIMMED_READS_HEADER);

    private Integer numSamplesWithUnexpectedMatch;
    private Integer numSamplesWithUnexpectedMismatch;
    private Integer numSamplesWithCdnaContamination;
    private Integer numGenesWithCdnaContamination;
    private Float averageMajorContamination;          //average fraction of postions that are heterozygous
    private Float averageMinorContamination;          //average minor allele frequency
    private Float averageCoverage;                    //across all samples (millions)
    private Float averageCoverageTumors;              //across tumors only (millions)
    private Float averageCoverageNormals;            //across normals only (millions)
    private Float averageDuplication;
    private Float averageLibrarySize;                    // millions
    private Float averageOnBaitPercentage;
    private Float averageAlignedReads;                   // millions   
    private Float averageInsertPeak;
    private Float averagePercentageTrimmedReads;	
    private Float totalNumClusters;
    private Float totalPercentageBothReadsAligned;
    private Float averageOnNearBaitPercentage;
    private Float averageOnTargetPercentage;

    private String clusterDensityStatus;
    private String captureSpecificityStatus;
    private String insertSizeStatus;
    private String sampleLabelStatus;
    private String contaminationStatus;
    private String duplicationStatus;
    private String librarySizeStatus;
    private String coverageStatus;

    private String minorContaminationFailures;
    private String majorContaminationFailures;
    private String cdnaContaminationFailures;
    private String duplicationFailures;
    private String insertSizeFailures;
    private String unexpectedMatches;
    private String unexpectedMismatches;
    private String coverageFailures;
    private String librarySizeFailures;

    private Map<String, Map<String, Map<String, Object>>> summaryMap = new HashMap<>(); //Map<Sample, <Metric, <['value'|'status'], Object>>>
    private Map<String, String> qcConfigurations;

    public QCSummary(String projectSummaryFile, String detailSummaryFile, Map<String, String> qcConfigurations){
        // to do: validate files
        storeProjectSummary(projectSummaryFile);
        storeSampleDetail(detailSummaryFile);
        this.qcConfigurations = qcConfigurations;
    }

    public void storeProjectSummary(String projectSummaryFile){
        /*
        * Parse summary file and store values as appropriate data type
        * for later use.     
        */

        try{
            BufferedReader buf = new BufferedReader(new FileReader(projectSummaryFile));
            List<String> headers = Arrays.asList(buf.readLine().split("\t"));
            String[] values;

            int statusIdx = headers.indexOf("AutoStatus");
            int metricIdx = headers.indexOf("Metric");
            int catIdx = headers.indexOf("Category");
            int descIdx = headers.indexOf("SummaryDescription");
            int valIdx = headers.indexOf("SummaryValue");
            int failIdx = headers.indexOf("Failures");

            while(true){
                String line = buf.readLine();
                if(line == null){
                    break;
                } else{
                values = line.split("\t");
                if(values[metricIdx].equals("Cluster Density")){
                    this.clusterDensityStatus = values[statusIdx];
                    if(values[descIdx].equals("All aligned reads (millions)")){
                        try {
                            this.totalNumClusters = Float.parseFloat(values[valIdx]);
                        } catch (NumberFormatException nfe){
                            this.totalNumClusters = null;
                        }
                    } else if(values[descIdx].equals("Total % both reads aligned")){
                        try {
                            this.totalPercentageBothReadsAligned = Float.parseFloat(values[valIdx]);
                        } catch (NumberFormatException nfe){
                            this.totalPercentageBothReadsAligned = null;
                        }
                    }
                } else if(values[metricIdx].equals("Capture Specificity")){
                    this.captureSpecificityStatus = values[statusIdx];
                    if(values[descIdx].equals("Average % on/near bait")){
                        try{
                            this.averageOnNearBaitPercentage = Float.parseFloat(values[valIdx]);
                        } catch (NumberFormatException nfe){
                            this.averageOnNearBaitPercentage = null;
                        }
                    } else if (values[descIdx].equals("Average % on bait")){
                        try{
                            this.averageOnBaitPercentage = Float.parseFloat(values[valIdx]);
                        } catch(NumberFormatException nfe){
                            this.averageOnBaitPercentage = null;
                        }
                    } else if (values[descIdx].equals("Average % on target")){
                        try{
                            this.averageOnTargetPercentage = Float.parseFloat(values[valIdx]);
                        } catch(NumberFormatException nfe){
                            this.averageOnTargetPercentage = null;
                        }
                    }
                } else if(values[metricIdx].equals("Sample Labeling Errors")){
                    this.sampleLabelStatus = values[statusIdx];
                    if(values[catIdx].equals("Unexpected Matches")){
                        try {
                            this.numSamplesWithUnexpectedMatch = Integer.parseInt(values[valIdx]);
                        } catch (NumberFormatException nfe){
                            this.numSamplesWithUnexpectedMatch = null;
                        }
                        this.unexpectedMatches = values[failIdx];
                    } else if (values[catIdx].equals("Unexpected Mismatches")){
                        try {
                            this.numSamplesWithUnexpectedMismatch = Integer.parseInt(values[valIdx]);
                        } catch (NumberFormatException nfe){
                            this.numSamplesWithUnexpectedMismatch = null;
                        }
                        this.unexpectedMismatches = values[failIdx];
                    }
                } else if(values[metricIdx].equals("Contamination")){
                        this.contaminationStatus = values[statusIdx];
                    if(values[descIdx].equals("Average fraction of positions that are heterozygous")){
                        this.majorContaminationFailures = values[failIdx];
                        try{
                            this.averageMajorContamination = Float.parseFloat(values[valIdx]);
                        } catch(NumberFormatException nfe){
                            this.averageMajorContamination = null;
                        }
                    } else if (values[descIdx].equals("Average minor allele frequency")){
                        this.minorContaminationFailures = values[failIdx];
                        try{
                            this.averageMinorContamination = Float.parseFloat(values[valIdx]);
                        } catch (NumberFormatException nfe){
                            this.averageMajorContamination = null;
                        }
                    } else if (values[descIdx].equals("Number of genes")){
                        this.numGenesWithCdnaContamination = Integer.parseInt(values[valIdx]);
                        this.cdnaContaminationFailures = values[failIdx];
                    }
                } else if(values[metricIdx].equals("Target Coverage")){
                    this.coverageStatus = values[statusIdx];
                    if(values[descIdx].equals("Mean across ALL samples (millions)")){
                        this.coverageFailures = values[failIdx];
                        try{
                            this.averageCoverage = Float.parseFloat(values[valIdx]);
                        } catch(NumberFormatException nfe){
                            this.averageCoverage = null;
                        }
                    } else if(values[descIdx].equals("Mean across NORMAL samples (millions)")){
                        try{
                            this.averageCoverageNormals = Float.parseFloat(values[valIdx]);
                        } catch (Exception e){
                            this.averageCoverageNormals = new Float(0.0); //temporarily
                        }
                    } else if(values[descIdx].equals("Mean across TUMOR samples (millions)")){
                        try{
                            this.averageCoverageTumors = Float.parseFloat(values[valIdx]);
                        } catch (Exception e){
                            this.averageCoverageTumors = new Float(0.0); //temp
                        }
                    } 
                } else if(values[metricIdx].equals("Insert Size")){
                    this.insertSizeStatus = values[statusIdx];
                    this.insertSizeFailures = values[failIdx];
                    if(values[descIdx].equals("Mean Peak")){
                        try{
                            this.averageInsertPeak = Float.parseFloat(values[valIdx]);
                        } catch (NumberFormatException nfe){
                            this.averageInsertPeak = null;
                        }
                    }
                } else if(values[metricIdx].equals("Duplication")){
                    this.duplicationStatus = values[statusIdx];
                    this.duplicationFailures = values[failIdx];
                    try{
                        this.averageDuplication = Float.parseFloat(values[valIdx]);
                    } catch(NumberFormatException nfe){
                        this.averageDuplication = null;
                    }
                } else if(values[metricIdx].equals("Library Size")){
                    this.librarySizeStatus = values[statusIdx];
                    try{
                        this.averageLibrarySize = Float.parseFloat(values[valIdx]);
                    } catch(NumberFormatException nfe){
                        this.averageLibrarySize = null;
                    }
                }
              }        
            }
        } catch (Exception e){
            e.printStackTrace();
        }
    }

    public void storeSampleDetail(String detailSummaryFile){
        /*
        * Parse sample detail file and store values, assign pass/warn/fail
        * status based on fixed thresholds
        */

        try{
            BufferedReader buf = new BufferedReader(new FileReader(detailSummaryFile));
            List<String> headers = Arrays.asList(buf.readLine().split("\t"));
            String[] values;
            String samp;
            DecimalFormat twoD = new DecimalFormat("0.00");
            DecimalFormat dfInt = new DecimalFormat("#");
            Float coverageFail = QCConstants.IMPACT_COVERAGE_FAIL;
            if(qcConfigurations.containsKey(QCConstants.COVERAGE_FAIL)){
               coverageFail = Float.parseFloat(qcConfigurations.get(QCConstants.COVERAGE_FAIL));
            }
            Float coverageWarn = QCConstants.IMPACT_COVERAGE_WARN;
            if(qcConfigurations.containsKey(QCConstants.COVERAGE_WARN)){
               coverageWarn = Float.parseFloat(qcConfigurations.get(QCConstants.COVERAGE_WARN));
            }
            Float dupWarn = QCConstants.IMPACT_DUPLICATION_WARN;
            if(qcConfigurations.containsKey(QCConstants.DUPLICATION_WARN)){
               dupWarn = Float.parseFloat(qcConfigurations.get(QCConstants.DUPLICATION_WARN));
            }
            Float majorContFail = QCConstants.IMPACT_MAJOR_CONTAMINATION_FAIL;
            if(qcConfigurations.containsKey(QCConstants.MAJOR_CONTAMINATION_FAIL)){
               majorContFail = Float.parseFloat(qcConfigurations.get(QCConstants.MAJOR_CONTAMINATION_FAIL));
            }
            Float minorContFail = QCConstants.IMPACT_MINOR_CONTAMINATION_FAIL; 
            if(qcConfigurations.containsKey(QCConstants.MINOR_CONTAMINATION_FAIL)){
               minorContFail = Float.parseFloat(qcConfigurations.get(QCConstants.MINOR_CONTAMINATION_FAIL));
            }
            while(true){
                String line = buf.readLine();
                if(line == null){
                    break;
                } else {
                    values = line.split("\t");
                    samp = values[headers.indexOf(SAMPLE_HEADER)];
                    String status = "PASS";

                    HashMap<String, Map<String,Object>> valMap = new HashMap<>();
                
                    valMap.put(AUTO_STATUS_HEADER, new HashMap<String, Object>());
                    valMap.get(AUTO_STATUS_HEADER).put("value",values[headers.indexOf(AUTO_STATUS_HEADER)]);
                    valMap.get(AUTO_STATUS_HEADER).put("status",status);                    

                    String un = new String(values[headers.indexOf(UNEXPECTED_MATCHES_HEADER)].replace("<br>"," "));
                    if(un.length() > 0 & !un.startsWith("None")){
                        status = "FAIL";
                    }
                    valMap.put(UNEXPECTED_MATCHES_HEADER, new HashMap<String, Object>());
                    valMap.get(UNEXPECTED_MATCHES_HEADER).put("value",un);
                    valMap.get(UNEXPECTED_MATCHES_HEADER).put("status",status); 

                    status = "PASS";
                    un = new String(values[headers.indexOf(UNEXPECTED_MISMATCHES_HEADER)].replace("<br>"," "));
                    if(un.length() > 0 & !un.startsWith("None")){
                        status = "FAIL";
                    }
                    valMap.put(UNEXPECTED_MISMATCHES_HEADER,  new HashMap<String, Object>());
                    valMap.get(UNEXPECTED_MISMATCHES_HEADER).put("value",un);
                    valMap.get(UNEXPECTED_MISMATCHES_HEADER).put("status",status);

                    status = "PASS";
                    Float val;
                    try{
                        val = new Float(values[headers.indexOf(MAJOR_CONTAMINATION_HEADER)]);
                    } catch (NumberFormatException e){
                        val = new Float(0.0);
                    }
                    if (val > majorContFail){
                        status = "FAIL";
                    }
                    valMap.put(MAJOR_CONTAMINATION_HEADER, new HashMap<String, Object>());
                    valMap.get(MAJOR_CONTAMINATION_HEADER).put("value",twoD.format(val));
                    valMap.get(MAJOR_CONTAMINATION_HEADER).put("status",status);

                    status = "PASS";
                    try{    
                        val = new Float(values[headers.indexOf(MINOR_CONTAMINATION_HEADER)]);
                    } catch (NumberFormatException e){
                        val = new Float(0.0);
                    }
                    if (val > minorContFail){
                        status = "FAIL";
                    }
                    valMap.put(MINOR_CONTAMINATION_HEADER, new HashMap<String, Object>());
                    valMap.get(MINOR_CONTAMINATION_HEADER).put("value",twoD.format(val));
                    valMap.get(MINOR_CONTAMINATION_HEADER).put("status",status);

                    status = "PASS";
                    Integer cov;
                    try{
                        cov = new Integer(values[headers.indexOf(COVERAGE_HEADER)]);
                        if (cov < coverageFail){
                            status = "FAIL";
                        } else if (cov < coverageWarn){
                            status = "WARN";
                        }
                    } catch (NumberFormatException e){
                        cov = 0;
                    }
                    valMap.put(COVERAGE_HEADER, new HashMap<String, Object>());
                    valMap.get(COVERAGE_HEADER).put("value",dfInt.format((cov)));
                    valMap.get(COVERAGE_HEADER).put("status",status);

                    status = "PASS";
                    try{
                        val = new Float(values[headers.indexOf(DUPLICATION_HEADER)]);
                        if (val > dupWarn){
                            status = "WARN";
                        }
                    } catch (NumberFormatException e){
                        val = new Float(0.0);
                    }
                    valMap.put(DUPLICATION_HEADER, new HashMap<String, Object>());
                    valMap.get(DUPLICATION_HEADER).put("value",twoD.format(val));
                    valMap.get(DUPLICATION_HEADER).put("status",status);

                    status = "PASS"; //we do NOT have auto thresholds for the metrics below
                    valMap.put(LIBRARY_SIZE_HEADER, new HashMap<String, Object>());
                    try{
                        valMap.get(LIBRARY_SIZE_HEADER).put("value",dfInt.format(new Integer(values[headers.indexOf(LIBRARY_SIZE_HEADER)])));
                    } catch(NumberFormatException nfe){
                        valMap.get(LIBRARY_SIZE_HEADER).put("value",dfInt.format(0));
                    }
                    valMap.get(LIBRARY_SIZE_HEADER).put("status",status);

                    valMap.put(ON_BAIT_HEADER, new HashMap<String, Object>());
                    try{
                        valMap.get(ON_BAIT_HEADER).put("value",dfInt.format(new Integer(values[headers.indexOf(ON_BAIT_HEADER)])));
                    } catch(NumberFormatException e){
                        valMap.get(ON_BAIT_HEADER).put("value",0);
                    }
                    valMap.get(ON_BAIT_HEADER).put("status",status);

                    valMap.put(ALIGNED_READS_HEADER, new HashMap<String, Object>());
                    try{
                        valMap.get(ALIGNED_READS_HEADER).put("value",dfInt.format(new Integer(values[headers.indexOf(ALIGNED_READS_HEADER)])));
                    } catch(NumberFormatException e){
                        valMap.get(ALIGNED_READS_HEADER).put("value",0);
                    }
                    valMap.get(ALIGNED_READS_HEADER).put("status",status);

                    valMap.put(INSERT_PEAK_HEADER, new HashMap<String, Object>());
                    try{
                        valMap.get(INSERT_PEAK_HEADER).put("value",dfInt.format(new Integer(values[headers.indexOf(INSERT_PEAK_HEADER)])));
                    } catch(NumberFormatException e){
                        valMap.get(INSERT_PEAK_HEADER).put("value",0);
                    }
                    valMap.get(INSERT_PEAK_HEADER).put("status",status);

                    valMap.put(TRIMMED_READS_HEADER, new HashMap<String, Object>());
                    try{
                        valMap.get(TRIMMED_READS_HEADER).put("value",twoD.format(new Float(values[headers.indexOf(TRIMMED_READS_HEADER)])));
                    } catch(NumberFormatException nfe){
                        valMap.get(TRIMMED_READS_HEADER).put("value",0);
                    }
                    valMap.get(TRIMMED_READS_HEADER).put("status",status);
                    summaryMap.put(samp, valMap);

                }
            }

            buf.close();

        } catch (Exception e){
            e.printStackTrace();
        }

    }

    public int getLongestSampleName(){
        int longest = 0;
        for(Map.Entry<String, Map<String, Map<String, Object>>> sampleMetrics : summaryMap.entrySet()) {
            String sampleID = sampleMetrics.getKey();
            if(sampleID.length()>longest){
                longest = sampleID.length();
            }
        }
        return longest;
    }

    public String getProjectAverageIndicator(){
        return this.PROJECT_AVERAGE_INDICATOR;
    }

    public List<String> getAllMetricsHeaders(){
        return this.ALL_METRICS;
    }

    public int getNumMetrics(){
        return this.ALL_METRICS.size();
    }

    public Map<String, Map<String, Map<String, Object>>> getSummaryMap(){
        return this.summaryMap;
    }

    public Float getAverageMajorContamination(){
        return this.averageMajorContamination;
    }

    public Float getAverageMinorContamination(){
        return this.averageMinorContamination;
    }

    public Float getAverageCoverage(){
        return this.averageCoverage;
    }

    public Float getAverageCoverageNormals(){
        return this.averageCoverageNormals;
    }

    public Float getAverageCoverageTumors(){
        return this.averageCoverageTumors;
    }

    public Float getAverageDuplication(){
        return this.averageDuplication;
    }

    public Float getAverageLibrarySize(){
        return this.averageLibrarySize;
    }

    public Float getAverageOnBaitPercentage(){
        return this.averageOnBaitPercentage;
    }

    public Float getAverageOnNearBaitPercentage(){
        return this.averageOnNearBaitPercentage;
    }

    public Float getAverageOnTargetPercentage(){
        return this.averageOnTargetPercentage;
    }

    public Float getAverageAlignedReads(){
        return this.averageAlignedReads;
    }

    public Float getTotalNumClusters(){
        return this.totalNumClusters;
    }

    public Float getTotalPercentageBothReadsAligned(){
        return this.totalPercentageBothReadsAligned;
    }

    public Float getAverageInsertPeak(){
        return this.averageInsertPeak;
    }

    public Float getAveragePercentageTrimmedReads(){
        return this.averagePercentageTrimmedReads;
    }

    public Integer getNumSamplesWithUnexpectedMatch(){
        return this.numSamplesWithUnexpectedMatch;
    }

    public Integer getNumSamplesWithUnexpectedMismatch(){
        return this.numSamplesWithUnexpectedMismatch;
    }

    public Integer getNumSamplesWithCdnaContamination(){
        return this.numSamplesWithCdnaContamination;
    }

    public Integer getNumGenesWithCdnaContamination(){
        return this.numGenesWithCdnaContamination;
    }

    public String getClusterDensityStatus(){
        return this.clusterDensityStatus;
    }

    public String getCaptureSpecificityStatus(){
        return this.captureSpecificityStatus;
    }

    public String getInsertSizeStatus(){
        return this.insertSizeStatus;
    }

    public String getSampleLabelStatus(){
        return this.sampleLabelStatus;
    }

    public String getContaminationStatus(){
        return this.contaminationStatus;
    }

    public String getDuplicationStatus(){
        return this.duplicationStatus;
    }

    public String getLibrarySizeStatus(){
        return this.librarySizeStatus;
    }

    public String getCoverageStatus(){
        return this.coverageStatus;
    }

    public String getMinorContaminationFailures(){
        return this.minorContaminationFailures;
    }

    public String getMajorContaminationFailures(){
        return this.majorContaminationFailures;
    }

    public String getCdnaContaminationFailures(){
        return this.cdnaContaminationFailures;
    }

    public String getDuplicationFailures(){
        return this.duplicationFailures;
    }

    public String getLibrarySizeFailures(){
        return this.librarySizeFailures;
    }

    public String getInsertSizeFailures(){
        return this.insertSizeFailures;
    }

    public String getUnexpectedMatches(){
        return this.unexpectedMatches;
    }

    public String getUnexpectedMismatches(){
        return this.unexpectedMismatches;
    }

    public String getCoverageFailures(){
        return this.coverageFailures;
    }

}
