unit ISPermObjConst;

interface

Const
  { Registered Versions }
  CVersionLowestValue = 18000;
  CVerAug1999 = 19908; { Millinium  Year Year Month Month }
  CVerFeb2001 = 20102;
  CVerApr2001 = 20104;
  CVerJun2001 = 20106;
  CVerSep2001 = 20109;
  CVerNov2001 = 20110;
  CVerJan2002 = 20201;
  CVerJun2002 = 20206;
  CVerNov2002 = 20211;
  CVerApr2003 = 20304;
  CVerMay2003 = 20305;
  CVerJun2003 = 20306;
  CVerJul2003 = 20307;
  CVerAug2003 = 20308;
  CVerJan2004 = 20401;
  CVerFeb2004 = 20402;
  CVerMar2004 = 20403;
  CVerApr2004 = 20404;
  CVerMay2004 = 20405;
  CVerJuly22_2004 = 20416; { Millinium  Year Year Version for year (00 - 99) }
  CVerOctober22_2004 = 20417;
  CVerOctober23_2004 = 20418;
  CVerNovember17_2004 = 20419;
  CVerNovember26_2004 = 20421;
  CVerDecember4_2004 = 20423;
  CVerJanuary27_2005 = 20501;
  CVerFebruary08_2005 = 20502;
  CVerMarch30_2005 = 20503;
  CVerJun6_2005 = 20506;
  CVerJuly28_2005 = 20510;
  CVerAugust20_2005 = 20511;
  CVerNovember11_2005 = 20512;
  CVerFeb25_2006 = 20604;
  CVerMar10_2006 = 20605;
  CVerJuly13_2006 = 20606;
  CVerAugust17_2006 = 20609;
  // CTestValue_2006 = 20610;
  CVerDec31_2006 = 20612;
  CVerJan23_2007 = 20701;
  CVerFeb03_2007 = 20702;
  CVerFeb22_2007 = 20703;
  CVerFeb28_2007 = 20704;
  CVerMar12_2007 = 20705;
  CVerApr02_2007 = 20708;
  CVerJun07_2007 = 20711; // BB Config Save lastFormat
  CVerJuly01_2007 = 20713; // BB Config Save lastFormat Fix
  CVerJuly11_2007 = 20715; // BB AssManager Save Fixtures
  CVerJuly18_2007 = 20717; // Save Form details BB ISDbGen
  CVerJuly19_2007 = 20718; // Added BB Notes Memos
  CVerNov19_2007 = 20721; // Added FLastNameDataHeaders to TISConfigBaseObj
  CVerJan01_2008 = 20801;
  // Added Postal Address to TISName, Added Email Db Added Find Remote Server
  CVerFeb01_2008 = 20802; // Email Templates to PollConfig
  CVerJune10_2008 = 20803; // Remote Dlg Mods
  CVerJune25_2008 = 20807;
  // New alternate Fields to Welfare solutions User Data Load Welfare Solutions
  CVerJuly1_2008 = 20808; // Bulk Load Wrker
  CVerSeptember29_2008 = 20810; //
  CVerNovember02_2008 = 20812; // Introduced Site Accounting
  CVerDecember06_2008 = 20814; // Changes to TAnnounceIpAddressObj
  CVerFebrury04_2009 = 20902;
  // AnsiString Definition - Photoobj TFileChangeDataObj Changes
  // Mandatory
  // CVerMarch10_2009 =  20904;     //FApplicationExtensionData to address Object and Address management
  // Moved to CVerAugustManadatory_2009
  CVerAugust04_2009 = 20904; // Soft Archive of records
  // Mandatory
  CVerAugustManadatory_2009 = 20905;
  // and CVerMarch10_2009 >>>//FApplicationExtensionData to address Object and Address management
  CVerMarch_2010 = 21001; // New Visit delete Pivilage
  CVerJuly_2010 = 21004; // Load Locations with impact object
  CVerAugust_2010 = 21005; // Web Edit Application Add Db Ref
  CVerSeptEarly_2010 = 21008; // Poll Solutions config info
  CVerSept17_2010 = 21009;
  // Poll Solutions further config info Communitee Notes
  // CVerSeptEarly_2010 Set TFormElectracMain.OpenBothDbs as mandatory

  CVerOct6_2010 = 21011; // Business Phone Number Added (Mandatory)
  // CLastMandatoryVersion = CVerNovember11_2005;
  // CLastMandatoryVersion = CVerJuly1_2008;

  CVerNov8_2010 = 21013;
  // ReidPlateConfig and AppliedMomment Electrac Mandatory
  CVerJanuary2011Manadatory = 21101; // FVisits Preloaded
  CVerSept2011 = 21108; // Photo Configuration
  CVer15Sept2011 = 21109; // Photo Configuration
  CVerOctober2011 = 21111; // Comment on Payment Field ASP Hotham
  CVerNovember2011 = 21111; // Reid Moment on plate
  CVerJuly2012 = 21201; // Source List in Photo and  >>>> Photo Mandatory
  CVerAugust2012 = 21203; // ForcePixel  >>>> Photo Mandatory
  CVerOctober2012 = 21205; // FTP Application Name
  CVerJanuary2013 = 21301;
  // Poll Solutions Mandatory By Fixed in PollDbObjects initialization
  CVerApril2013 = 21302;
  // Poll Solutions Mandatory By Fixed in PollDbObjects initialization
  CVerJune2013 = 21304;
  // Poll Solutions Mandatory By Fixed in PollDbObjects initialization
  CVerJuly2013 = 21306;
  // Service Monitor Test Mandatory By Fixed in Monitortestobj initialization
  CVerSept2013Manadatory = 21309;
  // Changes to uniting Care for cleanup and printing
  CVerOctober2013 = 21310; // SoftDb Auth Details
  CVerJan2014 = 21401; // Store Remote Client Directory in File transfer
  CVerMar2014Manadatory = 21404;
  // Changes to uniting Care for Flaged contacts global last flag etc
  CVerOctober2015Manadatory = 21509;
  // Changes to uniting Care for Survey Questions

  CVerApril2017 = 21702; // ReadStrmStringArray(s, FQualSection)
  CVer01May2017 = 21703; // ReadStrmStringArray(s, FParlServiceSection);
  CVerAugust2017 = 21707;
  CVerSept2017 = 21709; // fParlSvcBlocks := ReadStrmObject(s, Self)
  CVerFeb2018 = 21800; // FKERNEL_IMAGE7_PastValues etc

  CVerJan2019 = 21900; // Added manual to MPs
  CVer2Jan2022 = 22212; //Sampling Library

{$IFNDEF DoNotUsePermObjConst}
Var
  CLastMandatoryVersion: LongWord = CVerOctober2015Manadatory;
  FStartUpMessage: String = '';
{$EndIf}
implementation

uses ISPermObjFileStm, Sysutils;

{$IFNDEF DoNotUsePermObjConst}
initialization

Try
  SetCurrentVersion(CVerJan2019, CVersionLowestValue);
Except
  On E: Exception do
  Begin
    FStartUpMessage := 'initialization Error ::' + E.message;
  End;
End;
{$EndIf}
end.
