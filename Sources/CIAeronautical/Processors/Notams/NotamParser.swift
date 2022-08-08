// ********************** NotamParser *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/17/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** NotamParser *********************************


import Foundation

public typealias NotamList = [String: [String]]

/// Classy way to parse the NOTAMs after they've been fetched.
public class NotamParser {
    
    private var htmlData: String
    private var rawNotamData: [String] = []
    private var rawNotamStation: [String] = []
    public var notams: NotamList = [:]
    
    public init(htmlData: String) {
        self.htmlData = htmlData
        parseNotams()
    }
    
    private var numberOfNotams: Int {
        let notamNumberString = "Number of NOTAMs:"
        guard let startIndex = self.htmlData.range(of: notamNumberString) else {
            print("Unable to find count of NOTAMs retrieved; Bad start index")
            return 0
        }
        let endOfReportString = "End of Report"
        guard let endIndex = self.htmlData.range(of: endOfReportString) else {
            print("Unable to find count of NOTAMs retrieved; Bad end index")
            return 0
        }
        
        var parsable = String(self.htmlData[startIndex.upperBound..<endIndex.lowerBound])
        parsable = parsable.replacingOccurrences(of: "&nbsp;", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let number = Int(parsable) else {
            print ("Unable to parse the number from the text")
            return 0
        }
        return number
    }
    
    private func parseNotams() {
        let totalNotams = numberOfNotams
        
        if numberOfNotams == 0 {
            notams = [:]
            return
        }
        
        //This will wipe the data and allow us to insert into any position without an array error
        rawNotamData = (0..<totalNotams).map { _ in return ""}
        rawNotamStation = (0..<totalNotams).map { _ in return ""}
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DispatchQueue.global(qos: .default).async {
            self.fillInRawStations()
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        DispatchQueue.global(qos: .default).async {
            self.fillInRawNotams()
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        
        var prevStation = ""
        var notamArray: [String] = []
        notams = [:]
        for i in 0..<rawNotamStation.count {
            if prevStation == "" { prevStation = rawNotamStation[i] }
            if rawNotamStation[i] != prevStation {
                var copyOfNotams: [String] = []
                copyOfNotams.append(contentsOf: notamArray)
                notams[prevStation] = copyOfNotams
                notamArray = []
                prevStation = rawNotamStation[i]
            }
            
            notamArray.append(rawNotamData[i])
        }
        notams[prevStation] = notamArray
    }
    
    private func fillInRawNotams() {
        let dataIndexes = htmlData.ranges(of: "<PRE>")
        print("Notams found: \(dataIndexes.count)")
        var count = 0
        for index in dataIndexes {
            let substring = htmlData[index.upperBound...]
            let endString = "</PRE>"
            guard let endIndex = substring.range(of: endString) else {
                print("Unable to find closing tag")
                count += 1
                continue
            }
            let notam = String(substring[index.upperBound..<endIndex.lowerBound])
            rawNotamData[count] = notam
            count += 1
        }
    }
    
    private func fillInRawStations() {
        let stationIndexes = htmlData.ranges(of: "notamSelect")
        var count = 0
        for index in stationIndexes {
            let substring = htmlData[index.upperBound...]
            let idString = "id=\""
            guard let startIndex = substring.range(of: idString) else {
                print("Start pattern did not match")
                count += 1
                continue
            }
            let endString = "\">"
            guard let endIndex = substring.range(of: endString) else {
                print("End pattern did not match")
                count += 1
                continue
            }
            let station = String(substring[startIndex.upperBound..<endIndex.lowerBound])
            rawNotamStation[count] = station
            count += 1
        }
    }
}

// HTML that crashed it? (8/1/2022 18:36 GMT)
/*
 
 <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">



 <html>
 <HEAD>


 <META http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
 <META name="GENERATOR" content="IBM Software Development Platform">
 <META http-equiv="Content-Style-Type" content="text/css">
 <LINK href="theme/naimes.css" rel="stylesheet" type="text/css">
 <SCRIPT language="JavaScript" src="javascript/common.js"></SCRIPT>
 <SCRIPT language="JavaScript" src="javascript/save.js"></SCRIPT>

 <TITLE>Defense Internet NOTAM Service</TITLE>
 <script>
 window.focus();
 </script>
 <script >bazadebezolkohpepadr="1956961778"</script><script type="text/javascript" src="https://www.notams.faa.gov/akam/13/74a4df61"  defer></script></HEAD>


 <BODY>

 <A name="top"></A>
 <!-- begin of banner -->
 <TABLE width="100%" cellpadding="0" cellspacing="0" class="noprint" >
     <TBODY>
         <TR>
             <TD align="left" background="images/n_gradiant_back.gif"><IMG    src="images/n_seal_af.gif" width="99" height="104" border="0"></TD>
             <TD align="left" background="images/n_gradiant_back.gif"><IMG    src="images/n_seal_army.gif" width="99" height="104" border="0"></TD>
             <TD align="center" background="images/n_gradiant_back.gif"><IMG    src="images/n_logo_dins.gif" width="367" height="104" border="0"></TD>
             <TD align="center" background="images/n_gradiant_back.gif"><IMG    src="images/n_seal_navy.gif" width="99" height="104" border="0"></TD>
             <TD align="right" background="images/n_gradiant_back.gif"><IMG src="images/n_seal_marines.gif" width="99" height="104" border="0"></TD>
         </TR>
     </TBODY>
 </TABLE>

 <TABLE border="0" cellpadding="0" cellspacing="0" bgcolor="white"
     width="100%" class="noprint">


     <TBODY>
         <TR bgcolor="black">
         
             <TD width="33%" align="left" nowrap >
             <FONT color="white" size="1">
             <IMG    border="0" src="images/spacer.gif" width="10" height="11">
             <span    id="DINSClock"></span></FONT></TD>

 <td><IMG    border="0" src="images/spacer.gif" width="10" > </td>
             <TD width="33%"  class="dodWarningRed11" align="center"  bgcolor="black" nowrap>
                         ~ For DoD Flight Only ~
             </TD>

             <TD width="33%"  align="right"  id="MenuTop" nowrap >
             <FONT     color="#000000">xxxxxxxxx</FONT>
             <A    href="#" class="MenuTop" title="Close" onclick="window.close()">
             <FONT    color="#FFFFFF">Close</FONT></A>
          <FONT     color="#000000">xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</FONT>
         
         
                 </TD>

     </TBODY>
 </TABLE>

 <!-- end of menu line one -->
 <!-- end of banner -->
 <!-- end of menu line one -->

 <!-- END LINKS -->

 <style media="print">
 #noprint {
     display: none;
 }
 input, button {
     display: none;
 }
 .noprint {
     display: none;
 }
 .toggle {
     display: block;
 }
 text {
 display: block;
 }
 </style>

 <style media="screen">
 #noshow {
     display: none;
 }
 .noshow {
     display: none;
 }
 </style>

 <form name="NotamRetrievalForm" method="post" action="/dinsQueryWeb/printRetrievalMapAction.do" id="form1">

 <input type=hidden name="locidStr"  value="KBAB KMHR KSUU KSMF KPMD KRNO KNFL KCIC KFAT KSCK KEDW KOAK KLAS KPDX"  />
 <input type=hidden name="save"  value="" />






 <script>
 function submitForm(action) {
     var oldAction = "printRetrievalMapAction.do";
     if (action == "saveAsPDF") {
         document.NotamRetrievalForm.action = 'saveNotamAsPDF?sel=false&geo=false';
         }
     else {
         document.NotamRetrievalForm.action = oldAction;
     }
 }
 </script>

 <DIV align="left">
             <TABLE width="100%" cellpadding="5">
                 <TR>
                     <TD>
                     <TABLE>

                         <TR>
                             <TD><input type="submit" name="submit" value="Display/Print Selected NOTAMs" onclick="this.form.save.value =' '; submitForm();" style="width: 162px; font-size: 10px;"></TD>

                         </TR>

                         <TR>
                             <TD>
                                 <input type="button" name="button" value="Print all NOTAMs" onclick="loadAPDImagesForPrint('print');" style="width: 115px; font-size: 09px;">
                                 &nbsp;&nbsp;
                                 <!-- <input type="submit" name="button" value="Save all NOTAMs " onclick="this.form.save.value ='saveall';submitForm();" style="width: 115px; font-size: 09px;"> -->
                                 <input type="submit" name="button" value="Save all NOTAMs " onclick="submitForm('saveAsPDF');" style="width: 115px; font-size: 09px;">
                             </TD>


                             <td class="textBlack14" width="25%" align="right" >Sort By: <select name="sortOrder"><!--  onchange="sortNotamListing(this.value); "-->
                                 
                                 <option value="1" selected="selected">Default Report</option>
                                 <option value="2">Effective Date</option>
                                 <option value="3">Expiration Date</option>
                                 <option value="4">Created Date</option></select>
                             
                             </td>
                         </TR>
                     <tr>
                     <td class="toggle"> </td>
                     </tr>
                         <TR >
                         <TD ><input style="width: 115px; font-size: 09px;" type="button" onClick="checkedAll('form1', true)" value="Check All NOTAMs">
                             &nbsp;&nbsp;
                             <input style="width: 115px; font-size: 09px;" type="button" onClick="checkedAll('form1', false)" value="UnCheck All NOTAMs">
                         </TD>
                         <td nowrap="nowrap" class="textBlack14" width="25%" align="right" >
                             Keyword Sort: <input type="text" name="sortKeyword" maxlength="20" size="15" value="" style="display:inline">
                             <input  type="button" onClick="sortNotamListing(document.NotamRetrievalForm.sortOrder.value,document.NotamRetrievalForm.sortKeyword.value);" value="Go">
                             
                         </td>
                         </TR>

                         
                             
     


                         <TR>
                             <TD height="3" class="textRed12" align="center">
                         
                             
                             
                             </TD>
                         </TR>

                         <TR>
                             <TD nowrap="nowrap" class="textBlack16Bold">Locations:</TD>
                         </TR>
                         <TR>
                             <TD WIDTH=800 class="textBlack12Bold">

                               <A HREF='#KBAB' class='A1'>KBAB,</A> &nbsp;  <A HREF='#KMHR' class='A1'>KMHR,</A> &nbsp;  <A HREF='#KSUU' class='A1'>KSUU,</A> &nbsp;  <A HREF='#KSMF' class='A1'>KSMF,</A> &nbsp;  <A HREF='#KPMD' class='A1'>KPMD,</A> &nbsp;  <A HREF='#KRNO' class='A1'>KRNO,</A> &nbsp;  <A HREF='#KNFL' class='A1'>KNFL,</A> &nbsp;  <A HREF='#KCIC' class='A1'>KCIC,</A> &nbsp;  <A HREF='#KFAT' class='A1'>KFAT,</A> &nbsp;  <A HREF='#KSCK' class='A1'>KSCK,</A> &nbsp;  <A HREF='#KEDW' class='A1'>KEDW,</A> &nbsp;  <A HREF='#KOAK' class='A1'>KOAK,</A> &nbsp;  <A HREF='#KLAS' class='A1'>KLAS,</A> &nbsp;  <A HREF='#KPDX' class='A1'>KPDX</A> &nbsp; </TD>
                         </TR>
                         <TR>
                             <TD colspan="2">
                             <HR>
                             </TD>
                         </TR>

                         <TR>
                             <TD class="textBlack14"><tt>Data Current as of: &nbsp; <span
                                 class="textRed12">Mon, 01 Aug 2022 18:36:00 GMT</span></tt></TD>
                         </TR>


                     </TABLE>
                      
                     
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KBAB">
                                          KBAB&nbsp;&nbsp; BEALE AFB</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KBAB, KBAB)" > Check All KBAB </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KBAB, KBAB)" > UnCheck All KBAB </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KBAB"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KBAB, KBAB ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KBAB"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KBAB, KBAB ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KBAB%M0616/22%0" id="KBAB">
                                                 <input type=hidden name="saveall" value="KBAB%M0616/22%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0616/22</b> - RWY 33 APPROACH END CENTERLINE LIGHTS EXCEED ALLOWABLE OUTAGES. 29 JUL 06:32
 2022 UNTIL 29 AUG 23:59 2022. CREATED: 29 JUL 06:32 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KBAB%M0614/22%1" id="KBAB">
                                                 <input type=hidden name="saveall" value="KBAB%M0614/22%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0614/22</b> - RWY 15 APPROACH END CENTERLINE LIGHTS EXCEED ALLOWABLE OUTAGES. 29 JUL 06:31
 2022 UNTIL 29 AUG 23:59 2022. CREATED: 29 JUL 06:31 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KBAB%V0240/22%2" id="KBAB">
                                                 <input type=hidden name="saveall" value="KBAB%V0240/22%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>V0240/22</b> - [US DOD PROCEDURAL NOTAM] INSTRUMENT APPROACH PROCEDURE CHANGED
  RNAV (GPS) RWY 33 AMDT 1. CHANGE MINIMA: LNAV MDA, CAT AB 580/24
  475 (500-1/2), CAT CD 580/50 475 (500-1); LNAV MDA NO-LIGHT MINIMA,
  WHEN ALS INOP INCREASE CAT AB RVR TO 55, VIS TO 1 MILE; CAT CD VIS
  TO 1 3/8 MILES. VDP 1.3 NM TO RW33. 22 JUL 16:34 2022 UNTIL 17 NOV 07:00 2022.
 CREATED: 22 JUL 16:34 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KBAB%V0238/22%3" id="KBAB">
                                                 <input type=hidden name="saveall" value="KBAB%V0238/22%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>V0238/22</b> - [US DOD PROCEDURAL NOTAM] INSTRUMENT APPROACH PROCEDURE CHANGED
  TACAN Y RWY 33 AMDT 5. CHANGE MINIMA: S-33, CAT AB 580/24 475
  (500-1/2), CAT CDE 580/50 475 (500-1); CIRCLING, CAT C 620-1 1/2
  507 (600-1 1/2); S-33 NO-LIGHT MINIMA, WHEN ALS INOP INCREASE CAT
  AB RVR TO 55, VIS TO 1 MILE; CAT CDE VIS TO 1 3/8 MILES. VDP 2.3
  DME. 22 JUL 16:32 2022 UNTIL 17 NOV 07:00 2022. CREATED: 22 JUL 16:32 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KBAB%V0236/22%4" id="KBAB">
                                                 <input type=hidden name="saveall" value="KBAB%V0236/22%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>V0236/22</b> - [US DOD PROCEDURAL NOTAM] INSTRUMENT APPROACH PROCEDURE CHANGED
  ILS OR LOC Y RWY 33 AMDT 5. CHANGE MINIMA: S-LOC 33 CAT AB 580/24
  475 (500-1/2), CAT CDE 580/50 475 (500-1); CIRCLING, CAT C 620-1
  1/2 507 (600-1 1/2); S-LOC 33 NO-LIGHT MINIMA, WHEN ALS INOP
  INCREASE CAT AB RVR TO 55, VIS TO 1 MILE; CAT CDE VIS TO 1 3/8
  MILES. LOC VDP 2.3 DME. 22 JUL 16:30 2022 UNTIL 17 NOV 07:00 2022. CREATED:
 22 JUL 16:30 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KBAB%V0234/22%5" id="KBAB">
                                                 <input type=hidden name="saveall" value="KBAB%V0234/22%5" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>V0234/22</b> - [US DOD PROCEDURAL NOTAM] INSTRUMENT APPROACH PROCEDURE CHANGED
  HI-TACAN Z RWY 33 AMDT 5. CHANGE MINIMA: S-33 CAT CDE 580/50 475
  (500-1); CIRCLING, CAT C 620-1 1/2 507 (600-1 1/2); S-33 NO-LIGHT
  MINIMA, WHEN ALS INOP INCREASE CAT CDE VIS TO 1 3/8 MILES. VDP 2.3
  DME. 22 JUL 16:29 2022 UNTIL 17 NOV 07:00 2022. CREATED: 22 JUL 16:29 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KBAB%V0232/22%6" id="KBAB">
                                                 <input type=hidden name="saveall" value="KBAB%V0232/22%6" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>V0232/22</b> - [US DOD PROCEDURAL NOTAM] INSTRUMENT APPROACH PROCEDURE CHANGED
  HI-ILS OR LOC Z RWY 33 AMDT 5. CHANGE MINIMA: S-LOC 33, CAT CDE
  580/50 475 (500-1); CIRCLING, CAT C 620-1 1/2 507 (600-1 1/2);
  S-LOC 33 NO-LIGHT MINIMA, WHEN ALS INOP INCREASE CAT CDE VIS TO 1
  3/8 MILES. LOC VDP 2.3 DME. 22 JUL 16:26 2022 UNTIL 17 NOV 07:00 2022. CREATED:
 22 JUL 16:26 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KBAB%X0338/22%7" id="KBAB">
                                                 <input type=hidden name="saveall" value="KBAB%X0338/22%7" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>X0338/22</b> - DUE TO POTENTIAL 5G INTERFERENCE, RADIO ALTIMETER MAY BE
  UNUSABLE. REFER TO 5G &,150; RADIO ALTIMETER TAB ON DAIP FOR MORE
  INFORMATION AND REPORTING INSTRUCTIONS. 13 JUL 16:56 2022 UNTIL 11 OCT 05:00
 2022. CREATED: 13 JUL 16:56 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KBAB%07/002%8" id="KBAB">
                                                 <input type=hidden name="saveall" value="KBAB%07/002%8" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/002</b> - AIRSPACE SEE FDC 2/0412 ZOA 99.7 SECURITY. 31 JUL 21:00 2022 UNTIL 07 AUG 20:59
 2022. CREATED: 28 JUL 17:07 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KBAB%L0048/22%9" id="KBAB">
                                                 <input type=hidden name="saveall" value="KBAB%L0048/22%9" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>L0048/22</b> - EOD RANGE ACTIVE. 01 AUG 16:00 2022 UNTIL 01 AUG 20:00 2022. CREATED: 01 AUG
 15:44 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                             
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KMHR">
                                          KMHR&nbsp;&nbsp; SACRAMENTO MATHER</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KMHR, KMHR)" > Check All KMHR </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KMHR, KMHR)" > UnCheck All KMHR </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KMHR"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KMHR, KMHR ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KMHR"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KMHR, KMHR ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KMHR%08/001%0" id="KMHR">
                                                 <input type=hidden name="saveall" value="KMHR%08/001%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>08/001</b> (A0262/22) - OBST CRANE (ASN 2022-AWP-10448-OE) 383401N1211857W (.6NM N MHR) UNKNOWN (161FT
 AGL) FLAGGED AND LGTD. 06 AUG 11:30 2022 UNTIL 06 AUG 17:00 2022. CREATED: 01
 AUG 00:07 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KMHR%07/079%1" id="KMHR">
                                                 <input type=hidden name="saveall" value="KMHR%07/079%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/079</b> (A0261/22) - SVC TWR OPN DLY 1300-0300. 04 AUG 13:00 2022 UNTIL 06 AUG 03:00 2022. CREATED:
 31 JUL 20:06 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KMHR%07/078%2" id="KMHR">
                                                 <input type=hidden name="saveall" value="KMHR%07/078%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/078</b> (A0259/22) - SVC TWR OPN. 03 AUG 12:00 2022 UNTIL 04 AUG 04:00 2022. CREATED: 31 JUL 20:06
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KMHR%07/077%3" id="KMHR">
                                                 <input type=hidden name="saveall" value="KMHR%07/077%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/077</b> (A0260/22) - SVC TWR OPN. 02 AUG 13:00 2022 UNTIL 03 AUG 03:00 2022. CREATED: 31 JUL 20:06
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KMHR%07/075%4" id="KMHR">
                                                 <input type=hidden name="saveall" value="KMHR%07/075%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/075</b> - RWY 04R 7000FT DIST REMAINING SIGN LEFT SIDE LGT U/S. 30 JUL 15:44 2022 UNTIL
 06 AUG 14:00 2022. CREATED: 30 JUL 15:44 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KMHR%07/074%5" id="KMHR">
                                                 <input type=hidden name="saveall" value="KMHR%07/074%5" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/074</b> - RWY 22L 4000FT DIST REMAINING SIGN RIGHT SIDE LGT U/S. 30 JUL 15:43 2022 UNTIL
 06 AUG 14:00 2022. CREATED: 30 JUL 15:43 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KMHR%07/070%6" id="KMHR">
                                                 <input type=hidden name="saveall" value="KMHR%07/070%6" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/070</b> (A0256/22) - SVC TWR OPN DLY 1200-0400. 30 JUL 12:00 2022 UNTIL 02 AUG 04:00 2022. CREATED:
 25 JUL 22:58 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KMHR%07/059%7" id="KMHR">
                                                 <input type=hidden name="saveall" value="KMHR%07/059%7" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/059</b> - OBST TOWER LGT (ASR 1269470) 383618.90N1210943.80W (6.9NM ENE MHR) 415.7FT (110.9FT
 AGL) U/S. 19 JUL 18:21 2022 UNTIL 19 AUG 23:59 2022. CREATED: 19 JUL 18:22 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KMHR%01/013%8" id="KMHR">
                                                 <input type=hidden name="saveall" value="KMHR%01/013%8" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>01/013</b> (A0005/22) - AD AP RDO ALTIMETER UNREL. AUTOLAND, HUD TO TOUCHDOWN, ENHANCED FLT VISION SYSTEMS
 TO TOUCHDOWN, HEL OPS REQUIRING RDO ALTIMETER DATA TO INCLUDE HOVER AUTOPILOT
 MODES AND CAT A/B/PERFORMANCE CLASS TKOF AND LDG NOT AUTHORIZED EXC FOR ACFT
 USING APPROVED ALTERNATIVE METHODS OF COMPLIANCE DUE TO 5G C-BAND INTERFERENCE
 PLUS SEE AIRWORTHINESS DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:01 2022 UNTIL
 19 JAN 05:01 2024. CREATED: 13 JAN 07:48 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KMHR%2/1554%9" id="KMHR">
                                                 <input type=hidden name="saveall" value="KMHR%2/1554%9" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1554</b> (A0264/22) - IAP SACRAMENTO MATHER, SACRAMENTO, CA.
 ILS OR LOC RWY 22L, AMDT 7A...
 ILS RWY 22L (SA CAT I AND II), AMDT 7A...
 MISSED APPROACH: CLIMB TO 700 THEN CLIMBING LEFT TURN TO 3000 ON
 HEADING 090 AND LIN VOR/DME R-338 TO COSKA INT/LIN 28.43 DME AND
 HOLD (DME REQUIRED).
 DME REQUIRED EXCEPT FOR ACFT EQUIPPED WITH SUITABLE RNAV SYSTEM
 WITH GPS,
 SAC VORTAC OUT OF SERVICE. 02 AUG 14:30 2022 UNTIL 09 AUG 06:46 2022 ESTIMATED.
 CREATED: 01 AUG 06:47 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KMHR%2/1553%10" id="KMHR">
                                                 <input type=hidden name="saveall" value="KMHR%2/1553%10" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1553</b> (A0263/22) - ODP SACRAMENTO MATHER, SACRAMENTO, CA.
 TAKEOFF MINIMUMS AND (OBSTACLE) DEPARTURE PROCEDURES ORIG...
 DEPARTURE PROCEDURE NA EXCEPT FOR ACFT EQUIPPED WITH SUITABLE RNAV
 SYSTEM WITH GPS,
 SAC VORTAC OUT OF SERVICE. 02 AUG 14:30 2022 UNTIL 09 AUG 06:46 2022 ESTIMATED.
 CREATED: 01 AUG 06:47 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KMHR%2/3780%11" id="KMHR">
                                                 <input type=hidden name="saveall" value="KMHR%2/3780%11" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/3780</b> (A0004/22) - IAP SACRAMENTO MATHER, SACRAMENTO, CA.
 ILS RWY 22L (SA CAT I - II), AMDT 7A ...
 PROCEDURE NA EXC FOR ACFT USING APPROVED ALTERNATIVE METHODS OF
 COMPLIANCE DUE TO 5G C-BAND INTERFERENCE PLUS SEE AIRWORTHINESS
 DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:00 2022 UNTIL 19 JAN 05:06 2024
 ESTIMATED. CREATED: 13 JAN 05:07 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                             
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KSUU">
                                          KSUU&nbsp;&nbsp; TRAVIS AFB</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KSUU, KSUU)" > Check All KSUU </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KSUU, KSUU)" > UnCheck All KSUU </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KSUU"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KSUU, KSUU ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KSUU"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KSUU, KSUU ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSUU%M0811/22%0" id="KSUU">
                                                 <input type=hidden name="saveall" value="KSUU%M0811/22%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0811/22</b> - QUIET HOURS IN EFFECT. NO ARRIVALS, NO DEPARTURES, NO TOUCH AND
  GOS, NO LOW APPROACHES; REAL-WORLD TACAMO DEPARTURES AUTHORIZED. NO
  GROUND OPERATIONS TO INCLUDE ENGINE RUNS, APU USE, POWER CART
  OPERATIONS, AND AGE USE. 04 AUG 16:30 2022 UNTIL 04 AUG 18:00 2022. CREATED:
 01 AUG 14:29 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSUU%M0810/22%1" id="KSUU">
                                                 <input type=hidden name="saveall" value="KSUU%M0810/22%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0810/22</b> - RWY 03R/21L WORK IN PROGRESS GRASS CUTTING WITHIN 100 FT OF RWY
  EDGE. 01 AUG 13:41 2022 UNTIL 02 AUG 01:00 2022. CREATED: 01 AUG 13:41 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSUU%M0809/22%2" id="KSUU">
                                                 <input type=hidden name="saveall" value="KSUU%M0809/22%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0809/22</b> - RWY 21L ILS DOWNGRADED TO CAT 1. 01 AUG 06:17 2022 UNTIL 27 OCT 23:59 2022. CREATED:
 01 AUG 06:17 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSUU%M0808/22%3" id="KSUU">
                                                 <input type=hidden name="saveall" value="KSUU%M0808/22%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0808/22</b> - RWY 03R/21L EAST SIDE 2/9 RDM NOT ILLUMINATED. 01 AUG 06:12 2022 UNTIL 02 AUG
 07:00 2022. CREATED: 01 AUG 06:12 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSUU%M0807/22%4" id="KSUU">
                                                 <input type=hidden name="saveall" value="KSUU%M0807/22%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0807/22</b> - 900 RAMP SPOT 901 RESTRICTED TO AIRCRAFT WITH WINGSPAN OF 170FT
  OR BELOW. 31 JUL 17:21 2022 UNTIL 31 AUG 23:59 2022. CREATED: 31 JUL 17:21
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSUU%M0800/22%5" id="KSUU">
                                                 <input type=hidden name="saveall" value="KSUU%M0800/22%5" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0800/22</b> - ARFF IS REDUCED LEVEL OF SERVICE; USAF CAT 5, WITH 9,700 GALS
  REMAINING. 28 JUL 16:17 2022 UNTIL 05 AUG 23:59 2022. CREATED: 28 JUL 16:17
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSUU%M0779/22%6" id="KSUU">
                                                 <input type=hidden name="saveall" value="KSUU%M0779/22%6" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0779/22</b> - 300 RAMP SPOTS 311 312 RESTICTED TO TOW IN/TOW OUT ONLY. 26 JUL 20:53 2022 UNTIL
 16 AUG 23:59 2022. CREATED: 26 JUL 20:53 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSUU%M0778/22%7" id="KSUU">
                                                 <input type=hidden name="saveall" value="KSUU%M0778/22%7" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0778/22</b> - 300 RAMP CLSD SPOT 310 CLSD. 26 JUL 20:52 2022 UNTIL 16 AUG 23:59 2022. CREATED:
 26 JUL 20:52 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSUU%M0777/22%8" id="KSUU">
                                                 <input type=hidden name="saveall" value="KSUU%M0777/22%8" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0777/22</b> - 300 RAMP CLSD 320 ROW CLSD. 26 JUL 20:50 2022 UNTIL 16 AUG 23:59 2022. CREATED:
 26 JUL 20:50 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSUU%M0657/22%9" id="KSUU">
                                                 <input type=hidden name="saveall" value="KSUU%M0657/22%9" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0657/22</b> - 900 RAMP SPOTS 904, 905, 906 CLSD. 14 JUN 10:41 2022 UNTIL 11 SEP 23:59 2022.
 CREATED: 14 JUN 10:42 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSUU%M0609/22%10" id="KSUU">
                                                 <input type=hidden name="saveall" value="KSUU%M0609/22%10" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0609/22</b> - 300 RAMP ROWS 330 AND 340 CLSD. 26 MAY 17:36 2022 UNTIL 23 AUG 23:59 2022. CREATED:
 26 MAY 17:35 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSUU%X0327/22%11" id="KSUU">
                                                 <input type=hidden name="saveall" value="KSUU%X0327/22%11" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>X0327/22</b> - DUE TO POTENTIAL 5G INTERFERENCE, RADIO ALTIMETER MAY BE
  UNUSABLE. REFER TO 5G &,150; RADIO ALTIMETER TAB ON DAIP FOR MORE
  INFORMATION AND REPORTING INSTRUCTIONS. 13 JUL 16:50 2022 UNTIL 11 OCT 05:00
 2022. CREATED: 13 JUL 16:50 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSUU%L0040/22%12" id="KSUU">
                                                 <input type=hidden name="saveall" value="KSUU%L0040/22%12" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>L0040/22</b> - 200 RAMP SPOT 212 LEAD-IN LINE PARTIALLY MISSING DUE TO NEW
  PAVEMENT. 26 MAY 16:10 2022 UNTIL 23 AUG 23:59 2022. CREATED: 26 MAY 16:09
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                             
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KSMF">
                                          KSMF&nbsp;&nbsp; SACRAMENTO INTL</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KSMF, KSMF)" > Check All KSMF </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KSMF, KSMF)" > UnCheck All KSMF </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KSMF"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KSMF, KSMF ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KSMF"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KSMF, KSMF ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%07/050%0" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%07/050%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/050</b> (A1020/22) - RWY 35L CLSD TO TKOF FOR ACFT WINGSPAN MORE THAN 118FT. 01 AUG 13:30 2022 UNTIL
 31 OCT 23:59 2022. CREATED: 29 JUL 21:15 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%07/049%1" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%07/049%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/049</b> (A1019/22) - RWY 17R CLSD TO LDG FOR ACFT WINGSPAN MORE THAN 118FT. 01 AUG 13:30 2022 UNTIL
 31 OCT 23:59 2022. CREATED: 29 JUL 21:15 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%07/048%2" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%07/048%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/048</b> (A1018/22) - TWY A BTN TWY A11 AND TWY A13 CLSD. 01 AUG 13:30 2022 UNTIL 31 OCT 23:59 2022.
 CREATED: 29 JUL 21:05 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%07/023%3" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%07/023%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/023</b> (A0986/22) - OBST CRANE (ASN 2022-AWP-1207-NRA) 384117N1213555W (0.6NM SW SMF) 132FT (110FT
 AGL) FLAGGED AND LGTD. 19 JUL 21:43 2022 UNTIL 11 JUL 23:59 2023. CREATED: 19
 JUL 21:43 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%07/010%4" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%07/010%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/010</b> (A0958/22) - APRON CARGO 1 RAMP CLSD. 11 JUL 14:00 2022 UNTIL 18 NOV 23:59 2022. CREATED:
 07 JUL 21:33 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%01/046%5" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%01/046%5" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>01/046</b> (A0078/22) - AD AP RDO ALTIMETER UNREL. AUTOLAND, HUD TO TOUCHDOWN, ENHANCED FLT VISION SYSTEMS
 TO TOUCHDOWN, HEL OPS REQUIRING RDO ALTIMETER DATA TO INCLUDE HOVER AUTOPILOT
 MODES AND CAT A/B/PERFORMANCE CLASS TKOF AND LDG NOT AUTHORIZED EXC FOR ACFT
 USING APPROVED ALTERNATIVE METHODS OF COMPLIANCE DUE TO 5G C-BAND INTERFERENCE
 PLUS SEE AIRWORTHINESS DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:01 2022 UNTIL
 19 JAN 05:01 2024. CREATED: 13 JAN 09:14 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%10/023%6" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%10/023%6" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>10/023</b> - OBST ANTENNA (ASN 2021-AWP-3656-NRA) 384140N1213529W (0.1NM SSW SMF) 52FT (29FT
 AGL) LGTD. 20 OCT 21:55 2021 UNTIL 15 APR 23:59 2023. CREATED: 20 OCT 21:55 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%06/019%7" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%06/019%7" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>06/019</b> (A0381/21) - OBST CRANE (ASN 2021-AWP-5664-OE) 384138N1213410W (1.0NM E SMF) 175FT (157FT
 AGL) FLAGGED AND LGTD. 04 JUN 22:03 2021 UNTIL 11 NOV 23:59 2022. CREATED: 04
 JUN 22:03 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%2/1565%8" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%2/1565%8" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1565</b> (A1023/22) - IAP SACRAMENTO INTL, SACRAMENTO, CA.
 ILS OR LOC RWY 17R, AMDT 16D...
 ILS RWY 17R (SA CAT I), AMDT 16D...
 ILS RWY 17R (CAT II AND III), AMDT 16D...
 MISSED APPROACH: CLIMB TO 500 THEN CLIMBING RIGHT TURN TO 2000 ON
 HEADING 270 AND ILA VORTAC R-130 TO ILA VORTAC AND HOLD,
 SAC VORTAC OUT OF SERVICE. 02 AUG 14:30 2022 UNTIL 09 AUG 06:46 2022 ESTIMATED.
 CREATED: 01 AUG 06:47 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%2/1563%9" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%2/1563%9" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1563</b> (A1022/22) - IAP SACRAMENTO INTL, SACRAMENTO, CA.
 ILS OR LOC RWY 17L, AMDT 4C...
 ILS RWY 17L (SA CAT II), AMDT 4C...
 MISSED APPROACH: CLIMB TO 3000 THEN RIGHT TURN ON HEADING 350 AND
 ILA VORTAC R-116 TO ILA VORTAC AND HOLD,
 SAC VORTAC OUT OF SERVICE. 02 AUG 14:30 2022 UNTIL 09 AUG 06:46 2022 ESTIMATED.
 CREATED: 01 AUG 06:47 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%2/1557%10" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%2/1557%10" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1557</b> (A1021/22) - IAP SACRAMENTO INTL, SACRAMENTO, CA.
 ILS OR LOC RWY 35L, AMDT 8...
 MISSED APPROACH: CLIMB TO 2000 DIRECT MYV VOR/DME AND HOLD,
 SAC VORTAC OUT OF SERVICE. 02 AUG 14:30 2022 UNTIL 09 AUG 06:46 2022 ESTIMATED.
 CREATED: 01 AUG 06:47 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%2/2344%11" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%2/2344%11" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/2344</b> (A0926/22) - IAP SACRAMENTO INTL, SACRAMENTO, CA.
 RNAV (RNP) Z RWY 35R, AMDT 2...
 RNP 0.10 DA 326/ HAT 302 ALL CATS. TEMPORARY CRANES 120 MSL
 BEGINNING 2240FT W OF RWY 35R
 (2018-AWP-2541/2542/2543/2544/2545/2546/2547/2548-NRA). 22 JUN 13:06 2022 UNTIL
 22 AUG 13:06 2022 ESTIMATED. CREATED: 22 JUN 13:07 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%2/2343%12" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%2/2343%12" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/2343</b> (A0925/22) - IAP SACRAMENTO INTL, SACRAMENTO, CA.
 ILS OR LOC RWY 35L, AMDT 8...
 RNAV (GPS) Y RWY 17R, AMDT 2C...
 RNAV (GPS) Y RWY 35L, AMDT 3...
 CIRCLING CATS A/B/C MDA 540/HAA 513. TEMPORARY CRANE 171 MSL 1.67NM
 NE OF SMF AIRPORT (2020-AWP-2528-OE). 22 JUN 13:06 2022 UNTIL 22 AUG 13:06 2022
 ESTIMATED. CREATED: 22 JUN 13:07 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%2/2342%13" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%2/2342%13" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/2342</b> (A0927/22) - IAP SACRAMENTO INTL, SACRAMENTO, CA.
 RNAV (GPS) Y RWY 35R, AMDT 2...
 LNAV/VNAV DA 374/ HAT 350 ALL CATS, VISIBILITY ALL CATS 1. LNAV MDA
 400/ HAT 376 ALL CATS. CIRCLING CATS A/B/C MDA 540/HAA 513. VDP
 0.98NM TO RW35R. TEMPORARY CRANES 95 MSL BEGINNING 1916FT W OF RWY
 35R (2020-AWP-141/142/143-NRA), TEMPORARY CRANES 120 MSL BEGINNING
 2240FT W OF RWY 35R
 (2018-AWP-2541/2542/2543/2544/2545/2546/2547/2548-NRA), TEMPORARY
 CRANE 171 MSL 1.67NM NE OF SMF AIRPORT (2020-AWP-2528-OE). 22 JUN 13:06 2022
 UNTIL 22 AUG 13:06 2022 ESTIMATED. CREATED: 22 JUN 13:07 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%2/2341%14" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%2/2341%14" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/2341</b> (A0924/22) - IAP SACRAMENTO INTL, SACRAMENTO, CA.
 RNAV (GPS) Y RWY 17L, AMDT 3A...
 LNAV/VNAV DA 382/HAT 355 ALL CATS, VISIBILITY ALL CATS RVR 3000.
 CIRCLING MDA CATS A/B/C 540/HAA 513.
 TEMPORARY CRANE 171 MSL 5564FT NE OF RWY 17L (2020-AWP-2528-OE). 22 JUN 13:06
 2022 UNTIL 22 AUG 13:06 2022 ESTIMATED. CREATED: 22 JUN 13:07 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%2/2340%15" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%2/2340%15" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/2340</b> (A0923/22) - IAP SACRAMENTO INTL, SACRAMENTO, CA.
 ILS OR LOC RWY 17L, AMDT 4C...
 CIRCLING MDA CATS A/B/C 540/HAA 513.
 JOBUD FIX MINIMUMS (DME REQUIRED) CIRCLING MDA CATS A/B/C 540/HAA
 513.
 TEMPORARY CRANE 171 MSL 1.67 NM NE OF SMF AIRPORT
 (2020-AWP-2528-OE). 22 JUN 13:06 2022 UNTIL 22 AUG 13:06 2022 ESTIMATED. CREATED:
 22 JUN 13:07 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%2/2339%16" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%2/2339%16" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/2339</b> (A0922/22) - IAP SACRAMENTO INTL, SACRAMENTO, CA.
 ILS OR LOC RWY 17R, AMDT 16D...
 CIRCLING MDA CATS A/B/C 540/HAA 513.
 KAYEG FIX MINIMUMS (DME REQUIRED) CIRCLING MDA CATS A/B/C 540/HAA
 513.
 TEMPORARY CRANE 171 MSL 1.67 NM NE OF SMF AIRPORT
 (2020-AWP-2528-OE). 22 JUN 13:06 2022 UNTIL 22 AUG 13:06 2022 ESTIMATED. CREATED:
 22 JUN 13:06 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSMF%2/3716%17" id="KSMF">
                                                 <input type=hidden name="saveall" value="KSMF%2/3716%17" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/3716</b> (A0077/22) - IAP SACRAMENTO INTL, SACRAMENTO, CA.
 ILS RWY 17R (SA CAT I), AMDT 16C ...
 ILS RWY 17R (CAT II - III), AMDT 16C ...
 ILS RWY 17L (SA CAT II), AMDT 4B ...
 PROCEDURE NA EXC FOR ACFT USING APPROVED ALTERNATIVE METHODS OF
 COMPLIANCE DUE TO 5G C-BAND INTERFERENCE PLUS SEE AIRWORTHINESS
 DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:00 2022 UNTIL 19 JAN 05:01 2024
 ESTIMATED. CREATED: 13 JAN 05:02 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                             
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KPMD">
                                          KPMD&nbsp;&nbsp; PALMDALE USAF PLANT 42</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KPMD, KPMD)" > Check All KPMD </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KPMD, KPMD)" > UnCheck All KPMD </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KPMD"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KPMD, KPMD ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KPMD"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KPMD, KPMD ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPMD%M0159/22%0" id="KPMD">
                                                 <input type=hidden name="saveall" value="KPMD%M0159/22%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0159/22</b> - TWY ECHO BETWEEN SIERRA AND ROMEO IS CLSD. 01 AUG 16:32 2022 UNTIL 01 AUG 22:00
 2022. CREATED: 01 AUG 16:32 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPMD%M0158/22%1" id="KPMD">
                                                 <input type=hidden name="saveall" value="KPMD%M0158/22%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0158/22</b> - TWY E HOLDING POSITION SIGN FOR ILS WEST SIDE NOT LGTD ADJACENT
  TO TWY PAPA. 01 AUG 13:49 2022 UNTIL 27 OCT 05:00 2022. CREATED: 01 AUG 13:49
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPMD%M0157/22%2" id="KPMD">
                                                 <input type=hidden name="saveall" value="KPMD%M0157/22%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0157/22</b> - RWY 07/25 REILS UNAVAILABLE. 01 AUG 13:48 2022 UNTIL 27 OCT 05:00 2022. CREATED:
 01 AUG 13:48 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPMD%M0156/22%3" id="KPMD">
                                                 <input type=hidden name="saveall" value="KPMD%M0156/22%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0156/22</b> - RWY 04/22 REILS UNAVAILABLE. 01 AUG 13:48 2022 UNTIL 27 OCT 05:00 2022. CREATED:
 01 AUG 13:48 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPMD%M0155/22%4" id="KPMD">
                                                 <input type=hidden name="saveall" value="KPMD%M0155/22%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0155/22</b> - TWY S HOLD SIGN NORTHEAST SIDE NOT LGTD .LOCATED NORTH OF RWY 22
  INT. 01 AUG 13:47 2022 UNTIL 27 OCT 05:00 2022. CREATED: 01 AUG 13:47 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPMD%X0321/22%5" id="KPMD">
                                                 <input type=hidden name="saveall" value="KPMD%X0321/22%5" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>X0321/22</b> - DUE TO POTENTIAL 5G INTERFERENCE, RADIO ALTIMETER MAY BE
  UNUSABLE. REFER TO 5G &,150; RADIO ALTIMETER TAB ON DAIP FOR MORE
  INFORMATION AND REPORTING INSTRUCTIONS. 13 JUL 16:48 2022 UNTIL 11 OCT 05:00
 2022. CREATED: 13 JUL 16:48 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPMD%07/018%6" id="KPMD">
                                                 <input type=hidden name="saveall" value="KPMD%07/018%6" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/018</b> - OBST POWER LINE LGT (ASN 2010-AWP-4482-OE) 343316N1181045W (6.4NM SW PMD) 3501FT
 (134FT AGL) U/S. 28 JUL 18:41 2022 UNTIL 12 AUG 18:41 2022. CREATED: 28 JUL 18:41
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPMD%07/011%7" id="KPMD">
                                                 <input type=hidden name="saveall" value="KPMD%07/011%7" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/011</b> - OBST POWER LINE LGT (ASN 2010-AWP-7599-OE) 342915N1180705W (8.7NM S PMD) 3451FT
 (202FT AGL) U/S. 23 JUL 12:06 2022 UNTIL 07 AUG 12:06 2022. CREATED: 23 JUL 12:06
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPMD%02/008%8" id="KPMD">
                                                 <input type=hidden name="saveall" value="KPMD%02/008%8" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>02/008</b> - OBST TOWER LGT (ASR 1014645) 343954.30N1180046.10W (4.1NM ENE PMD) 2667.3FT (206.7FT
 AGL) U/S. 13 FEB 19:47 2022 UNTIL 31 DEC 23:59 2024. CREATED: 13 FEB 19:47 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPMD%01/003%9" id="KPMD">
                                                 <input type=hidden name="saveall" value="KPMD%01/003%9" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>01/003</b> (A0009/22) - AD AP RDO ALTIMETER UNREL. AUTOLAND, HUD TO TOUCHDOWN, ENHANCED FLT VISION SYSTEMS
 TO TOUCHDOWN, HEL OPS REQUIRING RDO ALTIMETER DATA TO INCLUDE HOVER AUTOPILOT
 MODES AND CAT A/B/PERFORMANCE CLASS TKOF AND LDG NOT AUTHORIZED EXC FOR ACFT
 USING APPROVED ALTERNATIVE METHODS OF COMPLIANCE DUE TO 5G C-BAND INTERFERENCE
 PLUS SEE AIRWORTHINESS DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:01 2022 UNTIL
 19 JAN 05:01 2024. CREATED: 13 JAN 08:41 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPMD%03/024%10" id="KPMD">
                                                 <input type=hidden name="saveall" value="KPMD%03/024%10" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>03/024</b> - AIRSPACE UAS WI AN AREA DEFINED AS 5NM EITHER SIDE OF A LINE FM PMD061001 TO
 PMD054011 SFC-12000FT. 29 MAR 13:00 2018 UNTIL PERM. CREATED: 29 MAR 13:16 2018
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPMD%2/3612%11" id="KPMD">
                                                 <input type=hidden name="saveall" value="KPMD%2/3612%11" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/3612</b> (A0008/22) - IAP PALMDALE USAF PLANT 42,
 Palmdale, CA.
 ILS OR LOC RWY 25, AMDT 10...
 RADAR OR DME REQUIRED EXCEPT FOR AIRCRAFT EQUIPPED WITH SUITABLE
 RNAV SYSTEM WITH GPS,
 LHS VORTAC OUT OF SERVICE. 12 JAN 21:03 2022 UNTIL 22 JAN 21:03 2023 ESTIMATED.
 CREATED: 12 JAN 21:04 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                             
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KRNO">
                                          KRNO&nbsp;&nbsp; RENO/TAHOE INTL</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KRNO, KRNO)" > Check All KRNO </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KRNO, KRNO)" > UnCheck All KRNO </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KRNO"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KRNO, KRNO ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KRNO"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KRNO, KRNO ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%M0028/22%0" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%M0028/22%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0028/22</b> - ANG OPS CLSD. 01 AUG 14:40 2022 UNTIL 01 AUG 23:00 2022. CREATED: 01 AUG 14:40
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%07/097%1" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%07/097%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/097</b> (A0729/22) - NAV ILS RWY 16R GP U/S. 01 AUG 14:00 2022 UNTIL 01 AUG 23:59 2022. CREATED: 29
 JUL 19:45 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%07/020%2" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%07/020%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/020</b> - OBST TOWER LGT (ASR 1059085) 392204.00N1194711.00W (8.0NM S RNO) 6235.9FT (195.9FT
 AGL) U/S. 09 JUL 20:04 2022 UNTIL 23 AUG 20:03 2022. CREATED: 09 JUL 20:04 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%05/081%3" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%05/081%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>05/081</b> (A0565/22) - OBST CRANE (ASN 2022-AWP-2820-OE) 393013N1194535W (0.5NM NE RNO) 4552FT (150FT
 AGL) FLAGGED AND LGTD. 19 MAY 18:53 2022 UNTIL 01 DEC 23:59 2022. CREATED: 19
 MAY 18:51 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%01/096%4" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%01/096%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>01/096</b> (A0050/22) - OBST CRANE LGT (ASN 2020-AWP-8852-OE) 393111N1194701W (1.4NM NNW RNO) 4684FT
 (220FT AGL) U/S. 21 JAN 21:10 2022 UNTIL 21 JAN 23:59 2023. CREATED: 21 JAN 21:10
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%01/049%5" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%01/049%5" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>01/049</b> (A0020/22) - AD AP RDO ALTIMETER UNREL. AUTOLAND, HUD TO TOUCHDOWN, ENHANCED FLT VISION SYSTEMS
 TO TOUCHDOWN, HEL OPS REQUIRING RDO ALTIMETER DATA TO INCLUDE HOVER AUTOPILOT
 MODES AND CAT A/B/PERFORMANCE CLASS TKOF AND LDG NOT AUTHORIZED EXC FOR ACFT
 USING APPROVED ALTERNATIVE METHODS OF COMPLIANCE DUE TO 5G C-BAND INTERFERENCE
 PLUS SEE AIRWORTHINESS DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:01 2022 UNTIL
 19 JAN 05:01 2024. CREATED: 13 JAN 08:50 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%12/022%6" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%12/022%6" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>12/022</b> (A0846/20) - OBST CRANE (ASN 2020-AWP-8856-OE) 393207N1194718W (2.37NM NW RNO) 4727FT (220FT
 AGL) FLAGGED AND LGTD. 08 DEC 15:00 2020 UNTIL 01 MAR 23:59 2023. CREATED: 03
 DEC 23:36 2020
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%2/1572%7" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%2/1572%7" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1572</b> (A0734/22) - IAP RENO/TAHOE INTL, RENO, NV.
 ILS OR LOC/DME RWY 34L, ORIG-C...
 ILS Y RWY 16R, ORIG...
 LOC Y RWY 16R, ORIG-A...
 DME REQUIRED EXCEPT FOR ACFT EQUIPPED WITH SUITABLE RNAV SYSTEM
 WITH GPS,
 HZN VORTAC OUT OF SERVICE. 02 AUG 14:00 2022 UNTIL 09 AUG 07:05 2022 ESTIMATED.
 CREATED: 01 AUG 07:06 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%2/1571%8" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%2/1571%8" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1571</b> (A0733/22) - SID RENO/TAHOE INTL, RENO, NV.
 SPLTM FOUR DEPARTURE (RNAV)...
 GPS REQUIRED, HZN VORTAC OUT OF SERVICE. 02 AUG 14:00 2022 UNTIL 09 AUG 07:05
 2022 ESTIMATED. CREATED: 01 AUG 07:06 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%2/1570%9" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%2/1570%9" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1570</b> (A0732/22) - SID RENO/TAHOE INTL, RENO, NV.
 WAGGE SIX DEPARTURE...
 LOVELOCK TRANSITION NA EXCEPT FOR ACFT EQUIPPED WITH SUITABLE RNAV
 SYSTEM WITH GPS,
 HZN VORTAC OUT OF SERVICE. 02 AUG 14:00 2022 UNTIL 09 AUG 07:05 2022 ESTIMATED.
 CREATED: 01 AUG 07:06 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%2/1569%10" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%2/1569%10" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1569</b> (A0731/22) - SID RENO/TAHOE INTL, RENO, NV.
 PVINE THREE DEPARTURE (RNAV)...
 PYGOW TRANSITION: GPS REQUIRED,
 HZN VORTAC OUT OF SERVICE. 02 AUG 14:00 2022 UNTIL 09 AUG 07:05 2022 ESTIMATED.
 CREATED: 01 AUG 07:06 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%2/9401%11" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%2/9401%11" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/9401</b> (A0716/22) - SID RENO/TAHOE INTL, RENO, NV.
 WAGGE SIX DEPARTURE...
 MUSTANG TRANSITION NA. 27 JUL 12:24 2022 UNTIL 27 JUL 12:24 2024 ESTIMATED.
 CREATED: 27 JUL 12:25 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%2/9012%12" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%2/9012%12" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/9012</b> (A0711/22) - SID RENO/TAHOE INTL, RENO, NV.
 WAGGE SIX DEPARTURE...
 LOVELOCK TRANSITION NA EXCEPT FOR AIRCRAFT EQUIPPED WITH SUITABLE
 RNAV SYSTEM WITH GPS,
 LLC VOR OUT OF SERVICE. 26 JUL 18:57 2022 UNTIL 26 AUG 18:57 2022 ESTIMATED.
 CREATED: 26 JUL 18:57 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%2/5059%13" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%2/5059%13" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/5059</b> (A0279/22) - SID RENO/TAHOE INTL, RENO, NV.
 HUNGRY THREE DEPARTURE...
 PVINE THREE DEPARTURE (RNAV)...
 RENO NINE DEPARTURE...
 SPLTM FOUR DEPARTURE (RNAV)...
 RWY 34L, TEMPORARY CRANE 484FT FROM DER, 576FT LEFT OF CENTERLINE,
 15FT AGL/ 4433FT MSL (2020-AWP-3940-NRA). RWY 34R, TEMPORARY CRANE
 490FT FROM DER, 411FT LEFT OF CENTERLINE, 15FT AGL/ 4430FT MSL
 (2020-AWP-3939-NRA).
 ALL OTHER DATA REMAINS AS PUBLISHED. 07 APR 13:44 2022 UNTIL 31 AUG 13:44 2022
 ESTIMATED. CREATED: 07 APR 13:45 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%2/5058%14" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%2/5058%14" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/5058</b> (A0278/22) - SID RENO/TAHOE INTL, RENO, NV.
 MUSTANG EIGHT DEPARTURE...
 WAGGE SIX DEPARTURE...
 ZEFFR SIX DEPARTURE (RNAV)...
 ADD TAKEOFF OBSTACLE NOTE: RWY 16L, TEMPORARY CRANE 88FT FROM DER,
 270FT RIGHT OF CENTERLINE, 15FT AGL/ 4418FT MSL
 (2020-AWP-3944-NRA). RWY 16R, TEMPORARY CRANE 59FT FROM DER, 404FT
 LEFT OF CENTERLINE, 15FT AGL/ 4425FT MSL (2020-AWP-3945-NRA)..
 ALL OTHER DATA REMAINS AS PUBLISHED. 07 APR 13:44 2022 UNTIL 31 AUG 13:44 2022
 ESTIMATED. CREATED: 07 APR 13:45 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%2/5057%15" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%2/5057%15" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/5057</b> (A0277/22) - ODP RENO/TAHOE INTL, RENO, NV.
 TAKEOFF MINIMUMS AND (OBSTACLE) DEPARTURE PROCEDURES AMDT 4...
 ADD TAKEOFF OBSTACLE NOTE: RWY 16L, TEMPORARY CRANE 88FT FROM DER,
 270FT RIGHT OF CENTERLINE, 15FT AGL/ 4418FT MSL
 (2020-AWP-3944-NRA). RWY 16R, TEMPORARY CRANE 59FT FROM DER, 404FT
 LEFT OF CENTERLINE, 15FT AGL/ 4425FT MSL (2020-AWP-3945-NRA). RWY
 34L, TEMPORARY CRANE 484FT FROM DER, 576FT LEFT OF CENTERLINE, 15FT
 AGL/ 4433FT MSL (2020-AWP-3940-NRA). RWY 34R, TEMPORARY CRANE 490FT
 FROM DER, 411FT LEFT OF CENTERLINE, 15FT AGL/ 4430FT MSL
 (2020-AWP-3939-NRA).
 ALL OTHER DATA REMAINS AS PUBLISHED. 07 APR 13:44 2022 UNTIL 31 AUG 13:44 2022
 ESTIMATED. CREATED: 07 APR 13:45 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%2/6314%16" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%2/6314%16" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/6314</b> (A0229/22) - IAP RENO/TAHOE INTL, RENO, NV.
 RNAV (RNP) Z RWY 16L, AMDT 1B...
 DISREGARD NOTE: WHEN VGSI INOP, PROCEDURE NA AT NIGHT. 18 MAR 12:40 2022 UNTIL
 18 MAR 12:40 2024 ESTIMATED. CREATED: 18 MAR 12:46 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%2/3711%17" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%2/3711%17" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/3711</b> (A0019/22) - IAP RENO/TAHOE INTL, RENO, NV.
 RNAV (RNP) Y RWY 16L, AMDT 1B...
 RNAV (RNP) Y RWY 16R, AMDT 1B...
 RNAV (RNP) Z RWY 16L, AMDT 1B...
 RNAV (RNP) Z RWY 16R, AMDT 1B...
 RNAV (RNP) Z RWY 34L, ORIG-A...
 RNAV (RNP) Z RWY 34R, ORIG-A...
 PROCEDURE NA EXC FOR ACFT USING APPROVED ALTERNATIVE METHODS OF
 COMPLIANCE DUE TO 5G C-BAND INTERFERENCE PLUS SEE AIRWORTHINESS
 DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:00 2022 UNTIL 19 JAN 05:01 2024
 ESTIMATED. CREATED: 13 JAN 05:02 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%1/2305%18" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%1/2305%18" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 1/2305</b> (A0536/21) - IAP RENO/TAHOE INTL, Reno, NV.
 RNAV (GPS) Y RWY 34R, ORIG-B...
 LPV CATS A/B/C DA 5344/HAT 936. VIS CATS A/B/C 2. 07 SEP 14:34 2021 UNTIL 05
 SEP 14:34 2023 ESTIMATED. CREATED: 07 SEP 14:34 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%1/2733%19" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%1/2733%19" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 1/2733</b> (A0275/21) - IAP RENO/TAHOE INTL, RENO, NV.
 RNAV (RNP) Z RWY 34L, ORIG-A...
 RNP 0.30 DA 5393/ HAT 983 ALL CATS, VISIBILITY ALL CATS 4.
 NOTE: INOPERATIVE TABLE DOES NOT APPLY TO RNP 0.30 DA. 31 MAR 13:36 2021 UNTIL
 31 MAR 13:36 2023 ESTIMATED. CREATED: 31 MAR 13:37 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KRNO%1/4239%20" id="KRNO">
                                                 <input type=hidden name="saveall" value="KRNO%1/4239%20" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 1/4239</b> (A0150/21) - SID RENO/TAHOE INTL, RENO, NV.
 ZEFFR SIX DEPARTURE (RNAV)...
 TAKE-OFF MINIMUMS RWY 16R STANDARD WITH MINIMUM CLIMB OF 440 TO
 9400.
 ALL OTHER DATA REMAINS AS PUBLISHED. 16 FEB 18:17 2021 UNTIL 16 FEB 18:17 2023
 ESTIMATED. CREATED: 16 FEB 18:17 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                             
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KNFL">
                                          KNFL&nbsp;&nbsp; FALLON NAS (VAN VOORHIS FLD)</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KNFL, KNFL)" > Check All KNFL </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KNFL, KNFL)" > UnCheck All KNFL </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KNFL"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KNFL, KNFL ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KNFL"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KNFL, KNFL ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KNFL%M0228/22%0" id="KNFL">
                                                 <input type=hidden name="saveall" value="KNFL%M0228/22%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0228/22</b> - TWY G WORK IN PROGRESS CONST NORTH SIDE. CALA STILL ACCESSIBLE
  FROMTXWY 'A' & 'G'. TXWY 'F' WILL BE ARM/DEARM AS APPLICABLE. 27 JUL 14:00
 2022 UNTIL 26 AUG 23:59 2022. CREATED: 26 JUL 18:08 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KNFL%M0214/22%1" id="KNFL">
                                                 <input type=hidden name="saveall" value="KNFL%M0214/22%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0214/22</b> - AERODROME HOURS OF OPERATION ARE AS PUBLISHED IN THE DOD
  (ENROUTE) IFR SUPPLEMENT FOR AUGUST 2022 EXCEPT AS FOLLOWS: 06AUG
  1900Z-2100Z (LOG SUPPORT), 07AUG CLSD, 13AUG 1600Z - 0100Z, 14AUG
  CLSD, 20-21AUG CLSD, 27-28AUG CLSD. 19 JUL 16:42 2022 UNTIL 01 SEP 15:30 2022.
 CREATED: 19 JUL 16:42 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KNFL%M0205/22%2" id="KNFL">
                                                 <input type=hidden name="saveall" value="KNFL%M0205/22%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0205/22</b> - AERODROME OFFICIAL BUSINESS ONLY. 08 JUL 15:44 2022 UNTIL 13 AUG 07:00 2022.
 CREATED: 08 JUL 15:44 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KNFL%M0170/22%3" id="KNFL">
                                                 <input type=hidden name="saveall" value="KNFL%M0170/22%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0170/22</b> - OBSTACLE ANTENNA LGT 393307N1184956W (10NM NORTHWEST KNFL) 4525FT
  MSL (625FT AGL) UNSERVICEABLE. 25 MAY 16:10 2022 UNTIL 23 AUG 16:09 2022. CREATED:
 25 MAY 16:09 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KNFL%M0161/22%4" id="KNFL">
                                                 <input type=hidden name="saveall" value="KNFL%M0161/22%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0161/22</b> - TWY B CLSD WEST RWY 31L. TWY A CLSD SOUTH INTXN TWY A/C/D. 14 MAY 03:06 2022
 UNTIL 10 AUG 23:59 2022. CREATED: 14 MAY 03:05 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KNFL%V0041/22%5" id="KNFL">
                                                 <input type=hidden name="saveall" value="KNFL%V0041/22%5" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>V0041/22</b> - [US DOD PROCEDURAL NOTAM] STANDARD INSTRUMENT DEPARTURE (SID) NOT
  AUTHORIZED TYWAN1 HZN TRANSITION , HZN VORTAC OTS. 01 AUG 17:17 2022 UNTIL
 09 AUG 07:05 2022. CREATED: 01 AUG 17:17 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KNFL%L0006/22%6" id="KNFL">
                                                 <input type=hidden name="saveall" value="KNFL%L0006/22%6" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>L0006/22</b> - FRTC FIRE SEASON RESTRICTIONS ARE IN EFFECT BEGINNING 13JUN2022
  DUE TO EXTREME FIRE DANGER. AIRBORNE FLARES ARE NOT ALLOWED, AND
  THERE ARE LIMITATIONS ON THE USE OF GROUND PYROTECHNICS AND TRACERS
  WITH STRAFE. SPECIFICS ARE AVAILABLE IN DCAST (FALLON RANGE
  SCHEDULING TOOL) OR CONTACT NAWDC RANGE DIVISON 775-426-2108/2101
  FOR FURTHER GUIDANCE. 03 JUN 21:00 2022 UNTIL 31 AUG 23:59 2022. CREATED: 03
 JUN 21:00 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                             
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KCIC">
                                          KCIC&nbsp;&nbsp; CHICO MUNI</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KCIC, KCIC)" > Check All KCIC </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KCIC, KCIC)" > UnCheck All KCIC </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KCIC"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KCIC, KCIC ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KCIC"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KCIC, KCIC ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KCIC%07/013%0" id="KCIC">
                                                 <input type=hidden name="saveall" value="KCIC%07/013%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/013</b> - OBST TOWER LGT (ASR 1012346) 395745.00N1214244.00W (12.0NM NE CIC) 3943.2FT (402.9FT
 AGL) U/S. 30 JUL 11:45 2022 UNTIL 14 AUG 10:45 2022. CREATED: 30 JUL 11:44 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KCIC%07/009%1" id="KCIC">
                                                 <input type=hidden name="saveall" value="KCIC%07/009%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/009</b> - OBST TOWER LGT (ASR 1049506) 395742.70N1214243.10W (12.0NM NE CIC) 3928.8FT (403.9FT
 AGL) U/S. 18 JUL 14:46 2022 UNTIL 01 AUG 23:59 2022. CREATED: 18 JUL 14:46 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KCIC%07/008%2" id="KCIC">
                                                 <input type=hidden name="saveall" value="KCIC%07/008%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/008</b> - OBST TOWER LGT (ASR 1061341) 394726.80N1215339.30W (1.7NM W CIC) 263.8FT (95.8FT
 AGL) U/S. 18 JUL 07:57 2022 UNTIL 17 AUG 07:57 2022. CREATED: 18 JUL 07:57 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KCIC%01/009%3" id="KCIC">
                                                 <input type=hidden name="saveall" value="KCIC%01/009%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>01/009</b> - AD AP RDO ALTIMETER UNREL. AUTOLAND, HUD TO TOUCHDOWN, ENHANCED FLT VISION SYSTEMS
 TO TOUCHDOWN, HEL OPS REQUIRING RDO ALTIMETER DATA TO INCLUDE HOVER AUTOPILOT
 MODES AND CAT A/B/PERFORMANCE CLASS TKOF AND LDG NOT AUTHORIZED EXC FOR ACFT
 USING APPROVED ALTERNATIVE METHODS OF COMPLIANCE DUE TO 5G C-BAND INTERFERENCE
 PLUS SEE AIRWORTHINESS DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:01 2022 UNTIL
 19 JAN 05:01 2024. CREATED: 13 JAN 05:47 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KCIC%08/011%4" id="KCIC">
                                                 <input type=hidden name="saveall" value="KCIC%08/011%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>08/011</b> - TWY N COMMISSIONED 250FT X 65FT ASPH LGTD. 11 AUG 00:24 2021 UNTIL PERM. CREATED:
 11 AUG 00:24 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KCIC%08/010%5" id="KCIC">
                                                 <input type=hidden name="saveall" value="KCIC%08/010%5" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>08/010</b> - TWY G CHANGED TO TWY N. 11 AUG 00:13 2021 UNTIL PERM. CREATED: 11 AUG 00:13 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KCIC%08/009%6" id="KCIC">
                                                 <input type=hidden name="saveall" value="KCIC%08/009%6" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>08/009</b> - TWY G BTN TWY A AND RWY 13L/31R DECOMMISSIONED. 11 AUG 00:11 2021 UNTIL PERM.
 CREATED: 11 AUG 00:11 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KCIC%08/008%7" id="KCIC">
                                                 <input type=hidden name="saveall" value="KCIC%08/008%7" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>08/008</b> - TWY G BTN TWY R AND RWY 13L/31R, TWY F BTN TWY R AND TWY A REMOVED. 11 AUG 00:11
 2021 UNTIL PERM. CREATED: 11 AUG 00:11 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KCIC%11/018%8" id="KCIC">
                                                 <input type=hidden name="saveall" value="KCIC%11/018%8" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>11/018</b> - TWY F BTN TWY A AND TWY R DECOMMISSIONED. 07 NOV 21:04 2019 UNTIL PERM. CREATED:
 07 NOV 21:04 2019
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                             
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KFAT">
                                          KFAT&nbsp;&nbsp; FRESNO YOSEMITE INTL</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KFAT, KFAT)" > Check All KFAT </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KFAT, KFAT)" > UnCheck All KFAT </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KFAT"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KFAT, KFAT ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KFAT"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KFAT, KFAT ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KFAT%07/008%0" id="KFAT">
                                                 <input type=hidden name="saveall" value="KFAT%07/008%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/008</b> (A0492/22) - OBST CRANE (ASN UNKNOWN) 364618N1194351W (0.66NM SSW FAT)
 UNKNOWN (100FT AGL) FLAGGED. 01 AUG 14:00 2022 UNTIL 01 AUG 23:59 2022. CREATED:
 29 JUL 22:27 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KFAT%01/001%1" id="KFAT">
                                                 <input type=hidden name="saveall" value="KFAT%01/001%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>01/001</b> (A0038/22) - FCH&nbsp;AD AP RDO ALTIMETER UNREL. AUTOLAND, HUD TO TOUCHDOWN, ENHANCED FLT VISION SYSTEMS
 TO TOUCHDOWN, HEL OPS REQUIRING RDO ALTIMETER DATA TO INCLUDE HOVER AUTOPILOT
 MODES AND CAT A/B/PERFORMANCE CLASS TKOF AND LDG NOT AUTHORIZED EXC FOR ACFT
 USING APPROVED ALTERNATIVE METHODS OF COMPLIANCE DUE TO 5G C-BAND INTERFERENCE
 PLUS SEE AIRWORTHINESS DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:01 2022 UNTIL
 19 JAN 05:01 2024. CREATED: 13 JAN 06:12 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KFAT%01/030%2" id="KFAT">
                                                 <input type=hidden name="saveall" value="KFAT%01/030%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>01/030</b> (A0037/22) - AD AP RDO ALTIMETER UNREL. AUTOLAND, HUD TO TOUCHDOWN, ENHANCED FLT VISION SYSTEMS
 TO TOUCHDOWN, HEL OPS REQUIRING RDO ALTIMETER DATA TO INCLUDE HOVER AUTOPILOT
 MODES AND CAT A/B/PERFORMANCE CLASS TKOF AND LDG NOT AUTHORIZED EXC FOR ACFT
 USING APPROVED ALTERNATIVE METHODS OF COMPLIANCE DUE TO 5G C-BAND INTERFERENCE
 PLUS SEE AIRWORTHINESS DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:01 2022 UNTIL
 19 JAN 05:01 2024. CREATED: 13 JAN 06:11 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KFAT%2/0169%3" id="KFAT">
                                                 <input type=hidden name="saveall" value="KFAT%2/0169%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/0169</b> (A0491/22) - IAP FRESNO YOSEMITE INTL, FRESNO, CA.
 LOC Y RWY 11L, AMDT 3A...
 MISSED APPROACH: CLIMB TO 1900 ON HEADING 112.35 FOR RADAR VECTORS.
 (RADAR REQUIRED),
 PXN VORTAC OUT OF SERVICE. 28 JUL 11:20 2022 UNTIL 28 AUG 11:20 2022 ESTIMATED.
 CREATED: 28 JUL 11:21 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KFAT%2/8666%4" id="KFAT">
                                                 <input type=hidden name="saveall" value="KFAT%2/8666%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/8666</b> (A0175/22) - IAP FRESNO YOSEMITE INTL, FRESNO, CA.
 ILS Y RWY 29R (SA CAT I), AMDT 39A ...
 ILS Y RWY 29R (CAT II - III), AMDT 39A ...
 PROCEDURE NA EXC FOR ACFT USING APPROVED ALTERNATIVE METHODS OF
 COMPLIANCE DUE TO 5G C-BAND INTERFERENCE PLUS SEE AIRWORTHINESS
 DIRECTIVES 2021-23-12, 2021-23-13. 24 MAR 12:53 2022 UNTIL 24 MAR 12:53 2024
 ESTIMATED. CREATED: 24 MAR 12:53 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                             
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KSCK">
                                          KSCK&nbsp;&nbsp; STOCKTON METRO</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KSCK, KSCK)" > Check All KSCK </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KSCK, KSCK)" > UnCheck All KSCK </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KSCK"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KSCK, KSCK ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KSCK"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KSCK, KSCK ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSCK%08/001%0" id="KSCK">
                                                 <input type=hidden name="saveall" value="KSCK%08/001%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>08/001</b> (A0168/22) - SVC TAR/SSR U/S. 02 AUG 15:00 2022 UNTIL 02 AUG 21:00 2022. CREATED: 01 AUG 15:17
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSCK%07/020%1" id="KSCK">
                                                 <input type=hidden name="saveall" value="KSCK%07/020%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/020</b> - OBST TOWER LGT (ASR 1258324) 375305.60N1212133.70W (5.7NM W SCK) 101.0FT (94.2FT
 AGL) U/S. 25 JUL 05:21 2022 UNTIL 09 AUG 04:21 2022. CREATED: 25 JUL 05:20 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSCK%07/018%2" id="KSCK">
                                                 <input type=hidden name="saveall" value="KSCK%07/018%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/018</b> (A0164/22) - TWY B BTN TWY M AND TWY H CLSD TO ACFT WINGSPAN MORE THAN 79FT. 19 JUL 21:00
 2022 UNTIL 30 AUG 01:00 2022. CREATED: 19 JUL 19:17 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSCK%01/007%3" id="KSCK">
                                                 <input type=hidden name="saveall" value="KSCK%01/007%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>01/007</b> (A0008/22) - AD AP RDO ALTIMETER UNREL. AUTOLAND, HUD TO TOUCHDOWN, ENHANCED FLT VISION SYSTEMS
 TO TOUCHDOWN, HEL OPS REQUIRING RDO ALTIMETER DATA TO INCLUDE HOVER AUTOPILOT
 MODES AND CAT A/B/PERFORMANCE CLASS TKOF AND LDG NOT AUTHORIZED EXC FOR ACFT
 USING APPROVED ALTERNATIVE METHODS OF COMPLIANCE DUE TO 5G C-BAND INTERFERENCE
 PLUS SEE AIRWORTHINESS DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:01 2022 UNTIL
 19 JAN 05:01 2024. CREATED: 13 JAN 09:07 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KSCK%2/3770%4" id="KSCK">
                                                 <input type=hidden name="saveall" value="KSCK%2/3770%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/3770</b> (A0007/22) - IAP STOCKTON METRO, STOCKTON, CA.
 ILS RWY 29R (SA CAT II), AMDT 22A ...
 PROCEDURE NA EXC FOR ACFT USING APPROVED ALTERNATIVE METHODS OF
 COMPLIANCE DUE TO 5G C-BAND INTERFERENCE PLUS SEE AIRWORTHINESS
 DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:00 2022 UNTIL 19 JAN 05:06 2024
 ESTIMATED. CREATED: 13 JAN 05:06 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                             
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KEDW">
                                          KEDW&nbsp;&nbsp; EDWARDS AFB</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KEDW, KEDW)" > Check All KEDW </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KEDW, KEDW)" > UnCheck All KEDW </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KEDW"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KEDW, KEDW ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KEDW"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KEDW, KEDW ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%M0692/22%0" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%M0692/22%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0692/22</b> - PJE 2NMR EDW 212.1/15.9 (ERICKSON DZ), SFC TO 10,000� AGL. 03 AUG 02:00 2022
 UNTIL 03 AUG 04:30 2022. CREATED: 01 AUG 16:16 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%M0691/22%1" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%M0691/22%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0691/22</b> - PJE 2NMR EDW 212.1/15.9 (ERICKSON DZ), SFC TO 10,000� AGL. 02 AUG 20:00 2022
 UNTIL 02 AUG 23:00 2022. CREATED: 01 AUG 16:15 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%M0690/22%2" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%M0690/22%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0690/22</b> - NVD OPS SFC TO 6,000' MSL. 04 AUG 03:00 2022 UNTIL 04 AUG 04:30 2022. CREATED:
 01 AUG 14:48 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%M0687/22%3" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%M0687/22%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0687/22</b> - SUAS ACTIVITY WITHIN THE VICINITY OF BORON MINE
  (35-04-41N/117-44-56W, 35-04-40N/117-37-45W, 35-00-49N/117-37-46W,
  35-00-15N/117-47-31W, 35-00-11N/117-46-27W, 35-00-16N/117-47-31W,
  35-01-43N/117-47-32W, 35-01-46N/117-48-04W, 35-01-09N/117-48-04W,
  35-02-09N/117-47-31W, 35-02-35N/117-47-32W, 35-01-35N/117-44-55W),
  SFC � 400� AGL. DLY 1330-0100, 03 AUG 13:30 2022 UNTIL 13 AUG 01:00 2022. CREATED:
 28 JUL 20:32 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%M0666/22%4" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%M0666/22%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0666/22</b> - PRESCRIBED FIRE ACTIVITIES ARE TENTATIVELY PLANNED FOR 23 JULY -
  2 AUGUST, WEATHER PERMITTING. BURNS WILL TAKE PLACE WITHIN 2NM
  RADIUS OF PIUTE PONDS COMPLEX (N 34� 46.942 X W 118� 07.326. DLY 1400-0300,
 23 JUL 14:00 2022 UNTIL 03 AUG 03:00 2022. CREATED: 19 JUL 23:24 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%M0663/22%5" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%M0663/22%5" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0663/22</b> - RWY 05L/23R CLOSED. AIRCRAFT MAY CROSS RWY 05L/23R AT TWY ALPHA,
  BRAVO AND CHARLIE INTERSECTIONS WITH ATC APPROVAL. 19 JUL 20:15 2022 UNTIL
 19 SEP 20:15 2022. CREATED: 19 JUL 20:15 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%M0661/22%6" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%M0661/22%6" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0661/22</b> - AERODROME RWY 05R/23L 2/13 DISTANCE REMAINING MARKER NOT
  ILLUMINTATED. 19 JUL 04:48 2022 UNTIL 18 AUG 05:00 2022. CREATED: 19 JUL 04:48
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%M0655/22%7" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%M0655/22%7" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0655/22</b> - SUAS ACTIVITY WITHIN THE VICINITY OF BORON MINE
  (35-04-41N/117-44-56W, 35-04-40N/117-37-45W, 35-00-49N/117-37-46W,
  35-00-15N/117-47-31W, 35-00-11N/117-46-27W, 35-00-16N/117-47-31W,
  35-01-43N/117-47-32W, 35-01-46N/117-48-04W,�35-01-09N/117-48-04W,
  35-02-09N/117-47-31W, 35-02-35N/117-47-32W, 35-01-35N/117-44-55W),
  SFC � 400� AGL. DLY 1330-0100, 21 JUL 13:30 2022 UNTIL 03 AUG 01:00 2022. CREATED:
 18 JUL 18:11 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%M0467/22%8" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%M0467/22%8" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0467/22</b> - TWY CHARLIE VORTAC GROUND RECEIVER CHECKPOINT RADIAL AND DISTANCE
  INCORRECT; SHOULD READ BRG - 226, DIST 7.6 NM. 17 MAY 16:53 2022 UNTIL 12 AUG
 23:59 2022. CREATED: 17 MAY 16:53 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%M0466/22%9" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%M0466/22%9" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0466/22</b> - RAMP 1 VORTAC GROUND RECEIVER CHECKPOINT RADIAL AND DISTANCE
  INCORRECT; SHOULD READ BRG - 231, DIST - 8.9 NM. 17 MAY 16:51 2022 UNTIL 12
 AUG 23:59 2022. CREATED: 17 MAY 16:51 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%M0465/22%10" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%M0465/22%10" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>M0465/22</b> - TWY ALPHA VORTAC GROUND RECEIVER CHECKPOINT UNUSABLE. 17 MAY 16:49 2022 UNTIL
 12 AUG 23:59 2022. CREATED: 17 MAY 16:48 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%X0277/22%11" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%X0277/22%11" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>X0277/22</b> - DUE TO POTENTIAL 5G INTERFERENCE, RADIO ALTIMETER MAY BE
  UNUSABLE. REFER TO 5G &,150; RADIO ALTIMETER TAB ON DAIP FOR MORE
  INFORMATION AND REPORTING INSTRUCTIONS. 13 JUL 16:34 2022 UNTIL 11 OCT 05:00
 2022. CREATED: 13 JUL 16:34 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%07/006%12" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%07/006%12" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/006</b> - AIRSPACE UAS WI AN AREA DEFINED AS 2.5NM RADIUS OF 350038N1172049W EDW07519.7
 (23.8NM N VCV) SFC-500FT AGL SAT SUN 0500-0300. 30 JUL 05:00 2022 UNTIL 08 AUG
 03:00 2022. CREATED: 26 JUL 16:47 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KEDW%1/9598%13" id="KEDW">
                                                 <input type=hidden name="saveall" value="KEDW%1/9598%13" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 1/9598</b> - IAP U.S. DOD EDWARDS AFB, EDWARDS, CA.
 ILS OR LOC/DME RWY 23L, AMDT 2...
 DISREGARD NOTE: ILS OR LOC/DME RWY 23L, AMDT 2...
 VGSI AND ILS GLIDEPATH NOT COINCIDENT (VGSI ANGLE 3.00/TCH 49).
 CURRENT VGSI ANGLE IS COINCIDENT AT 2.50/TCH 51.0. 03 MAY 20:18 2021 UNTIL 03
 MAY 20:18 2023 ESTIMATED. CREATED: 03 MAY 20:19 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                                     <TABLE>
                                         <TR valign="top">

                                             <TD height="25" class="textBlack12"><B><I>The following ICAOs
                                             share facilities with KEDW: </I></B></TD>
                                         </TR>

                                     </TABLE>
                                     
                                         <TABLE>
                                             <tr>
                                                 <TD nowrap class="textBlack12Bu"><A
                                                     name="K9L2"></A>
                                                 K9L2&nbsp;&nbsp;
                                                 EDWARDS AF AUX NORTH BASE </TD>
                                             </TR>
                                             
                                             <tr>
                                                 <td colspan="2" height="15" valign="bottom"><input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All K9L2"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.K9L2, K9L2 ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All K9L2"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.K9L2, K9L2 ); ">
                                                 
                                                 </td>
                                             </tr>
                                                 


                                         </TABLE>

                                         


                                         
                                             
                                                 <TABLE>
                                                     

                                                         <TR>

                                                             <TD width="12" class="textBlack12" valign="top"><input type="checkbox" name="notamSelect" value="K9L2%X0358/22%0" id="K9L2"></td>



                                                             <TD class="textBlack12" valign="top"><PRE><b>X0358/22</b> - DUE TO POTENTIAL 5G INTERFERENCE, RADIO ALTIMETER MAY BE
  UNUSABLE. REFER TO 5G &,150; RADIO ALTIMETER TAB ON DAIP FOR MORE
  INFORMATION AND REPORTING INSTRUCTIONS. 13 JUL 17:08 2022 UNTIL 11 OCT 05:00
 2022. CREATED: 13 JUL 17:08 2022
 </PRE>
                                                             </TD>

                                                         </TR>
                                                     

                                                 </TABLE>
                                             
                                             
                                         
                                     
                                 
                             
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KOAK">
                                          KOAK&nbsp;&nbsp; METRO OAKLAND INTL</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KOAK, KOAK)" > Check All KOAK </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KOAK, KOAK)" > UnCheck All KOAK </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KOAK"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KOAK, KOAK ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KOAK"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KOAK, KOAK ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%08/012%0" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%08/012%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>08/012</b> (A1825/22) - RWY 28R ALS U/S. 01 AUG 18:00 2022 UNTIL 01 AUG 20:00 2022. CREATED: 01 AUG 17:32
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%08/010%1" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%08/010%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>08/010</b> (A1816/22) - TWY W5 CLSD. 01 AUG 16:01 2022 UNTIL 01 AUG 22:00 2022. CREATED: 01 AUG 16:01
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%07/305%2" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%07/305%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/305</b> (A1804/22) - NAV ILS RWY 30 CAT II/III NA. 01 AUG 14:00 2022 UNTIL 02 SEP 23:00 2022. CREATED:
 31 JUL 18:57 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%07/303%3" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%07/303%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/303</b> (A1805/22) - AD AP RVR ALL U/S. 01 AUG 14:00 2022 UNTIL 02 SEP 23:00 2022. CREATED: 31 JUL
 18:54 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%07/281%4" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%07/281%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/281</b> (A1788/22) - SVC TAR/SSR U/S. 03 AUG 15:00 2022 UNTIL 03 AUG 21:00 2022. CREATED: 28 JUL 20:08
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%07/106%5" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%07/106%5" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/106</b> (A1647/22) - RWY 30 SEQUENCED FLG LGT U/S. 11 JUL 21:12 2022 UNTIL 15 AUG 23:59 2022 ESTIMATED.
 CREATED: 11 JUL 21:12 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%06/357%6" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%06/357%6" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>06/357</b> (A1539/22) - OBST CRANE (ASN 2022-AWP-11740-OE) 374555N1221220W (2NM NE OAK) 182FT (165FT
 AGL) LGTD AND FLAGGED. 01 JUL 13:00 2022 UNTIL 01 AUG 23:59 2022. CREATED: 29
 JUN 18:29 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%06/126%7" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%06/126%7" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>06/126</b> - OBST TOWER LGT (ASR 1045042) 374334.10N1221348.00W (0.5NM NW OAK) 139.1FT (126.0FT
 AGL) U/S. 08 JUN 23:47 2022 UNTIL 08 SEP 23:59 2022. CREATED: 08 JUN 23:47 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%01/127%8" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%01/127%8" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>01/127</b> (A0086/22) - AD AP RDO ALTIMETER UNREL. AUTOLAND, HUD TO TOUCHDOWN, ENHANCED FLT VISION SYSTEMS
 TO TOUCHDOWN, HEL OPS REQUIRING RDO ALTIMETER DATA TO INCLUDE HOVER AUTOPILOT
 MODES AND CAT A/B/PERFORMANCE CLASS TKOF AND LDG NOT AUTHORIZED EXC FOR ACFT
 USING APPROVED ALTERNATIVE METHODS OF COMPLIANCE DUE TO 5G C-BAND INTERFERENCE
 PLUS SEE AIRWORTHINESS DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:01 2022 UNTIL
 19 JAN 05:01 2024. CREATED: 13 JAN 07:59 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%09/045%9" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%09/045%9" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>09/045</b> - OBST TOWER LGT (ASN 2021-AWP-13624-OE) 374321.5N1221138.9W (1.8NM E OAK) 60FT
 (49FT AGL) U/S. 03 SEP 21:28 2021 UNTIL 31 DEC 23:59 2022. CREATED: 03 SEP 21:28
 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/1847%10" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/1847%10" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1847</b> (A1821/22) - IAP METRO OAKLAND INTL, OAKLAND, CA.
 RNAV (GPS) RWY 10R, AMDT 2...
 LNAV MDA 500/HAT 491 ALL CATS. VDP AT 0.89 MILES TO CAXIN.
 TEMPORARY CRANE 190 MSL 3983FT SW OF RWY 10R (2021-AWP-18824-OE). 02 AUG 14:00
 2022 UNTIL 17 AUG 14:00 2022 ESTIMATED. CREATED: 01 AUG 16:38 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/1846%11" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/1846%11" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1846</b> (A1822/22) - IAP METRO OAKLAND INTL, OAKLAND, CA.
 RNAV (GPS) Y RWY 12, AMDT 3A...
 LNAV/VNAV DA 401/HAT 392 ALL CATS, VISIBILITY ALL CATS RVR 4000.
 LNAV MDA 500/HAT 491 ALL CATS, VISIBILITY CAT C/D RVR 5000. VDP AT
 1.02NM TO RW12. TEMPORARY CRANE 190 MSL 1670FT NE OF RWY 12
 (2021-AWP-18824-OE). 02 AUG 14:00 2022 UNTIL 17 AUG 14:00 2022 ESTIMATED. CREATED:
 01 AUG 16:37 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/1845%12" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/1845%12" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1845</b> (A1820/22) - IAP METRO OAKLAND INTL, OAKLAND, CA.
 RNAV (RNP) Z RWY 12, AMDT 2...
 RNP 0.15 DA 360/HAT 351 ALL CATS, VISIBILITY ALL CATS RVR 3000.
 TEMPORARY CRANE 190 MSL 1670FT NE OF RWY 12 (2021-AWP-18824-OE). 02 AUG 14:00
 2022 UNTIL 17 AUG 14:00 2022 ESTIMATED. CREATED: 01 AUG 16:37 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/1545%13" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/1545%13" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1545</b> (A1806/22) - SID METRO OAKLAND INTL, OAKLAND, CA.
 SALAD FIVE DEPARTURE...
 DEPARTURE PROCEDURE DME REQUIRED EXCEPT FOR ACFT EQUIPPED WITH
 SUITABLE RNAV SYSTEM WITH GPS,
 SAC VORTAC OUT OF SERVICE. 02 AUG 14:30 2022 UNTIL 09 AUG 06:46 2022 ESTIMATED.
 CREATED: 01 AUG 06:47 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/0452%14" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/0452%14" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/0452</b> (A1784/22) - ODP METRO OAKLAND INTL, OAKLAND, CA.
 TAKEOFF MINIMUMS AND (OBSTACLE) DEPARTURE PROCEDURES AMDT 7...
 ADD TAKEOFF OBSTACLE NOTES: RWY 30, CONST EQUIP BEGINNING 266FT
 FROM DER, 531FT RIGHT OF CENTERLINE, UP TO 48FT AGL/58FT MSL
 (2020-AWP-2531/2532/2533/2534/2535/2536/2539/2540/2541/2542/2543-NR
 A). CONST EQUIP BEGINNING 201FT FROM DER, 493FT LEFT OF CENTERLINE,
 UP TO 36FT AGL/50FT MSL
 (2020-AWP-2466/2467/2468/2469/2470/2473/2474/2476-NRA). ALL OTHER
 DATA REMAINS AS PUBLISHED. 28 JUL 17:51 2022 UNTIL 28 SEP 17:51 2022 ESTIMATED.
 CREATED: 28 JUL 17:51 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/0450%15" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/0450%15" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/0450</b> (A1783/22) - ODP METRO OAKLAND INTL, OAKLAND, CA.
 TAKEOFF MINIMUMS AND (OBSTACLE) DEPARTURE PROCEDURES AMDT 7...
 ADD TAKEOFF OBSTACLE NOTES: RWY 30, CONST EQUIP BEGINNING 406FT
 FROM DER, 423FT RIGHT OF CENTERLINE, UP TO 36FT AGL/48FT MSL
 (2020-AWP-2488/2489/2490/2491/2492/2537/2538-NRA). CONST EQUIP
 BEGINNING 458FT FROM DER, 457FT LEFT OF CENTERLINE, UP TO 36FT
 AGL/48FT MSL (2020-AWP-2475/2483/2484/2498-NRA). CONST EQUIP
 BEGINNING 498FT FROM DER, LEFT AND RIGHT OF CENTERLINE, UP TO 36FT
 AGL/48FT MSL
 (2020-AWP-2479/2480/2481/2485/2486/2487/2493/2494/2495/2496/2497-NR
 A). EXCEPT WHEN ADVISED BY ATCT THAT AREA IS CLEAR . ALL OTHER DATA
 REMAINS AS PUBLISHED. 28 JUL 17:51 2022 UNTIL 28 SEP 17:51 2022 ESTIMATED. CREATED:
 28 JUL 17:51 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/0171%16" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/0171%16" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/0171</b> (A1777/22) - SID METROPOLITAN OAKLAND INTL,
 OAKLAND, CA.
 SKYLINE ONE DEPARTURE...
 PANOCHE TRANSITION NA EXCEPT FOR AIRCRAFT EQUIPPED WITH SUITABLE
 RNAV SYSTEM WITH GPS,
 PXN VORTAC OUT OF SERVICE. 28 JUL 11:20 2022 UNTIL 28 AUG 11:20 2022 ESTIMATED.
 CREATED: 28 JUL 11:21 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/4552%17" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/4552%17" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/4552</b> (A1700/22) - SID METRO OAKLAND INTL, OAKLAND, CA.
 COAST NINE DEPARTURE...
 SANTA CATALINA TRANSITION NA EXCEPT FOR ACFT EQUIPPED WITH SUITABLE
 RNAV SYSTEM WITH GPS,
 SXC VORTAC OUT OF SERVICE. 18 JUL 16:05 2022 UNTIL 19 OCT 16:05 2022 ESTIMATED.
 CREATED: 18 JUL 16:06 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/9128%18" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/9128%18" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/9128</b> (A1619/22) - IAP METRO OAKLAND INTL, OAKLAND, CA.
 RNAV (GPS) Y RWY 30, AMDT 5D...
 LNAV/VNAV DA 330/HAT 321 ALL CATS.
 TEMPORARY CRANE 180 MSL 3888FT N OF RWY 30 (2020-AWP-22-NRA). 08 JUL 13:11 2022
 UNTIL 08 OCT 13:11 2022 ESTIMATED. CREATED: 08 JUL 13:11 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/9127%19" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/9127%19" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/9127</b> (A1618/22) - IAP METRO OAKLAND INTL, OAKLAND, CA.
 RNAV (RNP) Z RWY 30, AMDT 3B...
 RNP 0.11 DA 306/HAT 297 ALL CATS.
 RNP 0.30 DA 350/HAT 341 ALL CATS, VISIBILITY ALL CATS RVR 3000.
 TEMPORARY CRANE 180 MSL 3888FT N OF RWY 30 (2020-AWP-22-NRA). 08 JUL 13:11 2022
 UNTIL 08 OCT 13:11 2022 ESTIMATED. CREATED: 08 JUL 13:11 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/9464%20" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/9464%20" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/9464</b> (A0966/22) - IAP METRO OAKLAND INTL, OAKLAND, CA.
 RNAV (RNP) Z RWY 28R, AMDT 2...
 RNP 0.11 DA 395/HAT 388 ALL CATS, VISIBILITY ALL CATS RVR 3500. RNP
 0.30 DA 439/HAT 432 ALL CATS. 05 MAY 12:15 2022 UNTIL 05 MAY 12:15 2024 ESTIMATED.
 CREATED: 05 MAY 12:17 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/9462%21" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/9462%21" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/9462</b> (A0965/22) - IAP METRO OAKLAND INTL, OAKLAND, CA.
 RNAV (RNP) Z RWY 28L, AMDT 2...
 RNP 0.15 DA 405/HAT 396 ALL CATS, VISIBILITY ALL CATS RVR 6000. RNP
 0.30 DA 442/HAT 433 ALL CATS. 05 MAY 12:15 2022 UNTIL 05 MAY 12:15 2024 ESTIMATED.
 CREATED: 05 MAY 12:17 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/8029%22" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/8029%22" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/8029</b> (A0712/22) - SID METRO OAKLAND INTL, OAKLAND, CA.
 SILENT TWO DEPARTURE...
 TAKE-OFF MINIMUMS: RWY 28R NA - ATC. 14 APR 12:56 2022 UNTIL 24 NOV 12:55 2022
 ESTIMATED. CREATED: 14 APR 12:58 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KOAK%2/3737%23" id="KOAK">
                                                 <input type=hidden name="saveall" value="KOAK%2/3737%23" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/3737</b> (A0082/22) - IAP METRO OAKLAND INTL, OAKLAND, CA.
 ILS RWY 12 (SA CAT I), AMDT 8B ...
 ILS RWY 30 (SA CAT I), AMDT 31 ...
 ILS RWY 30 (CAT II - III), AMDT 31 ...
 PROCEDURE NA EXC FOR ACFT USING APPROVED ALTERNATIVE METHODS OF
 COMPLIANCE DUE TO 5G C-BAND INTERFERENCE PLUS SEE AIRWORTHINESS
 DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:00 2022 UNTIL 19 JAN 05:03 2024
 ESTIMATED. CREATED: 13 JAN 05:04 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                             
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KLAS">
                                          KLAS&nbsp;&nbsp; HARRY REID INTL</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KLAS, KLAS)" > Check All KLAS </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KLAS, KLAS)" > UnCheck All KLAS </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KLAS"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KLAS, KLAS ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KLAS"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KLAS, KLAS ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%08/003%0" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%08/003%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>08/003</b> - COM REMOTE TRANS/REC 123.825 U/S. 01 AUG 14:03 2022 UNTIL 05 AUG 20:00 2022 ESTIMATED.
 CREATED: 01 AUG 14:04 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%08/002%1" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%08/002%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>08/002</b> (A1535/22) - NAV VORTAC U/S. 02 AUG 16:00 2022 UNTIL 02 AUG 22:00 2022. CREATED: 01 AUG 13:56
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%08/001%2" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%08/001%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>08/001</b> - OBST BLDG (ASN UNKNOWN) 360436N1150708W (0.33NM E APCH END RWY 26R)
  2047FT (15FT AGL) NOT LGTD. 01 AUG 03:16 2022 UNTIL 11 AUG 20:00 2022. CREATED:
 01 AUG 03:16 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/187%3" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/187%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/187</b> (A1512/22) - TWY F BTN TWY S AND TWY T CLSD. 02 AUG 11:00 2022 UNTIL 02 AUG 15:00 2022. CREATED:
 31 JUL 13:19 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/186%4" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/186%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/186</b> (A1511/22) - TWY A6 BTN TWY A AND TWY B CLSD. 02 AUG 11:00 2022 UNTIL 02 AUG 15:00 2022. CREATED:
 31 JUL 13:17 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/185%5" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/185%5" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/185</b> (A1510/22) - TWY A5 BTN TWY A AND TWY B CLSD. 02 AUG 11:00 2022 UNTIL 02 AUG 15:00 2022. CREATED:
 31 JUL 13:16 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/184%6" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/184%6" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/184</b> (A1509/22) - RWY 08L/26R CLSD. 02 AUG 11:00 2022 UNTIL 02 AUG 15:00 2022. CREATED: 31 JUL
 13:14 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/183%7" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/183%7" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/183</b> (A1508/22) - RWY 01R/19L CLSD. 02 AUG 07:30 2022 UNTIL 02 AUG 11:00 2022. CREATED: 31 JUL
 13:12 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/181%8" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/181%8" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/181</b> - OBST POLE (ASN UNKNOWN) 360456N1150744W (0.39NM NNW APCH END RWY 26R)
  2090FT (50FT AGL) NOT LGTD. 31 JUL 03:40 2022 UNTIL 11 AUG 20:00 2022. CREATED:
 31 JUL 03:40 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/180%9" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/180%9" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/180</b> - OBST POLE (ASN UNKNOWN) 360448N1150744W (0.27NM NW APCH END RWY 26R)
  2090FT (50FT AGL) NOT LGTD. 31 JUL 03:39 2022 UNTIL 11 AUG 20:00 2022. CREATED:
 31 JUL 03:39 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/169%10" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/169%10" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/169</b> (A1483/22) - TWY F BTN TWY N AND TWY T CLSD. 01 AUG 11:00 2022 UNTIL 01 AUG 19:00 2022. CREATED:
 30 JUL 04:25 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/168%11" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/168%11" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/168</b> (A1482/22) - TWY S BTN RWY 01L/19R AND TWY F CLSD. 01 AUG 11:00 2022 UNTIL 01 AUG 19:00 2022.
 CREATED: 30 JUL 04:24 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/167%12" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/167%12" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/167</b> - OBST POLE (ASN UNKNOWN) 360448N1150909W (0.55NM ENE APCH END RWY 08L)
 UNKNOWN (30FT AGL) NOT LGTD. 30 JUL 02:26 2022 UNTIL 26 AUG 19:00 2022. CREATED:
 30 JUL 02:27 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/163%13" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/163%13" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/163</b> (A1480/22) - RWY 08R PAPI U/S. 29 JUL 12:43 2022 UNTIL 10 AUG 20:00 2022 ESTIMATED. CREATED:
 29 JUL 12:43 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/155%14" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/155%14" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/155</b> (A1472/22) - OBST CRANE (ASN UNKNOWN) 360421N1150436W (2.5NM E APCH END RWY 26L)
 UNKNOWN (195FT AGL) FLAGGED. 01 AUG 15:00 2022 UNTIL 01 AUG 19:00 2022. CREATED:
 28 JUL 18:26 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/154%15" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/154%15" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/154</b> (A1471/22) - OBST CRANE (ASN UNKNOWN) 360547N1150948W (.45NM W APCH END RWY 19R)
 UNKNOWN (50FT AGL) FLAGGED. 02 AUG 13:30 2022 UNTIL 02 AUG 15:00 2022. CREATED:
 28 JUL 18:18 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/153%16" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/153%16" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/153</b> - OBST RIG (ASN UNKNOWN) 360607N1150851W (.2NM NE APCH END RWY 19L)
 UNKNOWN (36FT AGL) FLAGGED DLY 1400-0015. 01 AUG 14:00 2022 UNTIL 06 AUG 00:15
 2022. CREATED: 28 JUL 16:48 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/092%17" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/092%17" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/092</b> (A1463/22) - BLD&nbsp;NAV VORTAC U/S. 01 AUG 16:00 2022 UNTIL 01 AUG 22:00 2022. CREATED: 28 JUL 04:01
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/119%18" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/119%18" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/119</b> - OBST TOWER LGT (ASR 1212507) 360404.00N1151212.10W (2.6NM WSW LAS) 2417.0FT (89.9FT
 AGL) U/S. 22 JUL 05:21 2022 UNTIL 06 AUG 04:21 2022. CREATED: 22 JUL 05:20 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/080%19" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/080%19" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/080</b> - TWY D TWY DIRECTION SIGN NORTH SIDE BTN TWY N AND TWY M OBSC. 18 JUL 12:45 2022
 UNTIL 31 AUG 19:00 2022. CREATED: 18 JUL 12:45 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/030%20" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/030%20" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/030</b> - OBST TOWER LGT (ASR 1284798) 360440.60N1151148.60W (2.2NM W LAS) 2357.9FT (80.1FT
 AGL) U/S. 10 JUL 07:16 2022 UNTIL 24 AUG 07:15 2022. CREATED: 10 JUL 07:16 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%06/020%21" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%06/020%21" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>06/020</b> - OBST TOWER LGT (ASR 1218187) 360416.80N1150715.20W (1.6NM ESE LAS) 2086.0FT (55.1FT
 AGL) U/S. 03 JUN 21:38 2022 UNTIL 02 SEP 04:00 2022. CREATED: 03 JUN 21:38 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%01/055%22" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%01/055%22" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>01/055</b> (A0088/22) - AD AP RDO ALTIMETER UNREL. AUTOLAND, HUD TO TOUCHDOWN, ENHANCED FLT VISION SYSTEMS
 TO TOUCHDOWN, HEL OPS REQUIRING RDO ALTIMETER DATA TO INCLUDE HOVER AUTOPILOT
 MODES AND CAT A/B/PERFORMANCE CLASS TKOF AND LDG NOT AUTHORIZED EXC FOR ACFT
 USING APPROVED ALTERNATIVE METHODS OF COMPLIANCE DUE TO 5G C-BAND INTERFERENCE
 PLUS SEE AIRWORTHINESS DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:01 2022 UNTIL
 19 JAN 05:01 2024. CREATED: 13 JAN 07:39 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%07/058%23" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%07/058%23" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/058</b> - OBST SILO (ASN 2021-AWP-1653-NRA) 360546N1150904W (1.0NM NE LAS) 2152FT (80FT
 AGL) LGTD. 09 JUL 16:46 2021 UNTIL 13 NOV 22:00 2022. CREATED: 09 JUL 16:46 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1539%24" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1539%24" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1539</b> (A1533/22) - SID HARRY REID INTL, LAS VEGAS, NV.
 MCCARRAN SIX DEPARTURE...
 DEPARTURE PROCEDURE TAKE-OFF RUNWAYS 26L/R NA EXCEPT FOR ACFT
 EQUIPPED WITH SUITABLE RNAV SYSTEM WITH GPS,
 LAS VORTAC OUT OF SERVICE. 02 AUG 15:00 2022 UNTIL 09 AUG 06:23 2022 ESTIMATED.
 CREATED: 01 AUG 06:24 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1537%25" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1537%25" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1537</b> (A1532/22) - SID HARRY REID INTL, LAS VEGAS, NV.
 HOOVER SEVEN DEPARTURE...
 DEPARTURE PROCEDURE TAKE-OFF RUNWAYS 26L/R NA EXCEPT FOR ACFT
 EQUIPPED WITH SUITABLE RNAV SYSTEM WITH GPS.
 DOVE CREEK TRANSITION NA EXCEPT FOR ACFT EQUIPPED WITH SUITABLE
 RNAV SYSTEM WITH GPS,
 LAS VORTAC OUT OF SERVICE. 02 AUG 15:00 2022 UNTIL 09 AUG 06:23 2022 ESTIMATED.
 CREATED: 01 AUG 06:24 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1466%26" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1466%26" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1466</b> (A1525/22) - SID HARRY REID INTL, LAS VEGAS, NV.
 MCCARRAN SIX DEPARTURE...
 LOST COMMUNICATIONS PROCEDURE: NA EXCEPT FOR AIRCRAFT EQUIPPED WITH
 SUITABLE RNAV SYSTEM WITH GPS. HECTOR TRANSITION: NA EXCEPT FOR
 AIRCRAFT EQUIPPED WITH SUITABLE RNAV SYSTEM WITH GPS,
 BLD VOR OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 21:56 2022 ESTIMATED.
 CREATED: 31 JUL 21:57 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1465%27" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1465%27" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1465</b> (A1524/22) - SID HARRY REID INTL, LAS VEGAS, NV.
 HOOVER SEVEN DEPARTURE...
 LOST COMMUNICATIONS PROCEDURE: NA EXCEPT FOR AIRCRAFT EQUIPPED WITH
 SUITABLE RNAV SYSTEM WITH GPS,
 BLD VOR OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 21:56 2022 ESTIMATED.
 CREATED: 31 JUL 21:57 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1464%28" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1464%28" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1464</b> (A1523/22) - IAP HARRY REID INTL, LAS VEGAS, NV.
 VOR RWY 26L/R, AMDT 4A...
 VOR/DME-A, ORIG-E...
 PROCEDURE NA EXCEPT FOR ACFT EQUIPPED WITH SUITABLE RNAV SYSTEM
 WITH GPS,
 BLD VOR OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 21:56 2022 ESTIMATED.
 CREATED: 31 JUL 21:57 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1458%29" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1458%29" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1458</b> (A1522/22) - IAP HARRY REID INTL, LAS VEGAS, NV.
 ILS OR LOC RWY 26R, AMDT 20...
 MISSED APPROACH: CLIMB TO 3200 THEN CLIMBING RIGHT TURN TO 7000 ON
 HEADING 083 AND LAS R-066 TO LAPIN INT AND HOLD, CONTINUE
 CLIMB-IN-HOLD TO 7000,
 BLD VOR OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 21:56 2022 ESTIMATED.
 CREATED: 31 JUL 21:57 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1449%30" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1449%30" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1449</b> (A1521/22) - IAP HARRY REID INTL, LAS VEGAS, NV.
 ILS OR LOC RWY 26L, AMDT 7...
 MISSED APPROACH: CLIMB TO 3100 THEN CLIMBING RIGHT TURN TO 7000 ON
 HEADING 083 AND LAS R-066 TO LAPIN INT AND HOLD, CONTINUE
 CLIMB-IN-HOLD TO 7000,
 BLD VOR OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 21:56 2022 ESTIMATED.
 CREATED: 31 JUL 21:57 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1448%31" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1448%31" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1448</b> (A1520/22) - IAP HARRY REID INTL, LAS VEGAS, NV.
 ILS OR LOC RWY 1L, AMDT 3...
 PROCEDURE NA EXCEPT FOR ACFT EQUIPPED WITH SUITABLE RNAV SYSTEM
 WITH GPS,
 BLD VOR OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 21:56 2022 ESTIMATED.
 CREATED: 31 JUL 21:57 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1447%32" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1447%32" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1447</b> (A1519/22) - ODP HARRY REID INTL, LAS VEGAS, NV.
 TAKEOFF MINIMUMS AND (OBSTACLE) DEPARTURE PROCEDURES AMDT 8...
 DEPARTURE PROCEDURE: NA EXCEPT FOR AIRCRAFT EQUIPPED WITH SUITABLE
 RNAV SYSTEM WITH GPS,
 BLD VOR OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 21:56 2022 ESTIMATED.
 CREATED: 31 JUL 21:57 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1371%33" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1371%33" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1371</b> (A1506/22) - SID HARRY REID INTL, LAS VEGAS, NV.
 RATPK THREE DEPARTURE (RNAV)...
 DEPARTURE PROCEDURE GPS REQUIRED,
 BLD VORTAC OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 06:24 2022 ESTIMATED.
 CREATED: 31 JUL 06:25 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1370%34" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1370%34" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1370</b> (A1505/22) - SID HARRY REID INTL, LAS VEGAS, NV.
 MCCARRAN SIX DEPARTURE...
 DEPARTURE PROCEDURE LOST COMMUNICATIONS NA EXCEPT FOR ACFT EQUIPPED
 WITH SUITABLE RNAV SYSTEM WITH GPS.
 HECTOR TRANSITION NA EXCEPT FOR ACFT EQUIPPED WITH SUITABLE RNAV
 SYSTEM WITH GPS,
 BLD VORTAC OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 06:24 2022 ESTIMATED.
 CREATED: 31 JUL 06:25 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1369%35" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1369%35" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1369</b> (A1504/22) - IAP HARRY REID INTL, LAS VEGAS, NV.
 ILS OR LOC RWY 1L, AMDT 3...
 VOR RWY 26L/R, AMDT 4A...
 VOR/DME-A, ORIG-E...
 PROCEDURE NA EXCEPT FOR ACFT EQUIPPED WITH SUITABLE RNAV SYSTEM
 WITH GPS,
 BLD VORTAC OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 06:24 2022 ESTIMATED.
 CREATED: 31 JUL 06:25 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1368%36" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1368%36" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1368</b> (A1503/22) - IAP HARRY REID INTL, LAS VEGAS, NV.
 ILS OR LOC RWY 26L, AMDT 7...
 MISSED APPROACH: CLIMB TO 3100 THEN CLIMBING RIGHT TURN TO 7000 ON
 HEADING 083 AND LAS R-066 TO LAPIN INT AND HOLD, CONTINUE
 CLIMB-IN-HOLD TO 7000,
 BLD VORTAC OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 06:24 2022 ESTIMATED.
 CREATED: 31 JUL 06:25 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1367%37" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1367%37" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1367</b> (A1502/22) - IAP HARRY REID INTL, LAS VEGAS, NV.
 ILS OR LOC RWY 26R, AMDT 20...
 MISSED APPROACH: CLIMB TO 3200 THEN CLIMBING RIGHT TURN TO 7000 ON
 HEADING 083 AND LAS R-066 TO LAPIN INT AND HOLD, CONTINUE
 CLIMB-IN-HOLD TO 7000,
 BLD VORTAC OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 06:24 2022 ESTIMATED.
 CREATED: 31 JUL 06:25 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1364%38" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1364%38" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1364</b> (A1501/22) - SID HARRY REID INTL, LAS VEGAS, NV.
 HOOVER SEVEN DEPARTURE...
 DEPARTURE PROCEDURE LOST COMMUNICATIONS NA EXCEPT FOR ACFT EQUIPPED
 WITH SUITABLE RNAV SYSTEM WITH GPS.
 BAVPE TRANSITION NA EXCEPT FOR ACFT EQUIPPED WITH SUITABLE RNAV
 SYSTEM WITH GPS,
 BLD VORTAC OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 06:24 2022 ESTIMATED.
 CREATED: 31 JUL 06:25 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1363%39" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1363%39" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1363</b> (A1500/22) - ODP HARRY REID INTL, LAS VEGAS, NV.
 TAKEOFF MINIMUMS AND (OBSTACLE) DEPARTURE PROCEDURES AMDT 8...
 DEPARTURE PROCEDURE NA EXCEPT FOR ACFT EQUIPPED WITH SUITABLE RNAV
 SYSTEM WITH GPS,
 BLD VORTAC OUT OF SERVICE. 01 AUG 16:00 2022 UNTIL 08 AUG 06:24 2022 ESTIMATED.
 CREATED: 31 JUL 06:25 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/3065%40" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/3065%40" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/3065</b> (A1346/22) - STAR HENRY REID INTL, LAS VEGAS, NV RNDRZ TWO
 ARRIVAL (RNAV) CHANGE MISEN ALT TO READ: AT OR ABOVE FL240. 14 JUL 17:48 2022
 UNTIL 12 JUL 23:59 2023. CREATED: 14 JUL 18:46 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/4566%41" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/4566%41" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/4566</b> (A0939/22) - IAP HARRY REID INTL, LAS VEGAS, NV.
 RNAV (GPS) Y RWY 19L, AMDT 3...
 LNAV/VNAV DA 2764/HAT 652 ALL CATS, VISIBILITY ALL CATS 1 3/4.
 TEMPORARY CRANES 2647 MSL BEGINNING 1.48NM NW OF RWY 19L
 (2019-AWP-9923/9924/9925/9926-OE), TEMPORARY CRANE 2664 MSL 5948FT
 NW OF RWY 19L (2022-AWP-1101-OE). 16 MAY 14:32 2022 UNTIL 26 DEC 14:32 2022
 ESTIMATED. CREATED: 16 MAY 14:32 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/4565%42" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/4565%42" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/4565</b> (A0938/22) - IAP HARRY REID INTL, LAS VEGAS, NV.
 RNAV (GPS) Y RWY 19R, AMDT 3A...
 LNAV/VNAV DA 2853/HAT 736 ALL CATS, VISIBILITY ALL CATS 2.
 TEMPORARY CRANES 2647 MSL BEGINNING 1.38NM N OF RWY 19R
 (2019-AWP-9923/9924/9925/9926-OE). 16 MAY 14:32 2022 UNTIL 26 DEC 14:32 2022
 ESTIMATED. CREATED: 16 MAY 14:32 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/1517%43" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/1517%43" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/1517</b> (A0678/22) - IAP HARRY REID INTL, LAS VEGAS, NV.
 VOR RWY 26L/R, AMDT 4A...
 CIRCLING CAT B MDA 3060/HAA 879.
 THIS IS VOR RWY 26L/R, AMDT 4B. 30 MAR 20:22 2022 UNTIL PERM. CREATED: 30 MAR
 20:22 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/6431%44" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/6431%44" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/6431</b> (A0606/22) - STAR HARRY REID INTL, LAS VEGAS, NV LARKK ONE
 ARRIVAL...PROCEDURE AMEND TWENTYNINE PALMS TRANSITION: MOCA 7900 TNP
 VORTAC TO GFS VORTAC. DISREGARD MOCA 10500 GFS VORTAC TO RNDRZ. 18 MAR 16:00
 2022 UNTIL 17 MAR 23:59 2023 ESTIMATED. CREATED: 18 MAR 16:02 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/6430%45" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/6430%45" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/6430</b> (A0605/22) - STAR HARRY REID INTL, LAS VEGAS, NV BLAID ONE
 ARRIVAL PROCEDURE AMEND CHART BRYCE CANYON AND PAGE TRANSITIONS ADD
 CHOWW AT 15000 AND 250KTS. 18 MAR 16:00 2022 UNTIL 17 MAR 23:59 2023 ESTIMATED.
 CREATED: 18 MAR 16:02 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%2/3722%46" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%2/3722%46" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/3722</b> (A0085/22) - IAP HARRY REID INTL, LAS VEGAS, NV.
 RNAV (RNP) Z RWY 19L, ORIG...
 RNAV (RNP) Z RWY 19R, ORIG...
 PROCEDURE NA EXC FOR ACFT USING APPROVED ALTERNATIVE METHODS OF
 COMPLIANCE DUE TO 5G C-BAND INTERFERENCE PLUS SEE AIRWORTHINESS
 DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:00 2022 UNTIL 19 JAN 05:01 2024
 ESTIMATED. CREATED: 13 JAN 05:02 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%1/5022%47" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%1/5022%47" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 1/5022</b> (A1726/21) - SID HARRY REID INTL, LAS VEGAS, NV.
 MCCARRAN SIX DEPARTURE...
 JOHKR MRA 14000 FT AND RADYR MRA 10000 FT. CHANGE DEPARTURE ROUTE
 DESCRIPTION TO READ: TAKEOFF RWY 1L, 1R: CLIMB ON HEADING 014 TO
 2600, THEN CLIMBING LEFT TURN HEADING 200, THENCE...TAKEOFF RWY 8L,
 8R: CLIMB ON HEADING 079, THENCE... TAKEOFF RWY 19L, 19R: CLIMB ON
 HEADING 194, THENCE... TAKEOFF RWY 26L, 26R: CLIMB ON HEADING 259
 UNTIL LAS VORTAC 3.00 DME, THEN CLIMBING LEFT TURN HEADING 190,
 THENCE... FOR RADAR VECTORS TO ASSIGNED TRANSITION OR ASSIGNED
 ROUTE. MAINTAIN ATC ASSIGNED ALTITUDE. EXPECT CLEARANCE TO FILED
 ALTITUDE TWO MINUTES AFTER DEPARTURE. CHANGE TAKEOFF MINIMUMS: RWY
 1L, 1R TO TAKEOFF MINIMUMS: RWY 1L, 1R: STANDARD WITH MINIMUM CLIMB
 OF 526 FT PER NM TO 7000 AND CHANGE TAKEOFF MINIMUMS: RWY 19L, 19R,
 26L, 26R TO TAKEOFF MINIMUMS: RWY 19L, 19R, 26L, 26R: STANDARD WITH
 A MINIMUM CLIMB OF 410 FT PER NM TO 7000. 09 NOV 16:26 2021 UNTIL 09 NOV 16:26
 2024 ESTIMATED. CREATED: 09 NOV 16:28 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%1/3787%48" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%1/3787%48" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 1/3787</b> (A1284/21) - STAR HARRY REID INTERNATIONAL AIRPORT, LAS VEGAS, NV.
 CRESO FOUR ARRIVAL
 AMDT DAGGETT TRANSITION DELETE MEA 10000 DAG TO CRESO. ADD MEA 10500
 DAG TO CRESO. DELETE MEA 7000 CRESO TO BLD. ADD MEA 7500 CRESO TO
 BLD. AMDT HECTOR TRANSITION DELETE MEA 10500 HEC TO CRESO. ADD MEA
 10500 HEC TO CRESO. DELETE MEA 7000 CRESO TO BLD. ADD MEA 7500 CRESO
 TO BLD. 23 AUG 16:44 2021 UNTIL 20 AUG 23:59 2022. CREATED: 23 AUG 16:41 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KLAS%1/7745%49" id="KLAS">
                                                 <input type=hidden name="saveall" value="KLAS%1/7745%49" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 1/7745</b> (A0309/21) - SID MC CARRAN INTL, LAS VEGAS, NV.
 HOOVER SEVEN DEPARTURE ...
 TOP ALTITUDE: ASSIGNED BY ATC. DEPARTURE ROUTE DESCRIPTION:
 ...RADAR VECTORS TO TRANSITION OR ASSIGNED ROUTE. MAINTAIN ATC
 ASSIGNED ALTITUDE, EXPECT CLEARANCE TO FILED ALTITUDE TWO MINUTES
 AFTER DEPARTURE. TAKEOFF MINIMUMS RWYS 1L/R: STANDARD WITH MINIMUM
 CLIMB OF 400 FT PER NM TO 7000. TAKEOFF MINIMUMS RWYS 19L/R, 26L/R:
 STANDARD WITH MINIMUM CLIMB OF 410 FT PER NM TO 7000. NOTE:
 TURBOJET AIRCRAFT ONLY. DRAKE TRANSISTION: IGM VOR/DME TO DRK
 VORTAC MOCA 10500. 25 FEB 09:01 2021 UNTIL 25 FEB 21:37 2023 ESTIMATED. CREATED:
 24 FEB 21:38 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                             
                         
                             <TABLE>
                                 <TR>
                                     <TD colspan="2" width="1070">

                                     <HR>

                                     </TD>
                                 </TR>
                                 <TR>

                                     <TD nowrap class="textBlack12Bu" width="350" valign="top"><A
                                         name="KPDX">
                                          KPDX&nbsp;&nbsp; PORTLAND INTL</TD>
                                     
                                     
                                     <TD ALIGN="right" id="noprint"><A href="#top"><U>[Back to Top]</U></A>
                                     <br>
                                     </TD>
                                     
                                 </TR>
                             </TABLE>

                             


                             
                                 

                                     <TABLE>

                                         
                                         
                                         
                                             <tr>
                                                 <td colspan="2"><!--  keep until we are sure that the customer perfers links over buttons.
                                             <a href="javascript:icaoCheckAll(document.NotamRetrievalForm.KPDX, KPDX)" > Check All KPDX </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                 <a href="javascript:icaoUnCheckAll(document.NotamRetrievalForm.KPDX, KPDX)" > UnCheck All KPDX </a>
                                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                             </td> --> <input type="button"
                                                     style="width: 90px; font-size: 09px;" name="CheckAll"
                                                     value="Check All KPDX"
                                                     onClick="icaoCheckAll(document.NotamRetrievalForm.KPDX, KPDX ); ">
                                                 &nbsp; <input type="button"
                                                     style="width: 100px; font-size: 09px;" name="unCheckAll"
                                                     value="UnCheck All KPDX"
                                                     onClick="icaoUnCheckAll(document.NotamRetrievalForm.KPDX, KPDX ); ">
                                                 
                                         
                                                 </TD>
                                             </tr>
                                                                                         
                                         

                                         


                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%07/057%0" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%07/057%0" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/057</b> (A0944/22) - RWY 10R/28L CLSD. 03 AUG 20:00 2022 UNTIL 03 AUG 22:00 2022. CREATED: 29 JUL
 16:50 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%07/056%1" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%07/056%1" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/056</b> (A0943/22) - RWY 10L/28R CLSD. 03 AUG 16:00 2022 UNTIL 03 AUG 18:00 2022. CREATED: 29 JUL
 16:46 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%07/055%2" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%07/055%2" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/055</b> (A0942/22) - NAV ILS RWY 21 LOC/DME U/S. 29 JUL 13:32 2022 UNTIL 29 NOV 23:59 2022. CREATED:
 29 JUL 13:32 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%07/053%3" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%07/053%3" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/053</b> (A0933/22) - RWY 10R/28L CLSD. 04 AUG 07:01 2022 UNTIL 04 AUG 10:00 2022. CREATED: 28 JUL
 10:22 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%07/051%4" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%07/051%4" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>07/051</b> (A0922/22) - TWY C BTN TWY C6 AND TWY C8 CLSD TO ACFT WINGSPAN MORE THAN 200FT. 26 JUL 17:00
 2022 UNTIL 08 SEP 23:59 2022. CREATED: 26 JUL 17:00 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%06/078%5" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%06/078%5" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>06/078</b> (A0789/22) - RWY 10R/28L CLSD WED 2100-2200. 22 JUN 21:00 2022 UNTIL 02 NOV 22:00 2022. CREATED:
 22 JUN 13:12 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%06/077%6" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%06/077%6" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>06/077</b> (A0788/22) - RWY 10L/28R CLSD WED 1600-1700. 22 JUN 16:00 2022 UNTIL 02 NOV 17:00 2022. CREATED:
 22 JUN 13:10 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%06/027%7" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%06/027%7" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>06/027</b> - OBST TOWER LGT (ASR 1033054) 453642.00N1223308.00W (2.3NM NE PDX) 386.2FT (104.0FT
 AGL) U/S. 04 JUN 20:16 2022 UNTIL 22 NOV 23:59 2022. CREATED: 04 JUN 20:16 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%03/033%8" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%03/033%8" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>03/033</b> (A0364/22) - OBST CRANE (ASN 2021-ANM-700-NRA) 453539N1223616W (0.5NM NW PDX) 124FT (100FT
 AGL) FLAGGED AND LGTD. 14 MAR 14:00 2022 UNTIL 04 NOV 23:59 2022. CREATED: 13
 MAR 14:09 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%02/014%9" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%02/014%9" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>02/014</b> (A0196/22) - RWY 21 RWY END ID LGT U/S. 07 FEB 17:42 2022 UNTIL 07 FEB 23:59 2023. CREATED:
 07 FEB 17:42 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%02/013%10" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%02/013%10" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>02/013</b> (A0195/22) - RWY 21 PAPI U/S. 07 FEB 17:41 2022 UNTIL 07 FEB 23:59 2023. CREATED: 07 FEB 17:41
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%01/045%11" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%01/045%11" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>01/045</b> (A0076/22) - AD AP RDO ALTIMETER UNREL. AUTOLAND, HUD TO TOUCHDOWN, ENHANCED FLT VISION SYSTEMS
 TO TOUCHDOWN, HEL OPS REQUIRING RDO ALTIMETER DATA TO INCLUDE HOVER AUTOPILOT
 MODES AND CAT A/B/PERFORMANCE CLASS TKOF AND LDG NOT AUTHORIZED EXC FOR ACFT
 USING APPROVED ALTERNATIVE METHODS OF COMPLIANCE DUE TO 5G C-BAND INTERFERENCE
 PLUS SEE AIRWORTHINESS DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:01 2022 UNTIL
 19 JAN 05:01 2024. CREATED: 13 JAN 08:39 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%01/015%12" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%01/015%12" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>01/015</b> (A0018/22) - TWY G CLSD. 06 JAN 21:10 2022 UNTIL 01 JAN 00:01 2023. CREATED: 06 JAN 21:10
 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%10/088%13" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%10/088%13" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>10/088</b> (A1315/21) - RWY 21 CLSD TO LDG AND TKOF. 26 OCT 18:00 2021 UNTIL 20 SEP 23:59 2022. CREATED:
 26 OCT 17:42 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%10/020%14" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%10/020%14" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>10/020</b> (A1216/21) - RWY 03 CLSD TO TKOF. 06 OCT 03:14 2021 UNTIL 30 SEP 23:59 2022. CREATED: 06 OCT
 03:14 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     2022-08-01 11:36:39.762363-0700 OPS SOF[1703:34508] [UILog] Called -[UIContextMenuInteraction updateVisibleMenuWithBlock:] while no context menu is visible. This won't do anything.
         <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%10/019%15" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%10/019%15" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>10/019</b> (A1206/21) - RWY 03 DECLARED DIST: TORA 0FT TODA 0FT ASDA 0FT LDA 3000FT. 05 OCT 12:39 2021
 UNTIL 30 SEP 23:59 2022. CREATED: 05 OCT 12:39 2021
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%2/5397%16" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%2/5397%16" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/5397</b> (A0808/22) - IAP PORTLAND INTL, PORTLAND, OR.
 RNAV (GPS) Y RWY 10R, AMDT 2C...
 LNAV/VNAV DA 350/HAT 326 ALL CATS, VISIBILITY RVR 2600 ALL CATS.
 TEMPORARY CRANES UP TO 105FT AGL/139FT MSL BEGINNING 1428FT E OF
 RWY 10R (2021-ANM-1575-NRA). 28 JUN 15:13 2022 UNTIL 20 SEP 15:13 2022 ESTIMATED.
 CREATED: 28 JUN 15:13 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%2/5358%17" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%2/5358%17" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/5358</b> (A0805/22) - IAP PORTLAND INTL, PORTLAND, OR.
 RNAV (GPS) Y RWY 10L, AMDT 2C...
 LPV DA 372/HAT 342 ALL CATS. LNAV/VNAV DA 477/HAT 447 ALL CATS.
 LNAV MDA 860/HAT 830 ALL CATS. LPV VISIBILITY ALL CATS RVR 3000.
 LNAV VISIBILITY CAT C/D 1 7/8. CIRCLING CAT A/B MDA 860/HAA 829.
 VISIBILITY CAT A/B 1 1/4. FOR INOPERATIVE MALSR, INCREASE LPV
 VISIBILITY ALL CATS TO RVR 5500. TEMPORARY CRANE 236 MSL 1410FT SE
 OF RWY 10L (2021-ANM-1482-NRA). TEMPORARY CRANE 266FT MSL 2509FT
 SOUTHWEST OF RWY 10L (2021-ANM-3198-NRA). 28 JUN 15:00 2022 UNTIL 26 SEP 12:28
 2022 ESTIMATED. CREATED: 28 JUN 12:28 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%2/5357%18" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%2/5357%18" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/5357</b> (A0804/22) - IAP PORTLAND INTL, PORTLAND, OR.
 RNAV (RNP) Z RWY 10L, AMDT 1A...
 RNP 0.30 DA 465/HAT 435 ALL CATS. VISIBILITY ALL CATS RVR 4000.
 TEMPORARY CRANE 266FT MSL 2509FT SOUTHWEST OF RWY 10L
 (2021-ANM-3198-NRA). 28 JUN 15:00 2022 UNTIL 26 SEP 12:28 2022 ESTIMATED. CREATED:
 28 JUN 12:28 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%2/5356%19" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%2/5356%19" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/5356</b> (A0803/22) - IAP PORTLAND INTL, PORTLAND, OR.
 ILS OR LOC RWY 10L, AMDT 4C...
 S-ILS DA 372/HAT 342 ALL CATS. S-LOC MDA 560/HAT 530 ALL CATS.
 S-ILS VISIBILITY ALL CATS RVR 3000. S-LOC VISIBILITY CATS C/D/E RVR
 5500. FOR INOPERATIVE MALSR, INCREASE S-ILS VISIBILITY ALL CATS TO
 RVR 5500. INCREASE S-LOC CAT E VISIBILITY TO 1 1/2 SM. TEMPORARY
 CRANE 266FT MSL 2509FT SOUTHWEST OF RWY 10L (2021-ANM-3198-NRA). 28 JUN 15:00
 2022 UNTIL 26 SEP 12:28 2022 ESTIMATED. CREATED: 28 JUN 12:28 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%2/4187%20" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%2/4187%20" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/4187</b> (A0440/22) - SID PORTLAND INTL, PORTLAND, OR.
 CASCADE TWO DEPARTURE (RNAV)...
 HRMNS FIVE DEPARTURE (RNAV)...
 LAVAA SIX DEPARTURE (RNAV)...
 MINNE FIVE DEPARTURE (RNAV)...
 PORTLAND TWO DEPARTURE...
 WHAMY FOUR DEPARTURE (RNAV)...
 TAKEOFF OBSTACLE NOTES: RWY 28R, TEMPORARY CRANES, BEGINNING 3871FT
 FROM DER, 1153FT LEFT OF CENTERLINE, UP TO 105FT AGL/139FT MSL
 (2021-ANM-1575-NRA). ALL OTHER DATA REMAINS AS PUBLISHED. 06 APR 14:32 2022
 UNTIL 06 SEP 14:32 2022 ESTIMATED. CREATED: 06 APR 14:32 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%2/4183%21" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%2/4183%21" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/4183</b> (A0438/22) - ODP PORTLAND INTL, PORTLAND, OR.
 TAKEOFF MINIMUMS AND (OBSTACLE) DEPARTURE PROCEDURES AMDT 8...
 TAKEOFF OBSTACLE NOTES: RWY 28R, TEMPORARY CRANES, BEGINNING 3871FT
 FROM DER, 1153FT LEFT OF CENTERLINE, UP TO 105FT AGL/139FT MSL
 (2021-ANM-1575-NRA).
 ALL OTHER DATA REMAINS AS PUBLISHED. 06 APR 14:32 2022 UNTIL 06 SEP 14:32 2022
 ESTIMATED. CREATED: 06 APR 14:32 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%2/3725%22" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%2/3725%22" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 2/3725</b> (A0072/22) - IAP PORTLAND INTL, PORTLAND, OR.
 ILS RWY 10R (SA CAT I), AMDT 35A ...
 ILS RWY 10R (CAT II - III), AMDT 35A ...
 PROCEDURE NA EXC FOR ACFT USING APPROVED ALTERNATIVE METHODS OF
 COMPLIANCE DUE TO 5G C-BAND INTERFERENCE PLUS SEE AIRWORTHINESS
 DIRECTIVES 2021-23-12, 2021-23-13. 19 JAN 05:00 2022 UNTIL 19 JAN 05:01 2024
 ESTIMATED. CREATED: 13 JAN 05:02 2022
 </PRE></TD>

                                             </TR>
                                             
                                         

                                             <TR>

                                                 <TD width="12" class="textBlack12" valign="top">
                                                 <input type="checkbox" name="notamSelect" value="KPDX%0/9310%23" id="KPDX">
                                                 <input type=hidden name="saveall" value="KPDX%0/9310%23" />
                                                 </td>

                                                 <TD class="textBlack12" valign="top"><PRE><b>FDC 0/9310</b> (A1098/20) - IAP PORTLAND INTL, PORTLAND, OR.
 RNAV (RNP) Z RWY 10R, ORIG-B...
 RNP 0.10 DA 395/ HAT 371 ALL CATS, VISIBILITY ALL CATS RVR 3500.
 CHANGE INOP NOTE TO READ: FOR INOPERATIVE ALSF, INCREASE RNP 0.10
 ALL CATS VISIBILITY TO RVR 5500 AND 0.30 ALL CATS VISIBILITY TO 1
 3/8 SM. CRANE 119 MSL 4476FT NW OF RWY 10R (2020-ANM-2713-OE). 23 SEP 11:12
 2020 UNTIL 23 SEP 11:12 2022 ESTIMATED. CREATED: 23 SEP 11:12 2020
 </PRE></TD>

                                             </TR>
                                             
                                         

                                     </TABLE>
                                 
                                 

                                 
                             
                         
                      

                         <table>
                             <tr>
                                 <td height="4">&nbsp;</td>
                             </tr>
                             <TR>
                                 <TD class="textRed12"><TT>Number of NOTAMs: 225
                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;End of Report <br>
                                 <br>
                                 </TT></TD>
                             </TR>
                         </table>
                     
                     
                 <TR>

                     <TD bgcolor="silver"><input type="submit" name="submit" value="Display/Print Selected NOTAMs" onclick="this.form.save.value =' '; submitForm();" style="width: 162px; font-size: 10px;">
                     &nbsp;&nbsp;
                     
                     <input type="button" name="button" value="Print all NOTAMs" onclick="loadAPDImagesForPrint('print')" style="width: 115px; font-size: 09px;">
                                 &nbsp;&nbsp;
                                 <!-- <input type="submit" name="button" value="Save all NOTAMs " onclick="this.form.save.value ='saveall'; submitForm();" style="width: 115px; font-size: 09px;"> -->
                                 <input type="submit" name="button" value="Save all NOTAMs " onclick="submitForm('saveAsPDF');" style="width: 115px; font-size: 09px;">
                         
                         
                     &nbsp;&nbsp; <input style="width: 115px; font-size: 09px;"
                         type="button" onClick="checkedAll('form1', true)"
                         value="Check All NOTAMs"> &nbsp;&nbsp; <input
                         style="width: 115px; font-size: 09px;" type="button"
                         onClick="checkedAll('form1', false)" value="UnCheck All NOTAMs"></TD>
                 </TR>

             </TABLE>
 </DIV>
             
 </form>

     



 <!-- START Bottom LINKS -->
     <table width="100%" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="#5487C4" class="noprint">
       <tbody>
       <tr align="left">
        
         <td align="left"><img src="images/spacer.gif" alt="" width="20" height="15"></td>
         <td height="15" align="left" ><a href="http://www.faa.gov/privacy/" target="_blank" class="MenuBottom" title="Privacy and Website Policy"><font color="#FFFFFF">Privacy and Web site Policy</font></A></td>

         <td align="left">
 <a href="#" class="MenuBottom" title="About Defense Internet NOTAM Service" onClick="aboutWindow=window.open('../about.html','aboutWindow','toolbar=yes,location=no,directories=no,status=no,menubar=yes,scrollbars=yes,resizable=yes,width=550,height=400,left=150,top=50'); return false;"><font color="#FFFFFF">About DINS</font></a></td>

       
 <td align="left">
 <a href="#" class="MenuBottom" title="DINS Disclaimer" onClick="discWindow=window.open('../disclaim.html','discWindow','toolbar=yes,location=no,directories=no,status=no,menubar=yes,scrollbars=yes,resizable=yes,width=550,height=400,left=150,top=50'); return false;"><font color="#FFFFFF">DINS Disclaimer</font></a></td>
              
 <TD  VALIGN="top"><IMG SRC="images/spacer.gif" ALT="" TITLE="" WIDTH="200" HEIGHT="15"></TD>
  <TD  VALIGN="top"><IMG SRC="images/spacer.gif" ALT="" TITLE="" WIDTH="100" HEIGHT="15">
   </TD>
           
       </TR>
    </tbody>
   </TABLE>
     <!-- END LINKS -->
     <noscript><img src="https://www.notams.faa.gov/akam/13/pixel_74a4df61?a=dD03MWVkNjE3MzQzOTAxNzNiYmRlNDU1ZWFlYTU0OTk1NzI5NjIzYzM1JmpzPW9mZg==" style="visibility: hidden; position: absolute; left: -999px; top: -999px;" /></noscript></BODY>
 </html>
 
 */
