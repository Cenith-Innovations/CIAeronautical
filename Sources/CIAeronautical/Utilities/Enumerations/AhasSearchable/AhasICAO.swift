// ********************** AhasICAO *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 1/22/21, for 
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** AhasICAO *********************************


import Foundation

public enum AhasICAO: String, AhasSearchable {
    public var description: String { return self.rawValue}
    case _12NC = "12NC"
    case _13NC = "13NC"
    case _14NC = "14NC"
    case _22XS = "22XS"
    case _23XS = "23XS"
    case _99CL = "99CL"
    case _9TX5 = "9TX5"
    case CA62 = "CA62"
    case CAU3 = "CAU3"
    case CO80 = "CO80"
    case CO90 = "CO90"
    case CYBG = "CYBG"
    case K09J = "K09J"
    case K0F2 = "K0F2"
    case K0L9 = "K0L9"
    case K11R = "K11R"
    case K12J = "K12J"
    case K1R8 = "K1R8"
    case K1V6 = "K1V6"
    case K24R = "K24R"
    case K2CB = "K2CB"
    case K3G5 = "K3G5"
    case K3MY = "K3MY"
    case K40J = "K40J"
    case K4V1 = "K4V1"
    case K5T9 = "K5T9"
    case K67L = "K67L"
    case K79J = "K79J"
    case K92F = "K92F"
    case K95E = "K95E"
    case KAAA = "KAAA"
    case KAAF = "KAAF"
    case KABE = "KABE"
    case KABI = "KABI"
    case KABR = "KABR"
    case KABY = "KABY"
    case KACK = "KACK"
    case KACT = "KACT"
    case KACY = "KACY"
    case KADM = "KADM"
    case KADW = "KADW"
    case KAEG = "KAEG"
    case KAEX = "KAEX"
    case KAFF = "KAFF"
    case KAFW = "KAFW"
    case KAGR = "KAGR"
    case KAGS = "KAGS"
    case KAHC = "KAHC"
    case KAHN = "KAHN"
    case KALB = "KALB"
    case KALI = "KALI"
    case KALN = "KALN"
    case KAMA = "KAMA"
    case KAPA = "KAPA"
    case KAPG = "KAPG"
    case KAPH = "KAPH"
    case KAPN = "KAPN"
    case KARA = "KARA"
    case KARR = "KARR"
    case KATL = "KATL"
    case KATS = "KATS"
    case KAUS = "KAUS"
    case KAVK = "KAVK"
    case KAVL = "KAVL"
    case KAVO = "KAVO"
    case KAXX = "KAXX"
    case KAYX = "KAYX"
    case KAZU = "KAZU"
    case KBAB = "KBAB"
    case KBAD = "KBAD"
    case KBAF = "KBAF"
    case KBAK = "KBAK"
    case KBAM = "KBAM"
    case KBDL = "KBDL"
    case KBEA = "KBEA"
    case KBED = "KBED"
    case KBFI = "KBFI"
    case KBFM = "KBFM"
    case KBGE = "KBGE"
    case KBGM = "KBGM"
    case KBGR = "KBGR"
    case KBHM = "KBHM"
    case KBIF = "KBIF"
    case KBIH = "KBIH"
    case KBIL = "KBIL"
    case KBIS = "KBIS"
    case KBIX = "KBIX"
    case KBJC = "KBJC"
    case KBKF = "KBKF"
    case KBKN = "KBKN"
    case KBKS = "KBKS"
    case KBKT = "KBKT"
    case KBLI = "KBLI"
    case KBLV = "KBLV"
    case KBMG = "KBMG"
    case KBMI = "KBMI"
    case KBNA = "KBNA"
    case KBOI = "KBOI"
    case KBOS = "KBOS"
    case KBPT = "KBPT"
    case KBQK = "KBQK"
    case KBRO = "KBRO"
    case KBTL = "KBTL"
    case KBTR = "KBTR"
    case KBTV = "KBTV"
    case KBVU = "KBVU"
    case KBWI = "KBWI"
    case KBYS = "KBYS"
    case KC75 = "KC75"
    case KCAE = "KCAE"
    case KCAK = "KCAK"
    case KCBM = "KCBM"
    case KCDC = "KCDC"
    case KCEF = "KCEF"
    case KCEW = "KCEW"
    case KCHA = "KCHA"
    case KCHK = "KCHK"
    case KCHS = "KCHS"
    case KCIC = "KCIC"
    case KCKA = "KCKA"
    case KCKB = "KCKB"
    case KCKP = "KCKP"
    case KCLL = "KCLL"
    case KCLT = "KCLT"
    case KCMH = "KCMH"
    case KCMY = "KCMY"
    case KCNM = "KCNM"
    case KCNW = "KCNW"
    case KCOF = "KCOF"
    case KCOS = "KCOS"
    case KCOU = "KCOU"
    case KCPS = "KCPS"
    case KCQF = "KCQF"
    case KCRP = "KCRP"
    case KCRW = "KCRW"
    case KCSM = "KCSM"
    case KCVG = "KCVG"
    case KCVN = "KCVN"
    case KCVS = "KCVS"
    case KCWF = "KCWF"
    case KCXO = "KCXO"
    case KCYS = "KCYS"
    case KCZT = "KCZT"
    case KD05 = "KD05"
    case KDAA = "KDAA"
    case KDAB = "KDAB"
    case KDAL = "KDAL"
    case KDAY = "KDAY"
    case KDEC = "KDEC"
    case KDFW = "KDFW"
    case KDHN = "KDHN"
    case KDHT = "KDHT"
    case KDLF = "KDLF"
    case KDLH = "KDLH"
    case KDMA = "KDMA"
    case KDOV = "KDOV"
    case KDPG = "KDPG"
    case KDRO = "KDRO"
    case KDRT = "KDRT"
    case KDSM = "KDSM"
    case KDUC = "KDUC"
    case KDUG = "KDUG"
    case KDVL = "KDVL"
    case KDWH = "KDWH"
    case KDYS = "KDYS"
    case KECG = "KECG"
    case KECP = "KECP"
    case KECU = "KECU"
    case KEDG = "KEDG"
    case KEDW = "KEDW"
    case KEFD = "KEFD"
    case KEGE = "KEGE"
    case KEGI = "KEGI"
    case KEKO = "KEKO"
    case KELM = "KELM"
    case KELP = "KELP"
    case KEND = "KEND"
    case KENV = "KENV"
    case KERI = "KERI"
    case KEUF = "KEUF"
    case KEUG = "KEUG"
    case KEVV = "KEVV"
    case KEVY = "KEVY"
    case KFAF = "KFAF"
    case KFAR = "KFAR"
    case KFAT = "KFAT"
    case KFBG = "KFBG"
    case KFCS = "KFCS"
    case KFCT = "KFCT"
    case KFDK = "KFDK"
    case KFEW = "KFEW"
    case KFFO = "KFFO"
    case KFHB = "KFHB"
    case KFHU = "KFHU"
    case KFLG = "KFLG"
    case KFLV = "KFLV"
    case KFLY = "KFLY"
    case KFMH = "KFMH"
    case KFMN = "KFMN"
    case KFOE = "KFOE"
    case KFOK = "KFOK"
    case KFRI = "KFRI"
    case KFSD = "KFSD"
    case KFSI = "KFSI"
    case KFSM = "KFSM"
    case KFST = "KFST"
    case KFTG = "KFTG"
    case KFTK = "KFTK"
    case KFTW = "KFTW"
    case KFWA = "KFWA"
    case KFYM = "KFYM"
    case KFYV = "KFYV"
    case KGBG = "KGBG"
    case KGCK = "KGCK"
    case KGCN = "KGCN"
    case KGEG = "KGEG"
    case KGFA = "KGFA"
    case KGFK = "KGFK"
    case KGGG = "KGGG"
    case KGJT = "KGJT"
    case KGLH = "KGLH"
    case KGNF = "KGNF"
    case KGNT = "KGNT"
    case KGNV = "KGNV"
    case KGOK = "KGOK"
    case KGON = "KGON"
    case KGOV = "KGOV"
    case KGPI = "KGPI"
    case KGPT = "KGPT"
    case KGRB = "KGRB"
    case KGRF = "KGRF"
    case KGRI = "KGRI"
    case KGRK = "KGRK"
    case KGRR = "KGRR"
    case KGSB = "KGSB"
    case KGSO = "KGSO"
    case KGSP = "KGSP"
    case KGTB = "KGTB"
    case KGTF = "KGTF"
    case KGTR = "KGTR"
    case KGUP = "KGUP"
    case KGUR = "KGUR"
    case KGUS = "KGUS"
    case KGVT = "KGVT"
    case KGXA = "KGXA"
    case KGXF = "KGXF"
    case KHBG = "KHBG"
    case KHBV = "KHBV"
    case KHDC = "KHDC"
    case KHFF = "KHFF"
    case KHGR = "KHGR"
    case KHGT = "KHGT"
    case KHIF = "KHIF"
    case KHKA = "KHKA"
    case KHLN = "KHLN"
    case KHLR = "KHLR"
    case KHMN = "KHMN"
    case KHND = "KHND"
    case KHOB = "KHOB"
    case KHOP = "KHOP"
    case KHRL = "KHRL"
    case KHRT = "KHRT"
    case KHRX = "KHRX"
    case KHSA = "KHSA"
    case KHST = "KHST"
    case KHSV = "KHSV"
    case KHTH = "KHTH"
    case KHUA = "KHUA"
    case KHUF = "KHUF"
    case KHUT = "KHUT"
    case KIAB = "KIAB"
    case KIAG = "KIAG"
    case KICT = "KICT"
    case KIDA = "KIDA"
    case KIKR = "KIKR"
    case KILG = "KILG"
    case KILM = "KILM"
    case KINS = "KINS"
    case KISO = "KISO"
    case KIWA = "KIWA"
    case KJAN = "KJAN"
    case KJAX = "KJAX"
    case KJCT = "KJCT"
    case KJKA = "KJKA"
    case KJST = "KJST"
    case KJTC = "KJTC"
    case KJWG = "KJWG"
    case KK02 = "KK02"
    case KL25 = "KL25"
    case KLAA = "KLAA"
    case KLAL = "KLAL"
    case KLAS = "KLAS"
    case KLAW = "KLAW"
    case KLBB = "KLBB"
    case KLCH = "KLCH"
    case KLCK = "KLCK"
    case KLCQ = "KLCQ"
    case KLFI = "KLFI"
    case KLFT = "KLFT"
    case KLGF = "KLGF"
    case KLHW = "KLHW"
    case KLHX = "KLHX"
    case KLIC = "KLIC"
    case KLIT = "KLIT"
    case KLMT = "KLMT"
    case KLNK = "KLNK"
    case KLNS = "KLNS"
    case KLRD = "KLRD"
    case KLRF = "KLRF"
    case KLSE = "KLSE"
    case KLSF = "KLSF"
    case KLSV = "KLSV"
    case KLTS = "KLTS"
    case KLUF = "KLUF"
    case KLVS = "KLVS"
    case KLWB = "KLWB"
    case KMAF = "KMAF"
    case KMCE = "KMCE"
    case KMCF = "KMCF"
    case KMCI = "KMCI"
    case KMCN = "KMCN"
    case KMDA = "KMDA"
    case KMDT = "KMDT"
    case KMDW = "KMDW"
    case KMEI = "KMEI"
    case KMEM = "KMEM"
    case KMER = "KMER"
    case KMFD = "KMFD"
    case KMFE = "KMFE"
    case KMFR = "KMFR"
    case KMGE = "KMGE"
    case KMGM = "KMGM"
    case KMHR = "KMHR"
    case KMHT = "KMHT"
    case KMHV = "KMHV"
    case KMIB = "KMIB"
    case KMKC = "KMKC"
    case KMKE = "KMKE"
    case KMLI = "KMLI"
    case KMLU = "KMLU"
    case KMMH = "KMMH"
    case KMMT = "KMMT"
    case KMOB = "KMOB"
    case KMOD = "KMOD"
    case KMOT = "KMOT"
    case KMQB = "KMQB"
    case KMRB = "KMRB"
    case KMRY = "KMRY"
    case KMSN = "KMSN"
    case KMSO = "KMSO"
    case KMSP = "KMSP"
    case KMSY = "KMSY"
    case KMTC = "KMTC"
    case KMTN = "KMTN"
    case KMUI = "KMUI"
    case KMUL = "KMUL"
    case KMUO = "KMUO"
    case KMVY = "KMVY"
    case KMWA = "KMWA"
    case KMWH = "KMWH"
    case KMXF = "KMXF"
    case KMYR = "KMYR"
    case KNBC = "KNBC"
    case KNBG = "KNBG"
    case KNBJ = "KNBJ"
    case KNCA = "KNCA"
    case KNDY = "KNDY"
    case KNDZ = "KNDZ"
    case KNEL = "KNEL"
    case KNEN = "KNEN"
    case KNEW = "KNEW"
    case KNFD = "KNFD"
    case KNFE = "KNFE"
    case KNFG = "KNFG"
    case KNFJ = "KNFJ"
    case KNFL = "KNFL"
    case KNFW = "KNFW"
    case KNGP = "KNGP"
    case KNGS = "KNGS"
    case KNGT = "KNGT"
    case KNGU = "KNGU"
    case KNGW = "KNGW"
    case KNHK = "KNHK"
    case KNHL = "KNHL"
    case KNHZ = "KNHZ"
    case KNID = "KNID"
    case KNIP = "KNIP"
    case KNJK = "KNJK"
    case KNJM = "KNJM"
    case KNJW = "KNJW"
    case KNKL = "KNKL"
    case KNKT = "KNKT"
    case KNKX = "KNKX"
    case KNLC = "KNLC"
    case KNMM = "KNMM"
    case KNOG = "KNOG"
    case KNOW = "KNOW"
    case KNPA = "KNPA"
    case KNQA = "KNQA"
    case KNQB = "KNQB"
    case KNQI = "KNQI"
    case KNQX = "KNQX"
    case KNRA = "KNRA"
    case KNRB = "KNRB"
    case KNRQ = "KNRQ"
    case KNSE = "KNSE"
    case KNSI = "KNSI"
    case KNTD = "KNTD"
    case KNTU = "KNTU"
    case KNUC = "KNUC"
    case KNUI = "KNUI"
    case KNUN = "KNUN"
    case KNUQ = "KNUQ"
    case KNUW = "KNUW"
    case KNVI = "KNVI"
    case KNXP = "KNXP"
    case KNXX = "KNXX"
    case KNYG = "KNYG"
    case KNYL = "KNYL"
    case KNZX = "KNZX"
    case KNZY = "KNZY"
    case KO53 = "KO53"
    case KOAJ = "KOAJ"
    case KOAK = "KOAK"
    case KOCF = "KOCF"
    case KODO = "KODO"
    case KOFF = "KOFF"
    case KOGD = "KOGD"
    case KOKC = "KOKC"
    case KOMA = "KOMA"
    case KOQU = "KOQU"
    case KORF = "KORF"
    case KORL = "KORL"
    case KOZR = "KOZR"
    case KPAE = "KPAE"
    case KPAM = "KPAM"
    case KPBI = "KPBI"
    case KPDX = "KPDX"
    case KPHF = "KPHF"
    case KPHL = "KPHL"
    case KPHX = "KPHX"
    case KPIA = "KPIA"
    case KPIB = "KPIB"
    case KPIE = "KPIE"
    case KPIH = "KPIH"
    case KPIL = "KPIL"
    case KPIT = "KPIT"
    case KPKV = "KPKV"
    case KPMD = "KPMD"
    case KPNC = "KPNC"
    case KPNS = "KPNS"
    case KPOB = "KPOB"
    case KPOE = "KPOE"
    case KPQL = "KPQL"
    case KPRB = "KPRB"
    case KPRN = "KPRN"
    case KPRO = "KPRO"
    case KPRZ = "KPRZ"
    case KPSC = "KPSC"
    case KPSM = "KPSM"
    case KPSX = "KPSX"
    case KPUB = "KPUB"
    case KPVD = "KPVD"
    case KPVJ = "KPVJ"
    case KPVW = "KPVW"
    case KPWA = "KPWA"
    case KPWM = "KPWM"
    case KRBM = "KRBM"
    case KRCA = "KRCA"
    case KRDD = "KRDD"
    case KRDG = "KRDG"
    case KRDR = "KRDR"
    case KRFD = "KRFD"
    case KRIC = "KRIC"
    case KRIV = "KRIV"
    case KRKP = "KRKP"
    case KRKS = "KRKS"
    case KRME = "KRME"
    case KRND = "KRND"
    case KRNO = "KRNO"
    case KRNT = "KRNT"
    case KROA = "KROA"
    case KROW = "KROW"
    case KRST = "KRST"
    case KRSW = "KRSW"
    case KRYM = "KRYM"
    case KRYN = "KRYN"
    case KSAC = "KSAC"
    case KSAF = "KSAF"
    case KSAT = "KSAT"
    case KSAV = "KSAV"
    case KSAW = "KSAW"
    case KSBY = "KSBY"
    case KSCH = "KSCH"
    case KSCK = "KSCK"
    case KSDF = "KSDF"
    case KSEA = "KSEA"
    case KSEM = "KSEM"
    case KSEQ = "KSEQ"
    case KSGF = "KSGF"
    case KSGH = "KSGH"
    case KSGT = "KSGT"
    case KSGU = "KSGU"
    case KSH1 = "KSH1"
    case KSHV = "KSHV"
    case KSJT = "KSJT"
    case KSKA = "KSKA"
    case KSKF = "KSKF"
    case KSLC = "KSLC"
    case KSLI = "KSLI"
    case KSLJ = "KSLJ"
    case KSLN = "KSLN"
    case KSMF = "KSMF"
    case KSNS = "KSNS"
    case KSPI = "KSPI"
    case KSPS = "KSPS"
    case KSRQ = "KSRQ"
    case KSSC = "KSSC"
    case KSSF = "KSSF"
    case KSSI = "KSSI"
    case KSSN = "KSSN"
    case KSTJ = "KSTJ"
    case KSTL = "KSTL"
    case KSUS = "KSUS"
    case KSUU = "KSUU"
    case KSUX = "KSUX"
    case KSVC = "KSVC"
    case KSVN = "KSVN"
    case KSWF = "KSWF"
    case KSWO = "KSWO"
    case KSYR = "KSYR"
    case KSZL = "KSZL"
    case KT69 = "KT69"
    case KT70 = "KT70"
    case KTAD = "KTAD"
    case KTBN = "KTBN"
    case KTCC = "KTCC"
    case KTCL = "KTCL"
    case KTCM = "KTCM"
    case KTCS = "KTCS"
    case KTFP = "KTFP"
    case KTIK = "KTIK"
    case KTIX = "KTIX"
    case KTLH = "KTLH"
    case KTNT = "KTNT"
    case KTNX = "KTNX"
    case KTOI = "KTOI"
    case KTOL = "KTOL"
    case KTOP = "KTOP"
    case KTPH = "KTPH"
    case KTTS = "KTTS"
    case KTUL = "KTUL"
    case KTUP = "KTUP"
    case KTUS = "KTUS"
    case KTVL = "KTVL"
    case KTWF = "KTWF"
    case KTXK = "KTXK"
    case KTYS = "KTYS"
    case KU30 = "KU30"
    case KUNV = "KUNV"
    case KUVA = "KUVA"
    case KVAD = "KVAD"
    case KVBG = "KVBG"
    case KVCT = "KVCT"
    case KVCV = "KVCV"
    case KVGT = "KVGT"
    case KVLD = "KVLD"
    case KVOK = "KVOK"
    case KVPS = "KVPS"
    case KVQQ = "KVQQ"
    case KVUJ = "KVUJ"
    case KW94 = "KW94"
    case KWAL = "KWAL"
    case KWDG = "KWDG"
    case KWJF = "KWJF"
    case KWMC = "KWMC"
    case KWRB = "KWRB"
    case KWRI = "KWRI"
    case KWSD = "KWSD"
    case KXMR = "KXMR"
    case KXNA = "KXNA"
    case KXNO = "KXNO"
    case KYKM = "KYKM"
    case KYNG = "KYNG"
    case KYQQ = "KYQQ"
    case KZ = "KZ"
    case KZ10 = "KZ10"
    case KZ99 = "KZ99"
    case KZER = "KZER"
    case KZZV = "KZZV"
    case MT15 = "MT15"
    case NJ24 = "NJ24"
    case NV72 = "NV72"
    case PABA = "PABA"
    case PABI = "PABI"
    case PABM = "PABM"
    case PACD = "PACD"
    case PACZ = "PACZ"
    case PADK = "PADK"
    case PADM = "PADM"
    case PAED = "PAED"
    case PAEH = "PAEH"
    case PAEI = "PAEI"
    case PAFA = "PAFA"
    case PAFB = "PAFB"
    case PAGZ = "PAGZ"
    case PAIM = "PAIM"
    case PAKK = "PAKK"
    case PAKN = "PAKN"
    case PAKO = "PAKO"
    case PALU = "PALU"
    case PANC = "PANC"
    case PAPC = "PAPC"
    case PASV = "PASV"
    case PATC = "PATC"
    case PATL = "PATL"
    case PAWT = "PAWT"
    case PHHI = "PHHI"
    case PHIK = "PHIK"
    case PHNG = "PHNG"
    case PHNP = "PHNP"
    case PHSF = "PHSF"
    case PPIZ = "PPIZ"
    case WS20 = "WS20"
    case Z = "Z"
}

