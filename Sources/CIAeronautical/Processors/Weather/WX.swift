//
//  WX.swift
//  
//
//  Created by Jorge Alvarez on 10/26/22.
//

import SwiftUI

public struct WX {
    
    public struct Condition {
        // TODO: any icon that can have a .fill version should use that if using icon for Weather container
        public let name: String
        public let color: Color
        public let keyword: String
        public let iconName: String
        /// Not all Conditions will have a different iconFilledName
        public let iconFilledName: String
        public let iconNightName: String
    }
    
    public static let weatherGroups = ["-": "Light",
                                "+": "Heavy",
                                "VC": "Vicinity",
                                "DSNT": "Distant",
                                "BC": "Patchy",
                                "BL": "Blowing",
                                "DR": "Drifting",
                                "FZ": "Freezing",
                                "MI": "Shallow",
                                "PR": "Partial",
                                "SH": "Showers",
                                "TS": "Thunderstorms",
                                "DZ": "Drizzle",
                                "GR": "Hail",
                                "GS": "Small Hail",
                                "IC": "Ice Crystals",
                                "PL": "Ice Pellets",
                                "RA": "Rain",
                                "SG": "Snow Grains",
                                "SN": "Snow",
                                "UP": "Unknown Precipitation",
                                "BR": "Mist",
                                "DU": "Widespread Dust",
                                "FG": "Fog",
                                "FU": "Smoke",
                                "HZ": "Haze",
                                "PY": "Spray",
                                "SA": "Sand",
                                "VA": "Volcanic Ash",
                                "DS": "Dust Storm",
                                "FC": "Funnel Clouds",
                                "PO": "Dust / Sand Whirls",
                                "SQ": "Squalls",
                                "SS": "Sandstorm"]
    
    public static func cleanWx(word: String) -> String? {
        
        guard word.count % 2 == 0 else { return nil }
        
        // every 2 characters, replace them with their translation
        var result = ""
        let words = Array(word)
        let count = words.count
        var i = 0
        
        while i < count && (i+1) < count {
            let currAbrv = "\(words[i])\(words[i+1])"
            if let newWord = WX.weatherGroups[currAbrv] {
                let comma = count - 2 == i ? "" : " "
                result += newWord + comma
            }
            i += 2
        }
        
        // Showers goes after precipitation
        if result.contains("Showers") {
            print("Found Showers")
            let precipitation = Set(["Rain", "Snow"])
            var final = Array(result.split(separator: " "))
            let finalCount = final.count
            for i in 0..<finalCount {
                if final[i] == "Showers" && (i+1) < finalCount {
                    let nextWord = final[i+1]
                    if precipitation.contains(String(nextWord)) {
                        final[i] = nextWord
                        final[i+1] = "Showers"
                    }
                }
            }
            return String(final.joined(separator: " "))
        }
            
        return result
    }


    public static func cleanWxString(wx: String?) -> String? {
        
        guard let wx = wx, !wx.isEmpty else { return nil }
        
        var result = ""
        
        let words = Array(wx.split(separator: " "))
        let count = words.count
        
        for i in 0..<count {
            
            var intensity = ""
            var wordArray = Array(words[i])
            let first = wordArray[0]
            
            // Heavy
            if first == "+" {
                intensity += "Heavy "
                wordArray.remove(at: 0)
            }
            
            // Light
            else if first == "-" {
                intensity += "Light "
                wordArray.remove(at: 0)
            }
            
            // TODO: remove "DSNT" the same way "-" and "+" are removed?
            // TODO: "+FC" is Tornado instead of Heavy Funnel Clouds
                    
            let comma = count - 1 == i ? "" : ", "
            guard let cleanWx = cleanWx(word: String(wordArray)) else { return nil }
            result += intensity + cleanWx + comma
        }
        
        return result
    }
    
    /// "KBAB"
    public static let kbabIcao = "KBAB"

    /// KBAB Latitude. 39.1361
    public static let kbabLat = 39.1361
    
    /// KBAB Longitude. -121.436586
    public static let kbabLong = -121.436586
    
    public static func summaryString(metar: Metar?, lat: Double?, long: Double?) -> some View {
                
        var wxIcon = WX.unknownWxIcon
        var iconColor = Color.primary
        
        guard let metar = metar else {
            return HStack(spacing: 2) {
                Text("NA - Wind Unavailable")
                wxIcon.foregroundColor(iconColor)
            }
        }
        
        // Wind
        var direction = String(format:  "%03d", Int(metar.windDirDegrees ?? 0.0)) + "°"
        if let rawText = metar.rawText, rawText.uppercased().contains("VRB") { direction = "VAR" }
        
        let speed = Int(metar.windSpeedKts ?? 0.0)
        let gustInt = Int(metar.windGustKts ?? 0.0)
        let gustString = gustInt == 0 ? "" : " Gust \(gustInt)"
        var flightCategory = metar.flightCategory ?? "NA"
        if flightCategory.isEmpty { flightCategory = "NA" }
        var windString = "\(direction) at \(speed) kts\(gustString)"
        if speed == 0 { windString = "Winds Calm" }
        
        // Flight Category with color
        let flightCategoryText = Text(flightCategory).foregroundColor(WX.colors[flightCategory])
                
        // Visibility with color
        let visCategory = WX.visFlightCategory(vis: metar.visibilityStatuteMiles)
        let visColor = WX.colors[visCategory.rawValue]
        let visString = metar.visibilityStatuteMiles == nil ? "Vis NA" : "\(Int(metar.visibilityStatuteMiles!)) SM"
        let visText = Text(visString).foregroundColor(visCategory == .vfr ? Color.primary : visColor)
        
        var ceilingString = "NA"
        var ceilingCover = ""
        // Ceiling with color
        if let ceiling = WX.lowestCeiling(clouds: metar.skyConditions), let cover = ceiling.skyCover, let base = ceiling.cloudBaseFtAgl {
            
            if cover == "OVX" {
                let ovxBase = metar.vertVisFt ?? 0.0
                ceilingString = "\(WX.skyCoverDict[cover, default: "NA"]) \(Int(ovxBase))\'"
            } else {
                ceilingString = "\(WX.skyCoverDict[cover, default: "NA"]) \(Int(base))\'"
            }
            
            ceilingCover = cover
        } else {
            if let firstCloud = metar.skyConditions?.first, let cover = firstCloud.skyCover {
                
                // FEW, SCT, BKN, OVC
                if let base = firstCloud.cloudBaseFtAgl {
                    ceilingString = "\(WX.skyCoverDict[cover, default: "NA"]) \(Int(base))\'"
                    ceilingCover = cover
                }
                
                // CLR, SKC
                else {
                    ceilingString = "\(WX.skyCoverDict[cover, default: "NA"])"
                    ceilingCover = cover
                }
                
            }
        }
        let ceilingCategory = WX.cloudsFlightCategory(clouds: metar.skyConditions)
        let ceilingColor = WX.colors[ceilingCategory.rawValue]
        let ceilingText = Text("\(ceilingString)").foregroundColor(ceilingCategory == .vfr ? Color.primary : ceilingColor)
        
        // WxIcon
        if let wind = metar.windSpeedKts {
            let wxCondition = WX.getWx(wxString: metar.wxString ?? "",
                                       ceilingString: ceilingCover,
                                       wind: wind,
                                       lat: lat,
                                       long: long)
            let wxIconString = WX.iconForWx(wxCondition: wxCondition)
            if wxCondition.rawValue < 15 { iconColor = Color.red }
            wxIcon = Image(systemName: wxIconString)
        }
        
        return HStack(spacing: 2) {
            flightCategoryText + Text(", \(windString), ") + visText + Text(", ") + ceilingText
            
            wxIcon.foregroundColor(iconColor)
        }
    }
          
    /// Raw Values less than 15 should be highlighted red
    public enum WxCondition: Int {
        
        /// 1. Volcanic Ash. "VA". Red
        case volcanicAsh
        
        /// 2. Funnel Clouds(s). "FC". Red
        case funnelClouds
        
        /// 3. Sandstorm. "SS". Red
        case sandstorm
        
        /// 4. Thunderstorms + Rain (Any Clouds). "TSRA". Red
        case thunderstormsRain
        
        /// 5. Vicinity Thunderstorms + Rain (Any Clouds). "VCTSRA". Red
        case vicinityThunderstormsRain
        
        /// 6. Thunderstorms (Ceiling). "TS". Red
        case thunderstormsCeiling
        
        /// 7. Vicinity Thunderstorms (Ceiling). "VCTS". Red
        case vicinityThunderstormsCeiling
        
        /// 8. Thunderstorms (NO Ceiling). "TS". Has Night icon. Red
        case thunderstormsNoCeiling
        /// 8. Thunderstorms (NO Ceiling). "TS". Has Night icon. Red
        case thunderstormsNoCeilingNight
        
        /// 9. Vicinity Thunderstorms (NO Ceiling). "VCTS". Has Night icon. Red
        case vicinityThunderstormsNoCeiling
        /// 9. Vicinity Thunderstorms (NO Ceiling). "VCTS". Has Night icon. Red
        case vicinityThunderstormsNoCeilingNight
        
        /// 10. Squalls. "SQ". Red
        case squalls
        
        /// 11. Hail. "GR". Red
        case hail
        
        /// 12. Small Hail / Snow Pellets. "GS". Red
        case smallHailSnowPellets
        
        /// 13. Duststorm. "DS". Red
        case dustStorm
        
        /// 14. Dust / Sand Whirls. "PO"
        case dustSandWhirls
        
        /// 15. Blowing Sand. "BLSA"
        case blowingSand
        
        /// 16. Blowing Dust. "BLDU"
        case blowingDust
        
        /// 17. Ice Crystals. "IC"
        case iceCrystals
        
        /// 18. Ice Pellets. "PL"
        case icePellets
        
        /// 19. Blowing Snow. "BLSN"
        case blowingSnow
        
        /// 20. Heavy Snow. "+SN"
        case heavySnow
        
        /// 21. Snow. "SN"
        case snow
        
        /// 22. Snow Grains. "SG"
        case snowGrains
        
        /// 23. Heavy Rain. "+RA"
        case heavyRain
        
        /// 24. Rain (Ceiling). "RA"
        case rain
        
        /// 25. Light Rain (Ceiling). "-RA"
        case lightRain
        
        /// 26. Rain (NO Ceiling). "RA". Has Night icon
        case rainSunshowers
        /// 26. Rain (NO Ceiling). "RA". Has Night icon
        case rainSunshowersNight
        
        /// 27. Drizzle. "DZ"
        case drizzle
        
        /// Drizzle (NO Ceiling). Has Night icon
        case drizzleNoCeiling
        /// Drizzle (NO Ceiling). Has Night icon
        case drizzleNoCeilingNight
        
        /// 28. Smoke. "FU"
        case smoke
        
        /// 29. Fog. "FG"
        case fog
        
        /// 30. Haze. "HZ". Has Night icon
        case haze
        
        /// 31. Dust. "DU". Has Night icon
        case dust
        
        /// 32. Sand. "SA". Has Night icon
        case sand
        
        /// 33. Mist. "BR". Has Night icon
        case mist
        
        /// 34. Spray. "PY"
        case spray
        
        /// 35. > 20 kts, any WX/Ceiling.
        case windy
        
        /// 36. Obscured. "OVX" Sky Cover
        case obscured
        
        /// 37. Overcast. "OVC" Sky Cover
        case overcast
        
        /// 38. Broken. "BKN" Sky Cover
        case broken
        
        /// 39. Scattered. "SCT" Sky Cover. Has Night icon
        case scattered
        /// 39. Scattered. "SCT" Sky Cover. Has Night icon
        case scatteredNight
        
        /// 40. Few. "FEW" Sky Cover. Has Night icon
        case few
        /// 40. Few. "FEW" Sky Cover. Has Night icon
        case fewNight
        
        /// 41. Clear. "CLR" Sky Cover. Has Night icon
        case clear
        /// 41. Clear. "CLR" Sky Cover. Has Night icon
        case clearNight
        
        /// 42. Sky clear. "SKC" Sky Cover. Has Night icon
        case skyClear
        /// 42. Sky clear. "SKC" Sky Cover. Has Night icon
        case skyClearNight
        
        /// 43. CAVOK. "CAVOK" Sky Cover. Has Night icon
        case cavok
        /// 43. CAVOK. "CAVOK" Sky Cover. Has Night icon
        case cavokNight
        
        case none
    }
    
    public static let filledIcons = ["moon": "moon.fill", "sun.max": "sun.max.fill", "cloud.moon": "cloud.moon.fill",
                                     "cloud": "cloud.fill", "cloud.sun": "cloud.sun.fill", "humidity": "humidity.fill", "cloud.fog": "cloud.fog.fill", "smoke": "smoke.fill", "cloud.moon.rain": "cloud.moon.rain.fill", "cloud.sun.rain": "cloud.sun.rain.fill"]

    /// Returns String for Image name associated with passed in WxCondition
    public static func iconForWx(wxCondition: WxCondition) -> String {
        
        // TODO: Update some icons (hazeNight, squalls, etc..) with SF Symbols 4?
        switch wxCondition {
            
        case .volcanicAsh:
            return "aqi.high"
        case .funnelClouds:
            return "tornado"
        case .sandstorm:
            return "aqi.medium"
        case .thunderstormsRain:
            return "cloud.bolt.rain.fill"
        case .vicinityThunderstormsRain:
            return "cloud.bolt.rain"
        case .thunderstormsCeiling:
            return "cloud.bolt.fill"
        case .vicinityThunderstormsCeiling:
            return "cloud.bolt"
        case .thunderstormsNoCeiling:
            return "cloud.sun.bolt.fill"
        case .thunderstormsNoCeilingNight:
            return "cloud.moon.bolt.fill"
        case .vicinityThunderstormsNoCeiling:
            return "cloud.sun.bolt"
        case .vicinityThunderstormsNoCeilingNight:
            return "cloud.moon.bolt"
        case .squalls:
            return "cloud.bolt"
        case .hail:
            return "cloud.hail.fill"
        case .smallHailSnowPellets:
            return "cloud.hail"
        case .dustStorm:
            return "aqi.low"
        case .dustSandWhirls, .blowingSand, .blowingDust:
            return "wind"
        case .iceCrystals, .icePellets, .snowGrains:
            return "snowflake"
        case .blowingSnow:
            return "wind.snow"
        case .heavySnow:
            return "cloud.snow.fill"
        case .snow:
            return "cloud.snow"
        case .heavyRain:
            return "cloud.heavyrain"
        case .rain:
            return "cloud.rain"
        case .lightRain, .drizzle:
            return "cloud.drizzle"
        case .rainSunshowers, .drizzleNoCeiling:
            return "cloud.sun.rain"
        case .rainSunshowersNight, .drizzleNoCeilingNight:
            return "cloud.moon.rain"
        case .smoke:
            return "smoke"
        case .fog, .haze:
            return "cloud.fog"
        case .dust, .sand:
            return "aqi.low"
        case .mist, .spray:
            return "humidity"
        case .windy:
            return "wind"
        case .obscured:
            return "cloud.fill"
        case .overcast, .broken:
            return "cloud"
        case .scattered, .few:
            return "cloud.sun"
        case .scatteredNight, .fewNight:
            return "cloud.moon"
        case .clear, .skyClear, .cavok:
            return "sun.max"
        case .clearNight, .skyClearNight, .cavokNight:
            return "moon"
        case .none:
            return "questionmark"
        }
    }

    /// Returns WxCondition associated with passed in wxString, ceiling, wind, and time of day (using coordinates)
    public static func getWx(wxString: String, ceilingString: String, wind: Double, lat: Double?, long: Double?) -> WxCondition {
        
        // if now >= Sunrise AND less than Sunset -> Sun Icon
        // else -> Moon Icon
        
        var needsNightIcon = true
        if let lat = lat, let long = long {
            let nowDate = Date()//Calendar.current.startOfDay(for: Date())
            // TODO: should sun times be come in order of what's next or just what that day's times were?
            let suntime = SunriseSunset(lat: lat, long: long, date: nowDate)
            let sunriseTime = suntime.sunRise?.timeIntervalSinceReferenceDate
            let sunsetTime = suntime.sunSet?.timeIntervalSinceReferenceDate
            let now = nowDate.timeIntervalSinceReferenceDate
//            if let rise = sunriseTime, let set = sunsetTime {
//                print("times are not optional sunrise: \(rise) sunset: \(set)")
//                if now >= rise && now < set {
//                    needsNightIcon = false
//                }
//            }
            if let rise = sunriseTime, let set = sunsetTime, now >= rise, now < set {
                needsNightIcon = false
            }
        }
        
        let ceilingSet = Set(["BKN", "OVC", "OVX"])
        let noCeilingSet = Set(["CAVOK", "CLR", "SKC", "FEW", "SCT"])
        
        // VA
        if wxString.contains("VA") { return .volcanicAsh }
        
        // Funnel Cloud(s)
        if wxString.contains("FC") { return .funnelClouds }
        
        // Sandstorm
        if wxString.contains("SS") { return .sandstorm }

        // Thunderstorms + Rain
        if wxString.contains("TSRA") && !wxString.contains("VCTSRA") { return .thunderstormsRain }

        // Vicinity Thunderstorms + Rain
        if wxString.contains("VCTSRA") { return .vicinityThunderstormsRain }
        
        // Thunderstorms + Ceiling
        if wxString.contains("TS") && !wxString.contains("VCTS") && ceilingSet.contains(ceilingString) { return .thunderstormsCeiling }

        // Vicinity Thunderstorms + Ceiling
        if wxString.contains("VCTS") && ceilingSet.contains(ceilingString) { return .vicinityThunderstormsCeiling }
        
        // Thunderstorms + NO Ceiling
        if wxString.contains("TS") && !wxString.contains("VCTS") {
            return needsNightIcon ? .thunderstormsNoCeilingNight : .thunderstormsNoCeiling
        }
        
        // Vicinity Thunderstorms + NO Ceiling
        if wxString.contains("VCTS") {
            return needsNightIcon ? .vicinityThunderstormsNoCeiling : .vicinityThunderstormsNoCeiling
        }

        // Squalls
        if wxString.contains("SQ") { return .squalls }
        
        // Hail
        if wxString.contains("GR") { return .hail }
        
        // Small Hail / Snow Pellets
        if wxString.contains("GS") { return .smallHailSnowPellets }

        // Dust Storm
        if wxString.contains("DS") { return .dustStorm }
        
        // Dust / Sand Whirls
        if wxString.contains("PO") { return .dustSandWhirls }
        
        // Blowing Sand
        if wxString.contains("BLSA") { return .blowingSand }
        
        // Blowing Dust
        if wxString.contains("BLDU") { return .blowingDust }
        
        // Ice Crystals
        if wxString.contains("IC") { return .iceCrystals }
        
        // Ice Pellets
        if wxString.contains("PL") { return .icePellets }
        
        // Blowing Snow
        if wxString.contains("BLSN") { return .blowingSnow }
        
        // Heavy Snow
        if wxString.contains("+SN") { return .heavySnow }
        
        // Snow
        if wxString.contains("SN") { return .snow }
        
        // Snow Grains
        if wxString.contains("SG") { return .snowGrains }
        
        // Heavy Rain
        if wxString.contains("+RA") { return .heavyRain }
        
        // Rain + Ceiling
        if wxString.contains("RA") && ceilingSet.contains(ceilingString) && !wxString.contains("-RA") { return .rain }
        
        // Light Rain + Ceiling
        if wxString.contains("-RA") && ceilingSet.contains(ceilingString) { return .lightRain }
        
        // Rain + NO Ceiling (Sunshowers)
        if wxString.contains("RA") && noCeilingSet.contains(ceilingString) {
            return needsNightIcon ? .rainSunshowersNight : .rainSunshowers
        }
        
        // Drizzle + Ceiling
        if wxString.contains("DZ") && ceilingSet.contains(ceilingString) { return .drizzle }
        
        // Drizzle + NO Ceiling
        if wxString.contains("DZ") && noCeilingSet.contains(ceilingString) {
            return needsNightIcon ? .drizzleNoCeilingNight : .drizzleNoCeiling
        }
        
        // Smoke
        if wxString.contains("FU") { return .smoke }
        
        // Fog
        if wxString.contains("FG") { return .fog }
        
        // Haze
        if wxString.contains("HZ") { return .haze }

        // Dust
        if wxString.contains("DU") { return .dust }
        
        // Sand
        if wxString.contains("SA") { return .sand }
        
        // Mist
        if wxString.contains("BR") { return .mist }
        
        // Spray
        if wxString.contains("PY") { return .spray }

        // Windy
        if wind > 20.0 { return .windy }
        
        // Obscured
        if ceilingString == "OVX" { return .obscured }
        
        // Overcast
        if ceilingString == "OVC" { return .overcast }
        
        // Broken
        if ceilingString == "BKN" { return .broken }
        
        // Scattered
        if ceilingString == "SCT" {
            return needsNightIcon ? .scatteredNight : .scattered
        }
        
        // Few
        if ceilingString == "FEW" {
            return needsNightIcon ? .fewNight : .few
        }
        
        // Clear
        if ceilingString == "CLR" {
            return needsNightIcon ? .clearNight : .clear
        }
        
        // Sky Clear
        if ceilingString == "SKC" {
            return needsNightIcon ? .skyClearNight : .skyClear
        }
        
        // CAVOK
        if ceilingString == "CAVOK" {
            return needsNightIcon ? .cavokNight : .cavok
        }
        
        // None?
        return .none
    }

    
    // TODO: move this to Color+Extension?
    public static let colors: [String: Color] = [FlightCategory.none.rawValue: Color.gray,
                                                 FlightCategory.vfr.rawValue: Color.green,
                                                 FlightCategory.mvfr.rawValue: Color.blue,
                                                 FlightCategory.ifr.rawValue: Color.red,
                                                 FlightCategory.lifr.rawValue: Color(UIColor.magenta)]
    
    public enum FlightCategory: String {
        case vfr = "VFR"
        case mvfr = "MVFR"
        case ifr = "IFR"
        case lifr = "LIFR"
        case none = "NA"
    }
    
    public static let skyCoverDict = [SkyCover.clear.rawValue: "Clear",
                                      SkyCover.skyClear.rawValue: "Sky clear",
                                      SkyCover.few.rawValue: "Few",
                                      SkyCover.scattered.rawValue: "Scattered",
                                      SkyCover.broken.rawValue: "Broken",
                                      SkyCover.overcast.rawValue: "Overcast",
                                      SkyCover.obscured.rawValue: "Obscured",
                                      SkyCover.cavok.rawValue: "Clear and Visibility OK"]
        
    public enum SkyCover: String {
        /// No clouds detected below 12,000 feet
        case clear = "CLR"
        case skyClear = "SKC"
        case few = "FEW"
        case scattered = "SCT"
        /// Broken and Overcast can be ceilings
        case broken = "BKN"
        /// Broken and Overcast can be ceilings
        case overcast = "OVC"
        case cavok = "CAVOK"
        /// Ceiling. Checks vert_vis_ft for altitude instead of cloudBaseFtAgl
        case obscured = "OVX"
    }

    /// Image(systemName: "questionmark")
    public static let unknownWxIcon = Image(systemName: "questionmark")
    
    public static func lowestCeiling(clouds: [SkyCondition]?) -> SkyCondition? {
        
        // Clouds unavailable, can't calculate flight category
        guard let clouds = clouds else { return nil }
        
        let ceilings = clouds.filter { $0.skyCover == SkyCover.broken.rawValue || $0.skyCover == SkyCover.overcast.rawValue || $0.skyCover == SkyCover.obscured.rawValue }
        
        // No ceilings
        if ceilings.isEmpty { return nil }
        
        var lowest: SkyCondition? = ceilings.first
        
        for ceiling in ceilings {
            guard let ceilingCloudBase = ceiling.cloudBaseFtAgl, let lowestCloudBase = lowest?.cloudBaseFtAgl else { continue }
            if ceilingCloudBase <= lowestCloudBase { lowest = ceiling }
        }
        
        return lowest
    }
    
    public static func visFlightCategory(vis: Double?) -> FlightCategory {
        guard let vis = vis else { return .none }
        
        if vis < 1 { return .lifr }
        
        if vis >= 1 && vis < 3 { return .ifr }
        
        if vis >= 3 && vis <= 5 { return .mvfr }
        
        if vis > 5 { return .vfr }
        
        return .none
    }
        
    public static func cloudsFlightCategory(clouds: [SkyCondition]?) -> FlightCategory {
        guard let clouds = clouds else { return .none }
        
        let lowest = lowestCeiling(clouds: clouds)
        
        guard let ceiling = lowest?.cloudBaseFtAgl else { return .vfr }
        
        print("lowest ceiling: \(ceiling)")
        
        if ceiling < 500 { return .lifr }
        
        if ceiling >= 500 && ceiling < 1000 { return .ifr }
        
        if ceiling >= 1000 && ceiling <= 3000 { return .mvfr }
        
        if ceiling > 3000 { return .vfr }
        
        return .none
    }
    
    public static func calculatedFlightCategory(vis: Double?, clouds: [SkyCondition]?) -> (flightCategory: FlightCategory,
                                                                                    visCategory: FlightCategory,
                                                                                    cloudCategory: FlightCategory) {
        
        guard let vis = vis, let clouds = clouds else { return (.none, .none, .none) }
        
        let visRule = visFlightCategory(vis: vis)
        let cloudRule = cloudsFlightCategory(clouds: clouds)
        
        // LIFR
        if visRule == .lifr || cloudRule == .lifr { return (.lifr, visRule, cloudRule) }
        
        // IFR
        if visRule == .ifr || cloudRule == .ifr { return (.ifr, visRule, cloudRule) }
        
        // MVFR
        if visRule == .mvfr || cloudRule == .mvfr { return (.mvfr, visRule, cloudRule) }
        
        // VFR
        if visRule == .vfr && cloudRule == .vfr { return (.vfr, visRule, cloudRule) }
        
        // NA
        return (.none, .none, .none)
    }
    
    // TODO: needs to first look for first wind string (has KT at the end), then check if the next word is exactly 7 chars long with V in the middle
    /// Returns the high and low ends of a Metar's wind direction. If no variable wind, returns wind direction as both low and high. Returns nil if no wind direction
    public static func getVariableWind(rawText: String?, windDir: Double? = nil) -> (low: Int, high: Int)? {
        
        guard let rawText = rawText, let windDir = windDir else { return nil }
        
        let words = rawText.split(separator: " ")
        
        // return low and high ends of wind variation if it exists
        for word in words {
            if word.count == 7 {
                let wordArray = Array(word)
                if wordArray[3].uppercased() == "V" {
                    let low = Int("\(wordArray[0])\(wordArray[1])\(wordArray[2])")
                    let high = Int("\(wordArray[4])\(wordArray[5])\(wordArray[6])")
                    guard let low = low, let high = high else { return nil }
                    return (low, high)
                }
            }
        }
         
        // if we do not find variable wind, return wind direction as high and low
        let result = Int(windDir)
        return (result, result)
    }
    
    /// Returns wind direction as String. Returns variable wind if applicable. Examples: "170°", "170-200°"", "VRB", "-°"
    public static func windDirectionString(rawText: String?, windDir: Double?) -> String {
        
        // nil
        var dir = "-"
        
        // TODO: also check if word that contains VRB is the first wind string (KT) we find?
        // VRB
        if let rawText = rawText, rawText.uppercased().contains("VRB") {
            return "VAR"
        }
        
        if let varWinds = WX.getVariableWind(rawText: rawText, windDir: windDir) {
            
            let low = String(format: "%03d", varWinds.low)
            let high = String(format: "%03d", varWinds.high)
            
            // Regular
            if low == high {
                dir = "\(low)°"
            }
            
            // Variable Range
            else {
                dir = "\(varWinds.low)°-\(varWinds.high)°"
            }
        }
        
        return dir
    }
    
//    /// Returns Optional Tuple containing high/low ends of wind direction if variable. Otherwise returns wind direction or nil if no wind direction or rawText exists
//    public static func variableWinds(rawText: String?, windDir: Double?) -> (low: Int, high: Int)? {
//        return WX.getVariableWind(rawText: rawText, windDir: windDirDegrees)
//    }
    
    /// Returns wind direction, speed, and gust as a single String. Examples: "180 12 G15", "170-200 6 G5", "VRB 6", "CALM", "-"
    public static func windPanelString(windDir: Double?, windSpeed: Double?, windGust: Double?, rawText: String?) -> String {
        
        var speed = "-"
        if let windSpeed = windSpeed { speed = "\(Int(windSpeed))" }
        
        var gust = ""
        if let windGust = windGust, windGust != 0.0 { gust = " G\(Int(windGust))" }
        
        // nil
        var dir = "-"
        
        // VRB - only check first wind string (contains "KT") since Forecast rawTexts can have a second wind string
        if let rawText = rawText {
            let words = rawText.split(separator: " ")
            var containsKT = false
            for word in words {
                let newWord = word.uppercased()
                if newWord.contains("KT") {
                    containsKT = true
                    // make sure its not the ICAO that has KT in it
                    if newWord.count > 4 {
                       if newWord.contains("VRB") {
                           return "VAR at \(speed)\(gust)"
                       } else {
                           break
                       }
                   }
                }
            }
            
            // if there's no wind string at all, its VRB
            if !containsKT {
                return "VAR at \(speed)\(gust)"
            }
        }
        
        // Variable Winds
        if let varWinds = WX.getVariableWind(rawText: rawText, windDir: windDir) {
            
            let low = String(format: "%03d", varWinds.low)
            let high = String(format: "%03d", varWinds.high)
            
            // Regular
            if low == high {
                dir = "\(low)"
            }
            
            // Variable Range
            else {
                dir = "\(varWinds.low)°-\(varWinds.high)°"
            }
        }
        
        return "\(dir)° at \(speed)\(gust)"
    }
    
    public static func containsChange(word: String) -> Bool {
        
        let wordCount = word.count
        // make sure its 2 or more characters long first
        guard wordCount >= 2 else { return false }
        
        // first 5 are TEMPO or BECMG
        if wordCount >= 5 {
            if word == "TEMPO" || word == "BECMG" { return true }
        }
        
        // first 4 are PROB
        if wordCount >= 4 {
            if containsProb(word: word) { return true }
        }
        
        // first 2 are FM
        let wordArray = Array(word)
        if wordArray[0] == "F" && wordArray[1] == "M" { return true }
        
        return false
    }

    public static func containsProb(word: String) -> Bool {
        guard word.count >= 4 else { return false }
        let wordArray = Array(word)
        if wordArray[0] == "P" && wordArray[1] == "R" && wordArray[2] == "O" && wordArray[3] == "B" { return true }
        return false
    }

    public static func forecastRawTexts(rawText: String?) -> [String] {
        
        guard let rawText = rawText else { return [] }
        
        var forecasts = [String]()
        var currText = ""
        
        let words = rawText.split(separator: " ")
        
    //    let breaks = Set(["PROB", "TEMPO", "BECMG", "FM"])
        let count = words.count
        var i = 0
        while i < count {
            let newWord = "\(words[i])"
            if containsChange(word: newWord) {
    //            print("Break: \(newWord)")
                
                // if current contains Prob AND next word contains change, skip Prob
                if containsProb(word: newWord) && (i+1) < count {
                    // check next word
    //                print("found PROB, next word: \(words[i+1])")
                    forecasts.append(currText)
                    currText = "\(words[i]) \(words[i+1]) "
                    i += 2
                    continue
                }
                
                forecasts.append(currText)
                currText = ""
            }
            currText += "\(words[i]) "
            i += 1
        }
        
        forecasts.append(currText)

        return forecasts
    }
}
