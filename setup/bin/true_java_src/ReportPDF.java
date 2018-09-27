package org.mskcc.bic.qcpdf;

/**
 *
 * @author byrne
 */
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Image;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.PdfReader;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfImportedPage;
import com.itextpdf.text.pdf.PdfPageEventHelper;
import com.itextpdf.text.pdf.ColumnText;
import com.itextpdf.text.Anchor;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.GrayColor;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Rectangle;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.Chunk;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;

import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;
import java.util.SortedSet;
import java.util.TreeSet;
import java.text.DecimalFormat;
import java.util.Collections;
import java.lang.Math;
import java.util.Date;
import java.text.SimpleDateFormat;


public class ReportPDF {

    class MyFooter extends PdfPageEventHelper {
        Font ffont = new Font(Font.FontFamily.UNDEFINED, 8);
 
        public void onEndPage(PdfWriter writer, Document document){
            PdfContentByte cb = writer.getDirectContent();
            Phrase footer;
            if(writer.getPageNumber()>1){ //we don't want a page number on the cover page
                footer = new Phrase(Integer.toString(writer.getPageNumber()-1), ffont); //subtract one for the cover page
            } else {
                footer = new Phrase(" ",ffont);
            }
            ColumnText.showTextAligned(cb, Element.ALIGN_CENTER,
                    footer,
                    (document.right() - document.left()) / 2 + document.leftMargin(),
                    document.bottom() - 10, 0);
        }
    }
	
    String[] reportImgNames;
	
    int pageNum = 0;    

    private String id;
    private String pi;
    private String piID;
    private String inv;
    private String invID;
    private String runNum;
    private String assay;
    private String pipeline;
    private String pipelineVersion;
    private String metricsDir;
    private String reportPDFname;
    private String outputDir;
    private Document reportPDF;
    private PdfWriter writer;
    private Map<String, PdfPTable> docMap = new HashMap<String, PdfPTable>();

    private QCSummary qcSummary;

    private static final BaseColor TABLE_SUMMARY_COLOR = new BaseColor(230,230,230);
    private static final BaseColor TABLE_HEADER_COLOR = new BaseColor(200,200,200);
    private static final BaseColor STATUS_COLUMN_PASS_COLOR = new BaseColor(50,205,50);
    private static final BaseColor STATUS_COLUMN_WARN_COLOR = new BaseColor(255,255,102);
    private static final BaseColor STATUS_COLUMN_FAIL_COLOR = new BaseColor(255,0,0);
    private static final BaseColor DATA_CELL_WARN_COLOR = new BaseColor(255,255,200);
    private static final BaseColor DATA_CELL_FAIL_COLOR = new BaseColor(255,225,225);

    private static final Font captionFont = new Font(Font.FontFamily.HELVETICA, 10);
    private static final Font header = new Font(Font.FontFamily.HELVETICA, 24);
    private static final Font header2 = new Font(Font.FontFamily.HELVETICA, 18);
    private static final Font header3 = new Font(Font.FontFamily.HELVETICA, 12);
    private static final Font tableHeaderFont = new Font(Font.FontFamily.HELVETICA, 8);
    private static final Font dataFont = new Font(Font.FontFamily.HELVETICA, 8);

    // KEEP AN ORDERED LIST OF DOCUMENT ELEMENTS
    // THIS IS THE ORDER THE ELEMENTS WILL BE ADDED TO THE DOC
    private static final List<String> REPORT_ELEMENTS = Arrays.asList("Project QC Summary Table",
                                                                      "Sample Info Table", 
                                                                      "Sample QC Summary Table",
                                                                      "Alignment (absolute) Plot",
                                                                      "Alignment (percentage) Plot",
                                                                      "Capture Specificity (absolute) Plot",
                                                                      "Capture Specificity (percentage) Plot",
                                                                      "Insert Size Distribution Plot",
                                                                      "Insert Size Peaks Plot",
                                                                      "Sample Mislabeling Plot",
                                                                      "Unexpected Matches Table",
                                                                      "Unexpected Mismatches Table",
                                                                      "Major Contamination Plot",
                                                                      "Minor Contamination Plot",
                                                                      "cDNA Contamination Plot",
                                                                      "Duplication Plot",
                                                                      "Library Size Plot",
                                                                      "Coverage Plot",
                                                                      "Trimmed Reads Plot",
                                                                      "Base Qualities Plot",
                                                                      "GC Content Plot"
                                                                      );
    // FOR EVERY ELEMENT KEEP A SHORT NAME TO BE USED
    // FOR ANCHORS WITHIN THE DOCUMENT
    private static final List<String> ELEMENT_NAMES = Arrays.asList("projectSummary",
                                                                    "sampleInfo",
                                                                    "sampleSummary",
                                                                    "alignmentAbsolute",
                                                                    "alignmentPercentage",
                                                                    "captureSpecificityAbsolute",
                                                                    "captureSpecificityPercentage",
                                                                    "insertSizeDistribution",
                                                                    "insertSizePeaks",
                                                                    "sampleMislabeling",
                                                                    "unexpectedMatches",
                                                                    "unexpectedMismatches",
                                                                    "majorContamination",
                                                                    "minorContamination",
                                                                    "cdnaContamination",
                                                                    "duplication",
                                                                    "librarySize",
                                                                    "coverage",
                                                                    "trimmedReads",
                                                                    "baseQualities",
                                                                    "gcContent"
                                                                    );
                                                                    


    public ReportPDF(String id, String pi, String piID, String inv, String invID, String runNum, String assay, String pipeline, String pipelineVersion, String metricsDir, String outputDir) throws FileNotFoundException, DocumentException{
        this.id = id;
        this.pi = pi;
        this.piID = piID;
        this.inv = inv;
        this.invID = invID;
        this.runNum = runNum;
        this.assay = assay;
        this.pipeline = pipeline;
        this.pipelineVersion = pipelineVersion;
        this.reportImgNames = reportImgNames;
        this.metricsDir = metricsDir;
        this.reportPDFname = "Proj_" + this.id + "_QC_Report.pdf";
        this.outputDir = outputDir;
        this.reportPDF = new Document(PageSize.LETTER.rotate());
        this.writer = PdfWriter.getInstance(this.reportPDF, new FileOutputStream(outputDir+"/"+reportPDFname));
   }
	
    public void writePDF(){
	try{
            String projectSumFile = this.metricsDir + "/Proj_" + this.id + "_ProjectSummary.txt";
            String sampleSumFile = this.metricsDir + "/Proj_" + this.id + "_SampleSummary.txt";

            this.qcSummary = new QCSummary(projectSumFile,sampleSumFile);
            //PdfWriter writer = PdfWriter.getInstance(this.reportPDF, new FileOutputStream(outputDir+"/"+reportPDFname)); 
            writer.setStrictImageSequence(true);
      
            // set up footer to contain page numbers
            MyFooter event = new MyFooter();
            writer.setPageEvent(event); 
            PdfPTable footer = new PdfPTable(1);
            footer.setWidthPercentage(90);
            footer.getDefaultCell().setHorizontalAlignment(Element.ALIGN_RIGHT);

            this.reportPDF.open();

            // initialize document map
            this.initializeDocMap();

            // create a PdfPTable for each element of the report and store it in the docMap 
            // summary table
            this.createProjectSummaryTable();
            // detail table with highlighted warnings/failures
            this.createSampleSummaryTable();           
            // figures
            this.createFigureTables();
            // tables
            this.createDataTables();

            // write cover page and table of contents directly to document
            // cover page
            this.writeCoverPage();
            // table of contents
            this.writeTableOfContents();

            // finally, add elements in docMap
            for(String re: this.REPORT_ELEMENTS){
                if(this.getPageSpan(this.docMap.get(re))>0){
                    this.reportPDF.newPage();
                    this.reportPDF.add(this.docMap.get(re));
                }
            }       

	    this.reportPDF.close();	
	}catch(Exception e){
	    e.printStackTrace();
	}
    }

    public void writeTableOfContents()  throws IOException, DocumentException {
        /*
        Write a TOC page with links to each element
        */
        this.reportPDF.newPage();

        int pageNum = 2; //toc will be page 1; first fig/table will be on page 2

        PdfPTable table = new PdfPTable(2);
        table.setTotalWidth(this.reportPDF.getPageSize().getWidth() - this.reportPDF.leftMargin()*4 - this.reportPDF.rightMargin()*4);
        table.setLockedWidth(true);
        PdfPCell descCell;
        PdfPCell pageNumCell;

        table = this.addTableTitle(table,"Report Contents","Report Contents");

        for(String re : this.REPORT_ELEMENTS){
            if(this.getPageSpan(this.docMap.get(re))>0){

                Chunk x = new Chunk(re);
                x.setLocalGoto(this.ELEMENT_NAMES.get(this.REPORT_ELEMENTS.indexOf(re))); 
                Paragraph p = new Paragraph(x);
                descCell = new PdfPCell(p);
                descCell.setBorder(Rectangle.NO_BORDER);
                table.addCell(descCell);

                x = new Chunk(Integer.toString(pageNum),header3);
                x.setLocalGoto(this.ELEMENT_NAMES.get(this.REPORT_ELEMENTS.indexOf(re)));
                p = new Paragraph(x);
                pageNumCell = new PdfPCell(p);
                pageNumCell.setHorizontalAlignment(Element.ALIGN_RIGHT);            
                pageNumCell.setBorder(Rectangle.NO_BORDER);
                table.addCell(pageNumCell);
            
                pageNum += this.getPageSpan(this.docMap.get(re));
            }
        }
        this.reportPDF.add(table);
        return;
    }

    public void initializeDocMap(){
        /*
        Create a map of document elements where keys are all element names and 
        values are empty tables for now
        */
        for(String re : this.REPORT_ELEMENTS){
            this.docMap.put(re,new PdfPTable(1));
        }
        return;
    }

    public int getPageSpan(PdfPTable table){
       /*
       Calculate how many pages the table will take up
       */
       return (int) Math.ceil(table.getTotalHeight()/this.reportPDF.getPageSize().getHeight()); 
    }

    public void createDataTables() throws IOException, DocumentException {   
        /*
        Create a formatted table for each data table in the document and store
        it in the document map to be added to the document later
        */
        int tableNum = 1;

        File f = new File(this.metricsDir);
        File[] dataFiles = f.listFiles();
        Arrays.sort(dataFiles);

        String dir = this.metricsDir;
        boolean headerInFile = true;

        if(dir.endsWith("metrics")){  // we have a project from variants pipeline; unexp. matches/mismatches
            dir += "/fingerprint";    // are in the fingerprint subdir
            headerInFile = false;
        }

        f = new File(dir);
        dataFiles = f.listFiles();
        Arrays.sort(dataFiles);
        for (final File fileEntry : dataFiles) {
            String fname = fileEntry.getName();
            int numRows = 0; 
            String captionStr = "";
            String pageDesc = "";
            PdfPTable table;            

            if(fname.endsWith("_UnexpectedMatches.txt") || fname.endsWith("_ALL_FPCResultsUnMatch.txt")){
                System.out.println("\tAdding unexpected matches table");
                captionStr = "Unexpected Matches";
                pageDesc = "Unexpected Matches Table";
            } else if(fname.endsWith("_UnexpectedMismatches.txt") || fname.endsWith("_ALL_FPCResultsUnMismatch.txt")){
                System.out.println("\tAdding unexpected mismatches table");
                captionStr = "Unexpected Mismatches";
                pageDesc = "Unexpected Mismatches Table";
            }
            if(captionStr.length()>0){
                try{
                    BufferedReader buf = new BufferedReader(new FileReader(dir + "/" + fname));
                    String[] values;
                    table = new PdfPTable(3);
                    table.setTotalWidth(400);
                    table.setLockedWidth(true); 
                    table = addTableTitle(table,captionStr,pageDesc);

                    table.addCell(this.getHeaderCell(new Phrase("Sample 1",tableHeaderFont)));
                    table.addCell(this.getHeaderCell(new Phrase("Sample 2",tableHeaderFont)));
                    table.addCell(this.getHeaderCell(new Phrase("Fraction of Discordant Alleles",tableHeaderFont)));
                    while(true){
                        String line = buf.readLine();
                        if(line == null || line.length() == 0){
                            break;
                        } else if(line.startsWith("#") || line.startsWith("Sample1") || line.startsWith("---")){
                            continue;
                        } else if(line.contains("Normal_Pool")){
                            continue;
                        } else {
                            values = line.split("\t");
                            numRows++;
                            for(String val : values){
                                table.addCell(this.getDataCell(new Phrase(val,dataFont)));
                            }
                        }
                    }
                    tableNum++;
                    if(numRows == 0){
                        PdfPCell cell = new PdfPCell(new Phrase("None found.",dataFont));
                        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                        cell.setColspan(3);
                        table.addCell(cell);
                    }
                    captionStr = "Table " + tableNum + ". " + captionStr;
                    //spacer row
                    PdfPCell cell = this.getDataCell(new Phrase("",captionFont));
                    cell.setColspan(3);
                    cell.setBorder(Rectangle.NO_BORDER);
                    cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    table.addCell(cell);
                    //caption row
                    cell = this.getDataCell(new Phrase(captionStr,captionFont));
                    cell.setColspan(3);
                    cell.setBorder(Rectangle.NO_BORDER);
                    cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    table.addCell(cell);
                    this.docMap.put(pageDesc,table);
                } catch (Exception e){
                    e.printStackTrace();
                }
            }               
        }

        return;
    }

    public void createFigureTables() throws IOException, DocumentException {
        /*
        Create a one-column table to format each page that will contain an image
        and store them in the document map to be added to the document later
        */

        int indentation = 0;
        int figureNum = 1;
        DecimalFormat df = new DecimalFormat("##");

        File f = new File(this.metricsDir + "/images");
        File[] imageFiles = f.listFiles();
        Arrays.sort(imageFiles);
        for (final File fileEntry : imageFiles) {
            String fname = fileEntry.getName();

            PdfReader reader = new PdfReader(f+"/"+fname);
            try{
                PdfImportedPage page = writer.getImportedPage(reader,1);
                Image plot = Image.getInstance(page);
                float scaler = ((this.reportPDF.getPageSize().getWidth() - this.reportPDF.leftMargin()
                                      - this.reportPDF.rightMargin() - indentation) / plot.getWidth()) * 95;
                plot.scalePercent(scaler);

                //plot.setAbsolutePosition((this.reportPDF.getPageSize().getWidth() - plot.getScaledWidth()) / 2,
                 //                           (this.reportPDF.getPageSize().getHeight() - plot.getScaledHeight()));//  / 2);

                String captionStr = "";
                String pageDesc = "";

                if(fname.endsWith("_cdna_contamination.pdf")){
                    System.out.println("\tAdding cDNA contamination plot");
                    captionStr = "cDNA Contamination: a red circle indicates that structural variation analysis revealed evidence of cDNA contamination within that gene in that sample";
                    pageDesc = "cDNA Contamination Plot"; 
                }
                if(fname.endsWith("_trimmed_reads.pdf")){ 
                    System.out.println("\tAdding trimmed reads plot");
                    captionStr = "Percent trimmed reads";
                    pageDesc = "Trimmed Reads Plot";
                } else if (fname.endsWith("_alignment.pdf") || fname.endsWith("_alignment_percentage.pdf")){
                    captionStr = "Cluster Density: There were a total of " + df.format(this.qcSummary.getTotalNumClusters()) + " million clusters on the lane. " + Float.toString(this.qcSummary.getTotalPercentageBothReadsAligned()*100) + "% of these had both reads align to the reference genome.";
                    if(fname.endsWith("_alignment.pdf")){
                        System.out.println("\tAdding alignment (absolute values) plot");
                        pageDesc = "Alignment (absolute) Plot";
                    } else {
                        System.out.println("\tAdding alignment (percentage values) plot");
                        pageDesc = "Alignment (percentage) Plot";
                    }
                } else if (fname.endsWith("_base_qualities.pdf")){
                    System.out.println("\tAdding base qualities plot");
                    captionStr = "Base Qualities";
                    pageDesc = "Base Qualities Plot";
                } else if (fname.endsWith("_insert_size.pdf")){
                    System.out.println("\tAdding insert size distribution plot");
                    captionStr = "Insert Size Distribution";
                    pageDesc = "Insert Size Distribution Plot";
                } else if (fname.endsWith("_insert_size_peaks.pdf")){
                    System.out.println("\tAdding peak insert size plot");
                    captionStr = "Peak Insert Size Values: Mean peak insert size is " + df.format(this.qcSummary.getAverageInsertPeak());
                    pageDesc = "Insert Size Peaks Plot";
                } else if (fname.endsWith("_fingerprint.pdf")){
                    System.out.println("\tAdding sample mixups heatmap");
                    captionStr = "Sample Mixups: The value below the key refers to the fraction of discordant homozygous alleles. A low score between unrelated samples is a red flag.";
                    pageDesc = "Sample Mislabeling Plot";
                } else if (fname.endsWith("_major_contamination.pdf")){
                    System.out.println("\tAdding major contamination plot");
                    captionStr = "Major Contamination Check: The mean fraction of positions that are heterozygous is " + Float.toString(this.qcSummary.getAverageMajorContamination());
                    pageDesc = "Major Contamination Plot";
                } else if (fname.endsWith("_minor_contamination.pdf")){
                    System.out.println("\tAdding minor contamination plot");
                    captionStr = "Minor Contamination Check: Average minor allele frequency is " + Float.toString(this.qcSummary.getAverageMinorContamination());
                    pageDesc = "Minor Contamination Plot";
                } else if (fname.endsWith("_gc_bias.pdf")){
                    System.out.println("\tAdding GC Bias plot");
                    captionStr = "GC Content";
                    pageDesc = "GC Content Plot";
                } else if (fname.endsWith("_capture_specificity.pdf") || fname.endsWith("_capture_specificity_percentage.pdf")){
                    captionStr = "Capture Specificity: Average % selected on/near bait = " + Float.toString(this.qcSummary.getAverageOnNearBaitPercentage()) + "%. Average % on bait = " + Float.toString(this.qcSummary.getAverageOnBaitPercentage())  + "%. Average % of usable bases on target = " + Float.toString(this.qcSummary.getAverageOnTargetPercentage()) + "%";
                    if (fname.endsWith("_capture_specificity.pdf")){
                        System.out.println("\tAdding capture specificity (absolute values) plot");
                        pageDesc = "Capture Specificity (absolute) Plot";
                    } else {
                        System.out.println("\tAdding capture specificity (percentage values) plot");
                        pageDesc = "Capture Specificity (percentage) Plot";
                    }
                } else if (fname.endsWith("_duplication.pdf")){
                    System.out.println("\tAdding duplicat plot");
                    captionStr = "Duplication Rate: Average duplication rate is " + Float.toString(this.qcSummary.getAverageDuplication()) + "%";
                    pageDesc = "Duplication Plot";
                } else if (fname.endsWith("_library_size.pdf")){
                    System.out.println("\tAdding library size plot");
                    captionStr = "Estimated Library Size: Average library size is " + df.format(this.qcSummary.getAverageLibrarySize()) + " million"; // and total library size is XXX million";
                    pageDesc = "Library Size Plot";
                } else if (fname.endsWith("_coverage.pdf")){
                    System.out.println("\tAdding coverage plot");
                    captionStr = "Median Target Coverage: Median canonical exon coverage across all samples is " + df.format(this.qcSummary.getAverageCoverage()) +"x";  //Median coverage across normal samples is XXx and tumor samples is XXx.";
                    pageDesc = "Coverage Plot";
                }
                captionStr = "Figure " + Integer.toString(figureNum) + ". " + captionStr;

                // use a table without borders to lay out the page
                // the first row contains the image, followed by a spacer
                // row, then caption row
                PdfPTable table = new PdfPTable(1);
                table.setTotalWidth(this.reportPDF.getPageSize().getWidth() - this.reportPDF.leftMargin() - this.reportPDF.rightMargin());
                table.setLockedWidth(true);

                //anchor row
                Chunk a = new Chunk(" ");
                a.setLocalDestination(this.ELEMENT_NAMES.get(this.REPORT_ELEMENTS.indexOf(pageDesc)));
                Paragraph p = new Paragraph(a);
                PdfPCell cell = new PdfPCell(p);
                cell.setBorder(Rectangle.NO_BORDER);
                table.addCell(cell);
                // figure row
                cell = new PdfPCell(plot);
                cell.setBorder(Rectangle.NO_BORDER);
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                table.addCell(cell);
                // spacer row
                cell = new PdfPCell(new Phrase("\n\n",captionFont));
                cell.setBorder(Rectangle.NO_BORDER);
                table.addCell(cell);
                // caption row
                cell = new PdfPCell(new Phrase(captionStr, captionFont));
                cell.setBorder(Rectangle.NO_BORDER);
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                table.addCell(cell);

                figureNum++;
                this.docMap.put(pageDesc,table);
            } catch (IllegalArgumentException iae){
                // if the file is corrupt, which may happen if there was an R error,
                // the argument 1 (get page 1) causes this error to be thrown
                System.err.println("ERROR reading file: "+f+"/"+fname);
                continue;
            }
        }
        return;
    }

    public Paragraph getCaptionParagraph(){
        Paragraph caption = new Paragraph();
        caption.setAlignment(Element.ALIGN_CENTER);
        return caption;
    }

    public PdfPCell getDataCell(Phrase p){
        PdfPCell cell = new PdfPCell(p);
        cell.setPadding(3);
        return cell;
    }

    public BaseColor getBackgroundColor(String status){
        if(status.equals("PASS")){
            return this.STATUS_COLUMN_PASS_COLOR;
        } else if(status.equals("WARN")){
            return this.STATUS_COLUMN_WARN_COLOR;
        } else if(status.equals("FAIL")){
            return this.STATUS_COLUMN_FAIL_COLOR;
        }
        return null;
    }
  
    public PdfPCell getStatusCell(String status){
        PdfPCell cell = getDataCell(new Phrase(status,tableHeaderFont)); //auto status
        cell.setBackgroundColor(getBackgroundColor(status));
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        return cell;
    }

    public PdfPCell getHeaderCell(Phrase p){
        PdfPCell cell = new PdfPCell(p);
        cell.setPadding(3);
        cell.setBackgroundColor(TABLE_HEADER_COLOR);
        return cell;
    }

    public PdfPTable addTableTitle(PdfPTable table, String title, String pageDesc){
        /*
        Add title to existing table, including anchor
        */
        PdfPCell cell = new PdfPCell(new Phrase(title, header3));
        cell.setColspan(table.getNumberOfColumns());
        cell.setBorder(Rectangle.NO_BORDER);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        table.addCell(cell);

        // spacer row with anchor
        Paragraph p = new Paragraph();
        if(pageDesc.equals("Report Contents")){ 
            p.add(new Chunk(" ",header3));
        } else {
            Chunk a = new Chunk(" ",header3);        
            a.setLocalDestination(this.ELEMENT_NAMES.get(this.REPORT_ELEMENTS.indexOf(pageDesc)));
            p.add(a);
        }
        cell = new PdfPCell(p);
        cell.setColspan(table.getNumberOfColumns());
        cell.setBorder(Rectangle.NO_BORDER);
        table.addCell(cell);

        return table;
    }

    public void createProjectSummaryTable() throws IOException, DocumentException {
        DecimalFormat df = new DecimalFormat("##");

        PdfPTable table = new PdfPTable(6);
        // set absolute width in order to be able to calculate the total height before
        // the table is actually added to the document; this is so we can generate
        // the TOC before adding anything to the doc
        table.setTotalWidth(this.reportPDF.getPageSize().getWidth() - this.reportPDF.leftMargin() - this.reportPDF.rightMargin());
        table.setLockedWidth(true);
        table.setWidths(new int[]{1,2,2,3,1,3});

        PdfPCell cell;
        PdfPCell placeHolderCell = new PdfPCell(new Phrase(""));

        Integer cellInt;
        Float cellFloat;

        // Table title
        table = this.addTableTitle(table,"Project Summary","Project QC Summary Table");

        // header row
        cell = getHeaderCell(new Phrase("Auto-status",tableHeaderFont));
        table.addCell(cell);
        cell = getHeaderCell(new Phrase("Metric",tableHeaderFont));
        table.addCell(cell);
        cell = getHeaderCell(new Phrase("",tableHeaderFont));
        table.addCell(cell); 
        cell = getHeaderCell(new Phrase("Description",tableHeaderFont));
        table.addCell(cell);
        cell = getHeaderCell(new Phrase("Value",tableHeaderFont));
        table.addCell(cell);
        cell = getHeaderCell(new Phrase("Failures",tableHeaderFont));
        table.addCell(cell);

        //cluster density        
        cell = getStatusCell(this.qcSummary.getClusterDensityStatus()); //auto status
        cell.setRowspan(2);
        table.addCell(cell);
        cell = getDataCell(new Phrase("Cluster Density",tableHeaderFont));
        cell.setRowspan(2);
        table.addCell(cell);
        cell = getDataCell(new Phrase("Absolute",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase("Total number of clusters (millions)",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase(df.format(this.qcSummary.getTotalNumClusters()),dataFont));
        table.addCell(cell); //summary value
        table.addCell(placeHolderCell); //failures

        cell = getDataCell(new Phrase("Percentage",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase("% of clusters with both reads aligned to genome",dataFont));
        table.addCell(cell);
        if(this.qcSummary.getTotalPercentageBothReadsAligned() == null){
            cell = getDataCell(new Phrase("Not available",dataFont));
        } else {
            cell = getDataCell(new Phrase(Float.toString(this.qcSummary.getTotalPercentageBothReadsAligned()*100),dataFont));
        }
        table.addCell(cell); //summary value
        table.addCell(placeHolderCell); //failures
        
        //capture specificity
        //row 1 of cap spec
        cell = getStatusCell(this.qcSummary.getCaptureSpecificityStatus()); //auto status
        //cell.setRowspan(4);
        cell.setRowspan(3);
        table.addCell(cell);
        cell = getDataCell(new Phrase("Capture Specificity",tableHeaderFont));
        //cell.setRowspan(4);
        cell.setRowspan(3);
        table.addCell(cell);
        //cell = getDataCell(new Phrase("Absolute",dataFont));
        //table.addCell(cell);
        //table.addCell(placeHolderCell); //blank 
        //table.addCell(placeHolderCell); //summary value
        //table.addCell(placeHolderCell); //failures cell
        //row 2 of cap spec
        //cell = getDataCell(new Phrase("Percentage",dataFont));
        //table.addCell(placeHolderCell); // blank category
        cell = getDataCell(new Phrase(" ",dataFont));
        cell.setRowspan(3);
        table.addCell(cell);
        cell = getDataCell(new Phrase("Average % on/near bait",dataFont));
        table.addCell(cell);
        if(this.qcSummary.getAverageOnNearBaitPercentage() == null){
            cell = getDataCell(new Phrase("Not available",dataFont));
        } else{
            cell = getDataCell(new Phrase(Float.toString(this.qcSummary.getAverageOnNearBaitPercentage()),dataFont));
        }
        table.addCell(cell); //summary value
        table.addCell(placeHolderCell); //failures cell
        //row 3 of cap spec
        cell = getDataCell(new Phrase("Average % on bait",dataFont));
        table.addCell(cell);
        if(this.qcSummary.getAverageOnBaitPercentage() == null){
            cell = getDataCell(new Phrase("Not available",dataFont));
        } else{
            cell = getDataCell(new Phrase(Float.toString(this.qcSummary.getAverageOnBaitPercentage()),dataFont));
        }
        table.addCell(cell); //summary value
        table.addCell(placeHolderCell); //failures cell
        //row4 of cap spec
        cell = getDataCell(new Phrase("Average % on target",dataFont));
        table.addCell(cell);
        if(this.qcSummary.getAverageOnTargetPercentage() == null){
            cell = getDataCell(new Phrase("Not available",dataFont));
        } else {
            cell = getDataCell(new Phrase(Float.toString(this.qcSummary.getAverageOnTargetPercentage()),dataFont));
        }
        table.addCell(cell); //summary value
        table.addCell(placeHolderCell); //failures cell

        //row1 insert size
        cell = getStatusCell(this.qcSummary.getInsertSizeStatus()); //auto status 
        //cell.setRowspan(2);
        table.addCell(cell);
        cell = getDataCell(new Phrase("Insert Size",tableHeaderFont));
        //cell.setRowspan(2);
        table.addCell(cell);
        //cell = getDataCell(new Phrase("Distribution",dataFont));
        //table.addCell(cell);
        //cell = getDataCell(new Phrase("Samples \u00B1"+"3"+"\u03C3"+" from average ",dataFont));
        //table.addCell(cell);
        //table.addCell(placeHolderCell); //summary value
        //table.addCell(placeHolderCell); //failures cell
        //row2 insert size
        //cell = getDataCell(new Phrase("Peak Values",dataFont));
        //table.addCell(cell);
        table.addCell(placeHolderCell); // blank category
        cell = getDataCell(new Phrase("Mean peak ",dataFont));
        table.addCell(cell);
        if(this.qcSummary.getAverageInsertPeak() == null){
            cell = getDataCell(new Phrase("Not available",dataFont));
        } else {
            cell = getDataCell(new Phrase(df.format(this.qcSummary.getAverageInsertPeak()),dataFont));
        }
        table.addCell(cell); //summary value
        cell = getDataCell(new Phrase(this.qcSummary.getInsertSizeFailures(),dataFont));
        table.addCell(cell); //failures cell

        //row1 sample mixups
        cell = getStatusCell(this.qcSummary.getSampleLabelStatus()); //auto status
        cell.setRowspan(2);
        table.addCell(cell);
        cell = getDataCell(new Phrase("Sample Labeling Errors",tableHeaderFont));
        cell.setRowspan(2);
        table.addCell(cell);
        cell = getDataCell(new Phrase("Unexpected Matches",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase("Number of samples ",dataFont));
        table.addCell(cell);
        String um = "NA";
        if(this.qcSummary.getNumSamplesWithUnexpectedMatch() != null){
            um = Integer.toString(this.qcSummary.getNumSamplesWithUnexpectedMatch());
        }
        cell = getDataCell(new Phrase(um,dataFont));
        table.addCell(cell); //summary value
        cell = getDataCell(new Phrase(this.qcSummary.getUnexpectedMatches(),dataFont));
        table.addCell(cell); //failures cell
        //row2 sample mixups
        cell = getDataCell(new Phrase("Unexpected Mismatches",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase("Number of samples ",dataFont));
        table.addCell(cell);
        if(this.qcSummary.getNumSamplesWithUnexpectedMismatch() != null){
            um = Integer.toString(this.qcSummary.getNumSamplesWithUnexpectedMismatch());
        }
        cell = getDataCell(new Phrase(um,dataFont));
        table.addCell(cell); //summary value
        cell = getDataCell(new Phrase(this.qcSummary.getUnexpectedMismatches(),dataFont));
        table.addCell(cell); //failures cell

        //row1 contamination
        cell = getStatusCell(this.qcSummary.getContaminationStatus()); //auto status        
        cell.setRowspan(3);
        table.addCell(cell);
        cell = getDataCell(new Phrase("Contamination",tableHeaderFont));
        cell.setRowspan(3);
        table.addCell(cell);
        cell = getDataCell(new Phrase("Major",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase("Mean fraction of positions that are heterozygous ",dataFont));
        table.addCell(cell);
        String mjc = "NA";
        if(this.qcSummary.getAverageMajorContamination() != null){
            mjc = Float.toString(this.qcSummary.getAverageMajorContamination());
        }
        cell = getDataCell(new Phrase(mjc,dataFont));
        table.addCell(cell); //summary value
        cell = getDataCell(new Phrase(this.qcSummary.getMajorContaminationFailures(),dataFont));
        table.addCell(cell); //failures cell
        //row2 contamination
        cell = getDataCell(new Phrase("Minor",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase("Average minor allele frequency ",dataFont));
        table.addCell(cell);
        String mnc = "NA";
        if(this.qcSummary.getAverageMinorContamination() != null){ 
            mnc = Float.toString(this.qcSummary.getAverageMinorContamination());
        }
        cell = getDataCell(new Phrase(mnc,dataFont));
        table.addCell(cell); //summary value
        cell = getDataCell(new Phrase(this.qcSummary.getMinorContaminationFailures(),dataFont));
        table.addCell(cell); //failures cell
        //row3 contamination
        cell = getDataCell(new Phrase("cDNA",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase("Number of genes ",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase(Integer.toString(this.qcSummary.getNumGenesWithCdnaContamination()),dataFont));
        table.addCell(cell); //summary value
        cell = getDataCell(new Phrase(this.qcSummary.getCdnaContaminationFailures(),dataFont));
        table.addCell(cell); //failures cell

        //row1 duplication
        cell = getStatusCell(this.qcSummary.getDuplicationStatus()); //auto status
        table.addCell(cell);
        cell = getDataCell(new Phrase("Duplication",tableHeaderFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase(" ",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase("Average percentage",dataFont));
        table.addCell(cell);
        if(this.qcSummary.getAverageDuplication() == null){
            cell = getDataCell(new Phrase("Not available",dataFont));
        } else {
            cell = getDataCell(new Phrase(Float.toString(this.qcSummary.getAverageDuplication()),dataFont));
        }
        table.addCell(cell); //summary value
        cell = getDataCell(new Phrase(this.qcSummary.getDuplicationFailures(),dataFont));
        table.addCell(cell); //failures cell

        //row1 library size
        cell = getStatusCell(this.qcSummary.getLibrarySizeStatus()); //auto status
        table.addCell(cell);
        cell = getDataCell(new Phrase("Library Size",tableHeaderFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase(" ",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase("Average (millions) ",dataFont));
        table.addCell(cell);
        if(this.qcSummary.getAverageLibrarySize() == null){
            cell = getDataCell(new Phrase("Not available",dataFont));
        } else {
            cell = getDataCell(new Phrase(df.format(this.qcSummary.getAverageLibrarySize()),dataFont));
        }
        table.addCell(cell); //summary value
        cell = getDataCell(new Phrase(this.qcSummary.getLibrarySizeFailures(),dataFont));
        table.addCell(cell); //failures cell

        //row1 coverage
        cell = getStatusCell(this.qcSummary.getCoverageStatus()); //auto status
        cell.setRowspan(3);
        table.addCell(cell);
        cell = getDataCell(new Phrase("Target Coverage",tableHeaderFont));
        cell.setRowspan(3);
        table.addCell(cell);
        cell = getDataCell(new Phrase("All samples",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase("Mean (millions)",dataFont));
        table.addCell(cell);
        if(this.qcSummary.getAverageCoverage() == null){
            cell = getDataCell(new Phrase("Not available",dataFont));
        } else {
            cell = getDataCell(new Phrase(df.format(this.qcSummary.getAverageCoverage()),dataFont));
        }
        table.addCell(cell); //summary value
        cell = getDataCell(new Phrase(this.qcSummary.getCoverageFailures(),dataFont));
        table.addCell(cell); //failures cell
        //row2 coverage
        cell = getDataCell(new Phrase("Normals",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase("Mean (millions)",dataFont));
        table.addCell(cell);
        table.addCell(placeHolderCell); //summary value
        table.addCell(placeHolderCell); //failures cell
        //row3 coverage
        cell = getDataCell(new Phrase("Tumors",dataFont));
        table.addCell(cell);
        cell = getDataCell(new Phrase("Mean (millions)",dataFont));
        table.addCell(cell);
        table.addCell(placeHolderCell); //summary value
        table.addCell(placeHolderCell); //failures cell

        //this.reportPDF.add(table);
        this.docMap.put("Project QC Summary Table",table);
        return;
   }
 
    public void createSampleSummaryTable() throws IOException, DocumentException {
        float[] colWidths = new float[this.qcSummary.getNumMetrics()+1];
        colWidths[0] = 2; //sample id col
        colWidths[1] = 1; //auto status col
        colWidths[2] = 2; //un match col
        colWidths[3] = 2; //un mismatch col
        for(int i=4; i<=this.qcSummary.getNumMetrics(); i++){
            colWidths[i] = 1;
        }
        Map<String, Map<String, Map<String, Object>>> summaryMap = this.qcSummary.getSummaryMap();

        List<String> metricsHeaders = this.qcSummary.getAllMetricsHeaders();


        PdfPTable table = new PdfPTable(colWidths);
        table.setTotalWidth(this.reportPDF.getPageSize().getWidth() - this.reportPDF.leftMargin() - this.reportPDF.rightMargin());
        table.setLockedWidth(true);
        table.setSplitLate(false);  // this will split a row between two pages if necessary, as opposed to
                                    // pushing a row that doesn't completely fit on the page entirely to the next page
                                    // this is to make sure page numbers in the TOC are correct
        table.setHeaderRows(2);             // make sure column headers and project averages
                                            // appear on every page should the table extend more than one page
        table = this.addTableTitle(table,"Sample Summary","Sample QC Summary Table");


        PdfPCell cell;

        //header row
        cell = new PdfPCell(new Phrase("Sample",tableHeaderFont));
        cell.setBackgroundColor(TABLE_HEADER_COLOR);
        cell.setVerticalAlignment(Element.ALIGN_BOTTOM);
        cell.setPadding(3);
        table.addCell(cell);
        for (String metric : metricsHeaders){
            cell = new PdfPCell(new Phrase(metric.replace(" ","\n").replace("ination","."),tableHeaderFont));
            cell.setBackgroundColor(TABLE_HEADER_COLOR);
            cell.setVerticalAlignment(Element.ALIGN_BOTTOM);
            cell.setPadding(3);
            cell.setNoWrap(true);
            table.addCell(cell);
        }        

        //summary row
        Map<String, Map<String, Object>> averages = summaryMap.get(this.qcSummary.getProjectAverageIndicator());
        cell = new PdfPCell(new Phrase("Project Average",tableHeaderFont));
        cell.setBackgroundColor(TABLE_SUMMARY_COLOR);
        cell.setPadding(3);
        table.addCell(cell);
        for (String metric : metricsHeaders){
            String cellVal = "NA";
            if (averages.containsKey(metric)){
                Object value = averages.get(metric).get("value");
                if (value != null){
                    cellVal = value.toString().replace(" ","\n");
                } 
            } 
            cell = new PdfPCell(new Phrase(cellVal,dataFont));
            cell.setBackgroundColor(TABLE_SUMMARY_COLOR);
            cell.setPadding(3);
            if(metric.startsWith("Un") || metric.startsWith("Auto")){
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
            } else {
                cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
            }
            table.addCell(cell);
        }

        //sample rows
        List<String> sortedSampleIDs=new ArrayList<String>(summaryMap.keySet());
        Collections.sort(sortedSampleIDs);

        for(String sampleID : sortedSampleIDs){
            Map<String, Map<String, Object>> metricMap = summaryMap.get(sampleID);
            if (sampleID.equals(this.qcSummary.getProjectAverageIndicator())){
                continue;
            }
            cell = new PdfPCell(new Phrase(sampleID,dataFont));
            cell.setPadding(3);
            table.addCell(cell);
            for (String metric : metricsHeaders){
                Object value = metricMap.get(metric).get("value");
                Object status = metricMap.get(metric).get("status");
                cell = new PdfPCell(new Phrase(value.toString(),dataFont));
                //determine horizontal alignment
                try {
                    Float x = new Float(value.toString());
                    cell.setHorizontalAlignment(Element.ALIGN_RIGHT);        //align cells with numbers to right
                } catch (NumberFormatException nfe) {
                    cell.setHorizontalAlignment(Element.ALIGN_CENTER);       //align cells with strings to center
                }
                //color status column
                if(metric.startsWith("Auto")){
                    if(value.toString().equals("PASS")){
                        cell.setBackgroundColor(STATUS_COLUMN_PASS_COLOR);   //green
                    } else if(value.toString().equals("WARN")){
                        cell.setBackgroundColor(STATUS_COLUMN_WARN_COLOR); //yellow
                    } else if(value.toString().equals("FAIL")){ 
                        cell.setBackgroundColor(STATUS_COLUMN_FAIL_COLOR);     //red
                    }
                } else { // color individual failed data cells
                    if(status.toString().equals("WARN")){
                        cell.setBackgroundColor(DATA_CELL_WARN_COLOR); //light yellow
                    } else if(status.toString().equals("FAIL")){
                        cell.setBackgroundColor(DATA_CELL_FAIL_COLOR); //light red
                    }
                }
                cell.setPadding(3);
                table.addCell(cell);
            }
        } 
        this.docMap.put("Sample QC Summary Table",table);
        return;
    }

    public void writeCoverPage(){
        Date date = new Date();
        String reportDate = new SimpleDateFormat("yyyy-MM-dd").format(date);

        Font header = new Font(Font.FontFamily.HELVETICA, 24);
        Font header2 = new Font(Font.FontFamily.HELVETICA, 18);
        Font header3 = new Font(Font.FontFamily.HELVETICA, 12);
        
        Paragraph projID = new Paragraph();
        projID.setSpacingBefore(150);
        projID.setSpacingAfter(15);
        projID.setAlignment(Element.ALIGN_CENTER);
           
        projID.add(new Chunk("Project " + this.id, header));
            
        Paragraph title = new Paragraph();
        title.setSpacingAfter(25);
        title.setAlignment(Element.ALIGN_CENTER);
        title.add(new Chunk("QC Metrics Report\n", header2));

        Paragraph runDate = new Paragraph();
        runDate.setSpacingAfter(25);
        runDate.setAlignment(Element.ALIGN_CENTER);
        runDate.add(new Chunk(reportDate+"\n",header3));

        Paragraph deptInfo = new Paragraph();
        deptInfo.setSpacingAfter(25);
        deptInfo.setAlignment(Element.ALIGN_CENTER);
        deptInfo.add(new Chunk("Memorial Sloan Kettering Cancer Center\n", header2));
        deptInfo.add(new Chunk("Center for Molecular Oncology", header2));
            
        Paragraph pipelineRunInfo = new Paragraph();
        pipelineRunInfo.setSpacingAfter(25);
        pipelineRunInfo.setAlignment(Element.ALIGN_CENTER);

        pipelineRunInfo.add(new Chunk("\n\n\n\n\n",header3));
        pipelineRunInfo.add(new Chunk("Assay: " + this.assay + "\n", header3));
        pipelineRunInfo.add(new Chunk(this.pipeline + " Pipeline version: " + this.pipelineVersion + "\n", header3));
        pipelineRunInfo.add(new Chunk("Pipeline run number: " + this.runNum + "\n", header3));
    
        pipelineRunInfo.add(new Chunk("PI: " + this.pi + "\n", header3));
        pipelineRunInfo.add(new Chunk("PI email: " + this.piID + "\n", header3));
        pipelineRunInfo.add(new Chunk("Investigator: " + this.inv + "\n", header3));
        pipelineRunInfo.add(new Chunk("Investigator email: " + this.invID + "\n", header3));
 
        try{
            this.reportPDF.add(deptInfo);
            this.reportPDF.add(projID);
            this.reportPDF.add(title);
            this.reportPDF.add(runDate);
            this.reportPDF.add(pipelineRunInfo);
        } catch(Exception e){
            e.printStackTrace();
        }
    }
    
    	
    public void setReportPDFname(String reportPDFname){
    	this.reportPDFname = reportPDFname;
    }
    public String getReportPDFname(){
    	return reportPDFname;
    }   
}

