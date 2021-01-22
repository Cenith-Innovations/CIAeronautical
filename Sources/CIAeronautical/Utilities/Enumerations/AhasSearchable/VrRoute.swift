// ********************** VrRoute *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 1/22/21, for 
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** VrRoute *********************************


import Foundation

public enum VrRoute: String, AhasSearchable {
    public var description: String { return self.rawValue}
    case VR025 = "VR025"
    case VR041 = "VR041"
    case VR042 = "VR042"
    case VR043 = "VR043"
    case VR045 = "VR045"
    case VR054 = "VR054"
    case VR058 = "VR058"
    case VR060 = "VR060"
    case VR071 = "VR071"
    case VR073 = "VR073"
    case VR083 = "VR083"
    case VR084 = "VR084"
    case VR085 = "VR085"
    case VR086 = "VR086"
    case VR087 = "VR087"
    case VR088 = "VR088"
    case VR092 = "VR092"
    case VR093 = "VR093"
    case VR096 = "VR096"
    case VR097 = "VR097"
    case VR100 = "VR100"
    case VR101 = "VR101"
    case VR104 = "VR104"
    case VR106 = "VR106"
    case VR108 = "VR108"
    case VR114 = "VR114"
    case VR118 = "VR118"
    case VR119 = "VR119"
    case VR125 = "VR125"
    case VR138 = "VR138"
    case VR140 = "VR140"
    case VR142 = "VR142"
    case VR143 = "VR143"
    case VR144 = "VR144"
    case VR151 = "VR151"
    case VR152 = "VR152"
    case VR156 = "VR156"
    case VR158 = "VR158"
    case VR159 = "VR159"
    case VR168 = "VR168"
    case VR176 = "VR176"
    case VR179 = "VR179"
    case VR184 = "VR184"
    case VR186 = "VR186"
    case VR189 = "VR189"
    case VR190 = "VR190"
    case VR191 = "VR191"
    case VR196 = "VR196"
    case VR197 = "VR197"
    case VR198 = "VR198"
    case VR199 = "VR199"
    case VR201 = "VR201"
    case VR202 = "VR202"
    case VR208 = "VR208"
    case VR209 = "VR209"
    case VR222 = "VR222"
    case VR223 = "VR223"
    case VR231 = "VR231"
    case VR239 = "VR239"
    case VR241 = "VR241"
    case VR242 = "VR242"
    case VR243 = "VR243"
    case VR244 = "VR244"
    case VR245 = "VR245"
    case VR249 = "VR249"
    case VR259 = "VR259"
    case VR260 = "VR260"
    case VR263 = "VR263"
    case VR267 = "VR267"
    case VR268 = "VR268"
    case VR269 = "VR269"
    case VR289 = "VR289"
    case VR296 = "VR296"
    case VR299 = "VR299"
    case VR316 = "VR316"
    case VR319 = "VR319"
    case VR331 = "VR331"
    case VR389 = "VR389"
    case VR391 = "VR391"
    case VR410 = "VR410"
    case VR411 = "VR411"
    case VR413 = "VR413"
    case VR510 = "VR510"
    case VR511 = "VR511"
    case VR512 = "VR512"
    case VR531 = "VR531"
    case VR532 = "VR532"
    case VR533 = "VR533"
    case VR534 = "VR534"
    case VR535 = "VR535"
    case VR536 = "VR536"
    case VR540 = "VR540"
    case VR541 = "VR541"
    case VR544 = "VR544"
    case VR545 = "VR545"
    case VR552 = "VR552"
    case VR604 = "VR604"
    case VR607 = "VR607"
    case VR615 = "VR615"
    case VR619 = "VR619"
    case VR634 = "VR634"
    case VR664 = "VR664"
    case VR704 = "VR704"
    case VR705 = "VR705"
    case VR707 = "VR707"
    case VR708 = "VR708"
    case VR724 = "VR724"
    case VR725 = "VR725"
    case VR840 = "VR840"
    case VR841 = "VR841"
    case VR842 = "VR842"
    case VR931 = "VR931"
    case VR932 = "VR932"
    case VR933 = "VR933"
    case VR934 = "VR934"
    case VR935 = "VR935"
    case VR936 = "VR936"
    case VR937 = "VR937"
    case VR938 = "VR938"
    case VR940 = "VR940"
    case VR941 = "VR941"
    case VR954 = "VR954"
    case VR955 = "VR955"
    case VR1001 = "VR1001"
    case VR1002 = "VR1002"
    case VR1003 = "VR1003"
    case VR1004 = "VR1004"
    case VR1005 = "VR1005"
    case VR1006 = "VR1006"
    case VR1007 = "VR1007"
    case VR1008 = "VR1008"
    case VR1009 = "VR1009"
    case VR1010 = "VR1010"
    case VR1013 = "VR1013"
    case VR1014 = "VR1014"
    case VR1017 = "VR1017"
    case VR1020 = "VR1020"
    case VR1021 = "VR1021"
    case VR1022 = "VR1022"
    case VR1023 = "VR1023"
    case VR1024 = "VR1024"
    case VR1030 = "VR1030"
    case VR1031 = "VR1031"
    case VR1032 = "VR1032"
    case VR1033 = "VR1033"
    case VR1039 = "VR1039"
    case VR1040 = "VR1040"
    case VR1041 = "VR1041"
    case VR1043 = "VR1043"
    case VR1046 = "VR1046"
    case VR1050 = "VR1050"
    case VR1051 = "VR1051"
    case VR1052 = "VR1052"
    case VR1054 = "VR1054"
    case VR1055 = "VR1055"
    case VR1056 = "VR1056"
    case VR1059 = "VR1059"
    case VR1061 = "VR1061"
    case VR1065 = "VR1065"
    case VR1066 = "VR1066"
    case VR1070 = "VR1070"
    case VR1072 = "VR1072"
    case VR1082 = "VR1082"
    case VR1083 = "VR1083"
    case VR1084 = "VR1084"
    case VR1085 = "VR1085"
    case VR1087 = "VR1087"
    case VR1088 = "VR1088"
    case VR1089 = "VR1089"
    case VR1097 = "VR1097"
    case VR1098 = "VR1098"
    case VR1102 = "VR1102"
    case VR1103 = "VR1103"
    case VR1104 = "VR1104"
    case VR1105 = "VR1105"
    case VR1106 = "VR1106"
    case VR1107 = "VR1107"
    case VR1108 = "VR1108"
    case VR1109 = "VR1109"
    case VR1110 = "VR1110"
    case VR1113 = "VR1113"
    case VR1116 = "VR1116"
    case VR1117 = "VR1117"
    case VR1120 = "VR1120"
    case VR1121 = "VR1121"
    case VR1122 = "VR1122"
    case VR1123 = "VR1123"
    case VR1124 = "VR1124"
    case VR1128 = "VR1128"
    case VR1130 = "VR1130"
    case VR1137 = "VR1137"
    case VR1139 = "VR1139"
    case VR1140 = "VR1140"
    case VR1141 = "VR1141"
    case VR1142 = "VR1142"
    case VR1143 = "VR1143"
    case VR1144 = "VR1144"
    case VR1145 = "VR1145"
    case VR1146 = "VR1146"
    case VR1175 = "VR1175"
    case VR1176 = "VR1176"
    case VR1182 = "VR1182"
    case VR1195 = "VR1195"
    case VR1196 = "VR1196"
    case VR1205 = "VR1205"
    case VR1206 = "VR1206"
    case VR1214 = "VR1214"
    case VR1215 = "VR1215"
    case VR1217 = "VR1217"
    case VR1218 = "VR1218"
    case VR1233 = "VR1233"
    case VR1250 = "VR1250"
    case VR1251 = "VR1251"
    case VR1252 = "VR1252"
    case VR1253 = "VR1253"
    case VR1254 = "VR1254"
    case VR1255 = "VR1255"
    case VR1256 = "VR1256"
    case VR1257 = "VR1257"
    case VR1259 = "VR1259"
    case VR1260 = "VR1260"
    case VR1261 = "VR1261"
    case VR1262 = "VR1262"
    case VR1264 = "VR1264"
    case VR1265 = "VR1265"
    case VR1266 = "VR1266"
    case VR1267 = "VR1267"
    case VR1268 = "VR1268"
    case VR1293 = "VR1293"
    case VR1300 = "VR1300"
    case VR1301 = "VR1301"
    case VR1302 = "VR1302"
    case VR1303 = "VR1303"
    case VR1304 = "VR1304"
    case VR1305 = "VR1305"
    case VR1350 = "VR1350"
    case VR1351 = "VR1351"
    case VR1352 = "VR1352"
    case VR1353 = "VR1353"
    case VR1354 = "VR1354"
    case VR1355 = "VR1355"
    case VR1422 = "VR1422"
    case VR1423 = "VR1423"
    case VR1427 = "VR1427"
    case VR1445 = "VR1445"
    case VR1446 = "VR1446"
    case VR1520 = "VR1520"
    case VR1521 = "VR1521"
    case VR1525 = "VR1525"
    case VR1546 = "VR1546"
    case VR1616 = "VR1616"
    case VR1617 = "VR1617"
    case VR1624 = "VR1624"
    case VR1625 = "VR1625"
    case VR1626 = "VR1626"
    case VR1627 = "VR1627"
    case VR1628 = "VR1628"
    case VR1629 = "VR1629"
    case VR1631 = "VR1631"
    case VR1632 = "VR1632"
    case VR1633 = "VR1633"
    case VR1635 = "VR1635"
    case VR1636 = "VR1636"
    case VR1638 = "VR1638"
    case VR1639 = "VR1639"
    case VR1640 = "VR1640"
    case VR1641 = "VR1641"
    case VR1642 = "VR1642"
    case VR1644 = "VR1644"
    case VR1645 = "VR1645"
    case VR1647 = "VR1647"
    case VR1648 = "VR1648"
    case VR1650 = "VR1650"
    case VR1666 = "VR1666"
    case VR1667 = "VR1667"
    case VR1668 = "VR1668"
    case VR1679 = "VR1679"
    case VR1709 = "VR1709"
    case VR1711 = "VR1711"
    case VR1712 = "VR1712"
    case VR1713 = "VR1713"
    case VR1721 = "VR1721"
    case VR1722 = "VR1722"
    case VR1726 = "VR1726"
    case VR1743 = "VR1743"
    case VR1753 = "VR1753"
    case VR1754 = "VR1754"
    case VR1755 = "VR1755"
    case VR1756 = "VR1756"
    case VR1757 = "VR1757"
    case VR1759 = "VR1759"
    case VR1800 = "VR1800"
    case VR1801 = "VR1801"
    case VR1900 = "VR1900"
    case VR1902 = "VR1902"
    case VR1905 = "VR1905"
    case VR1909 = "VR1909"
    case VR1912 = "VR1912"
    case VR1915 = "VR1915"
    case VR1916 = "VR1916"
    case VR1939 = "VR1939"
}

