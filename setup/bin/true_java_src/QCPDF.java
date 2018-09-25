/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.mskcc.bic.qcpdf;

import java.util.List;
import java.awt.image.BufferedImage;
import java.io.*;
import com.sampullara.cli.*;
import com.itextpdf.text.DocumentException;

/**
 *
 * @author byrne
 */
public class QCPDF {
    
    /**
     * @param args the command line arguments
     */
    @Argument(alias = "rf", description = "Project Request File", required = false)
    private static String requestFile;

    @Argument(alias = "p", description = "Project to get samples for", required = false)
    private static String project;

    @Argument(alias = "piName", description = "Full name of PI", required = false)
    private static String pi;

    @Argument(alias = "piID", description = "PI's MSKCC id (email)", required = false)
    private static String piID;

    @Argument(alias = "invName", description = "Full name of Investigator", required = false)
    private static String inv;

    @Argument(alias = "invID", description = "Investigator's MSKCC id (email)", required = false)
    private static String invID;

    @Argument(alias = "r", description = "Pipeline Run Number", required = false)
    private static String runNum;

    @Argument(alias = "a", description = "Assay", required = false)
    private static String assay;

    @Argument(alias = "v", description = "Pipeline SVN revision number", required = true)
    private static String pipelineVersion;

    @Argument(alias = "d", description = "Project metrics directory", required = true)
    private static String metricsDirectory;

    @Argument(alias = "o", description = "Output directory", required = true)
    private static String outputDirectory;

    @Argument(alias = "pl", description = "Pipeline name", required = false)
    private static String pipeline;

    @Argument(alias = "cf", description = "Coverage fail threshold", required = false)
    private static String coverageFail;

    @Argument(alias = "cw", description = "Coverage warning threshold", required = false)
    private static String coverageWarn;

    @Argument(alias = "dupWarn", description = "Duplication warnig threshold", required = false)
    private static String duplicationWarn;

    @Argument(alias = "majorCF", description = "Major contamination fail", required = false)
    private static String majorContaminationFail;

    @Argument(alias = "minorCF", description = "Minor contamination fail", required = false)
    private static String minorContaminationFail;

    public static void exitWithError(String msg){
        System.err.println("ERROR: "+msg);
        System.exit(1);
    }

    public static void parseRequest(String requestFile){
       try{
            BufferedReader buf = new BufferedReader(new FileReader(requestFile));
            String[] values;

            while(true){
                String line = buf.readLine();
                if(line == null){
                    break;
                } else{
                    values = line.split(": ");
                    switch(values[0]){
                        case "PI":
                            piID = values[1];
                            break; 
                        case "PI_Name":
                            pi = values[1];
                            break;
                        case "Investigator":
                            invID = values[1];
                            break;
                        case "Investigator_Name":
                            inv = values[1];
                            break;
                        case "ProjectID":
                            project = values[1].replace("Proj_","");
                            break;
                        case "RunNumber":
                            runNum = values[1];
                            break;
                        case "Assay":
                            assay = values[1];
                            break;
                        case "Pipelines":
                            pipeline = values[1].toUpperCase();
                            break;
                    }
                }
            }
        } catch (Exception e){
            e.printStackTrace();
        } 
    }

    public static void main(String[] args) {
        QCPDF q = new QCPDF();
        if( args.length == 0){
            Args.usage(q);
        } else {
            List<String> extra = Args.parse(q, args);

            if(requestFile != null && requestFile.length() > 0){
                File req = new File(requestFile);
                if(!req.exists()){
                    exitWithError("Request file does not exist: "+requestFile);
                }
                // parse request file
                parseRequest(requestFile);
            }

            // some minimal validation on all parameters 
            if (project == null || project.length()<4){
                exitWithError("Missing or invalid project ID");
            }
            if (pi == null || pi.length() == 0){
                exitWithError("Missing or invalid PI Name");
            }
            if (piID == null || piID.length() == 0){
                exitWithError("Missing or invalid PI ID");
            } else {
                if(!piID.contains("@")){
                    piID = piID + "@mskcc.org";
                }
            }             
            if (inv == null || inv.length() == 0){
                exitWithError("Missing or invalid investigator name");
            } 
            if (invID == null || invID.length() == 0){
                exitWithError("Missing or invalid investigator ID");
            } else {
                if(!invID.contains("@")){
                    invID = invID + "@mskcc.org";
                }
            }
            if (runNum == null || runNum.length() == 0){
                exitWithError("Missing or invalid run number");
            }
            if (assay == null || assay.length() == 0){
                exitWithError("Missing or invalid assay");
            }
            if (pipeline == null || pipeline.length() == 0){
                exitWithError("Missing or invalid pipeline name");
            }
            if (pipelineVersion == null || pipelineVersion.length() == 0){
                exitWithError("Missing or invalid pipeline version");
            }
            if (metricsDirectory == null || metricsDirectory.length() == 0){
                exitWithError("Missing or invalid metrics directory");
            } else {
                File md = new File(metricsDirectory);
                if(!md.exists()){
                    exitWithError("Metrics directory does not exist: "+metricsDirectory);
                }
            }
            if (outputDirectory == null || outputDirectory.length() == 0){
                exitWithError("Missing or invalid output directory");
            } else {
               File od = new File(outputDirectory);
               if(!od.exists()){
                   exitWithError("Output directory does not exist: "+outputDirectory);
               }
            }
            q.writeQCPDF();
        }
    }

    private void writeQCPDF(){
        try{
            System.out.println("Writing PDF report for Project "+project+"..."); 

            ReportPDF pdf = new ReportPDF(project,pi,piID,inv,invID,runNum,assay,pipeline,pipelineVersion,metricsDirectory,outputDirectory);
            pdf.writePDF();
    
            System.out.println("Done.");
        
        } catch (IOException e){
            e.printStackTrace();            
        } catch (DocumentException de){
            de.printStackTrace();
        }
    }
}
