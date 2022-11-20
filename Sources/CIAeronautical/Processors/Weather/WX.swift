//
//  WX.swift
//  
//
//  Created by Jorge Alvarez on 10/26/22.
//

import SwiftUI

public struct WX {
    
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
        if let rawText = metar.rawText, rawText.uppercased().contains("VRB") { direction = "VRB" }
        
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
}
