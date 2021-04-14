// ********************** SunTime *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 4/1/21, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** SunTime *********************************

import Combine
import CoreLocation

@available(tvOS 13.0, *)
public class SunTime: ObservableObject {
    
    @Published public var sunRise: Date?
    @Published public var sunSet: Date?
    @Published public var dayLightDurationInMinutes: Double?
    @Published public var civilTwilightDawn: Date?
    @Published public var civilTwilightDusk: Date?
    @Published public var civilTwilightDawnDurationInMinutes: Double?
    @Published public var civilTwilightDuskDurationInMinutes: Double?
    @Published public var nauticalTwilightDawn: Date?
    @Published public var nauticalTwilightDusk: Date?
    @Published public var nauticalTwilightDawnDurationInMinutes: Double?
    @Published public var nauticalTwilightDuskDurationInMinutes: Double?
    @Published public var astronomicalTwilightDawn: Date?
    @Published public var astronomicalTwilightDusk: Date?
    @Published public var astronomicalTwilightDawnDurationInMinutes: Double?
    @Published public var astronomicalTwilightDuskDurationInMinutes: Double?
    
    @Published public var julianDay: Int?
    
    private var location: CLLocationCoordinate2D
    private var date: Date
    private var secondsFromGMT: Double
    private var timeZone: TimeZone
    
    public enum Twilight { case none, civil, nautical, astronomical }
    public enum DayPortion { case dawn, dusk }
    
    public init(location: CLLocationCoordinate2D, date: Date = Date()) {
        self.date = date
        self.location = location
        guard let timeZoneUTC = TimeZone(identifier: "UTC") else { fatalError() }
        self.timeZone = timeZoneUTC
        self.secondsFromGMT = Double(timeZoneUTC.secondsFromGMT(for: date) / (3600))
        setTimes()
    }
    
    public func setTimes() {
        sunRise = sunTimes(dayPortion: .dawn, twilight: .none)
        sunSet = sunTimes(dayPortion: .dusk, twilight: .none)
        civilTwilightDawn = sunTimes(dayPortion: .dawn, twilight: .civil)
        civilTwilightDusk = sunTimes(dayPortion: .dusk, twilight: .civil)
        nauticalTwilightDawn = sunTimes(dayPortion: .dawn, twilight: .nautical)
        nauticalTwilightDusk = sunTimes(dayPortion: .dusk, twilight: .nautical)
        astronomicalTwilightDawn = sunTimes(dayPortion: .dawn, twilight: .astronomical)
        astronomicalTwilightDusk = sunTimes(dayPortion: .dusk, twilight: .astronomical)
        dayLightDurationInMinutes = sunlightDuration(twilight: .none)
        civilTwilightDawnDurationInMinutes = getTwilightDurationInMinutes(dayPortion: .dawn, twilight: .civil)
        civilTwilightDuskDurationInMinutes = getTwilightDurationInMinutes(dayPortion: .dusk, twilight: .civil)
        nauticalTwilightDawnDurationInMinutes = getTwilightDurationInMinutes(dayPortion: .dawn, twilight: .nautical)
        nauticalTwilightDuskDurationInMinutes = getTwilightDurationInMinutes(dayPortion: .dusk, twilight: .nautical)
        astronomicalTwilightDawnDurationInMinutes = getTwilightDurationInMinutes(dayPortion: .dawn, twilight: .astronomical)
        astronomicalTwilightDuskDurationInMinutes = getTwilightDurationInMinutes(dayPortion: .dusk, twilight: .astronomical)
        julianDay = getJulianDay()
    }
    
    
    private func getTwilightDurationInMinutes(dayPortion: DayPortion, twilight: Twilight) -> Double {
        switch dayPortion {
        case .dawn:
            switch twilight {
            case .civil: return getMinutesBetween(civilTwilightDawn, and: sunRise)
            case .nautical: return getMinutesBetween(nauticalTwilightDawn, and: sunRise)
            case .astronomical: return getMinutesBetween(astronomicalTwilightDawn, and: sunRise)
            case .none: return 999999
            }
        case .dusk:
            switch twilight {
            case .civil: return getMinutesBetween(civilTwilightDusk, and: sunSet)
            case .nautical: return getMinutesBetween(nauticalTwilightDusk, and: sunSet)
            case .astronomical: return getMinutesBetween(astronomicalTwilightDusk, and: sunSet)
            case .none: return 999999
            }
        }
    }
    
    private func getMinutesBetween(_ d1: Date?, and d2: Date?) -> Double {
        guard let d1 = d1 else { fatalError() }
        guard let d2 = d2 else { fatalError() }
        return abs(d1.distance(to: d2) / 60)
    }
    
    private func jdFromDate() -> Double {
        let julianDate = self.date.timeIntervalSince1970 / (60 * 60 * 24) + 25569.0
        let calender = Calendar.current
        let localHour = Double(calender.component(.hour, from: date))
        let localMinute = Double(calender.component(.minute, from: date))
        let localSecond = Double(calender.component(.second, from: date))
        let timeProprtionToDay = (localHour + (localMinute/60) + (localSecond/3600))/24
        let julianDay = julianDate + 2415018.5 + timeProprtionToDay - (self.secondsFromGMT/24)
        return julianDay
    }
    
    private func julianCentury() -> Double {
        let jd = jdFromDate()
        return (jd-2451545)/36525
    }
    
    private func geomMeanLongSun() -> Double {
        let innerFunc = (36000.76983 + julianCentury() * 0.0003032)
        let outerFunc = (280.46646 + julianCentury() * innerFunc)
        return outerFunc.truncatingRemainder(dividingBy: 360)
    }
    
    private func geomMeanAnomSunDegrees() -> Double {
        return 357.52911 + julianCentury() * (35999.05029 - 0.0001537 * julianCentury())
    }
    
    private func eccentEarthOrbit() -> Double{
        return 0.016708634 - julianCentury() * (0.000042037 + 0.0000001267 * julianCentury())
    }
    
    private func sunEqOfCtr() -> Double {
        let J2 = geomMeanAnomSunDegrees()
        let G2 = julianCentury()
        let a = sin(J2.degreesToRadians)
        let b = 1.914602 - G2 * (0.004817 + 0.000014 * G2)
        let c = sin((J2 * 2).degreesToRadians)
        let d = 0.019993 - 0.000101 * G2
        let e = sin((J2 * 3).degreesToRadians)
        return a * b + c * d + e * 0.000289
    }
    
    private func sunTrueLongDegrees() -> Double {
        return geomMeanLongSun() + sunEqOfCtr()
    }
    
    private func sunTrueAnomDegrees() -> Double {
        return geomMeanAnomSunDegrees() + sunEqOfCtr()
    }
    
    private func sunRadVectorAUs() -> Double {
        let K2 = eccentEarthOrbit()
        let N2 = sunTrueAnomDegrees()
        let a = 1.000001018 * (1 - K2 * K2)
        let b = 1 + K2 * cos(N2.degreesToRadians)
        return a/b
    }
    
    private func sunAppLong() -> Double {
        let M2 = sunTrueLongDegrees()
        let G2 = julianCentury()
        let a = (125.04 - 1934.136 * G2).degreesToRadians
        return M2 - 0.00569 - 0.00478 * sin(a)
    }
    
    private func meanObliqEclipticDegrees() -> Double {
        let G2 = julianCentury()
        return 23 + (26 + ((21.448 - G2 * (46.815 + G2 * (0.00059 - G2 * 0.001813))))/60)/60
    }
    
    private func obliqCorrDegrees() -> Double {
        let Q2 = meanObliqEclipticDegrees()
        let G2 = julianCentury()
        let a = cos((125.04 - 1934.136 * G2).degreesToRadians)
        return Q2 + 0.00256 * a
    }
    
    private func sunRtAscenDegrees() -> Double {
        let R2 = obliqCorrDegrees()
        let P2 = sunAppLong()
        let a = cos(P2.degreesToRadians)
        let b = cos(R2.degreesToRadians) * sin(P2.degreesToRadians)
        return atan2(b, a).radiansToDegrees
    }
    
    private func sunDeclinationsDegrees() -> Double {
        let R2 = obliqCorrDegrees()
        let P2 = sunAppLong()
        let a = sin(R2.degreesToRadians)
        let b = sin(P2.degreesToRadians)
        return asin(a * b).radiansToDegrees
    }
    
    private func varY() -> Double {
        let R2 = obliqCorrDegrees()
        let a = tan((R2/2).degreesToRadians)
        return a * a
    }
    
    private func eqOfTimeMinutes() -> Double {
        let U2 = varY()
        let I2 = geomMeanLongSun()
        let K2 = eccentEarthOrbit()
        let J2 = geomMeanAnomSunDegrees()
        let a = U2 * sin(2 * I2.degreesToRadians)
        let b = 2 * K2 * sin(J2.degreesToRadians)
        let c = 4 * K2 * U2 * sin(J2.degreesToRadians) * cos(2 * I2.degreesToRadians)
        let d = 0.5 * U2 * U2 * sin(4 * I2.degreesToRadians)
        let f = 1.25 * K2 * K2 * sin(2 * J2.degreesToRadians)
        return 4 * (a - b + c - d - f).radiansToDegrees
    }
    
    private func haSunriseDegrees(twilight: Twilight) -> Double {
        var sunDegrees: Double {
            switch twilight {
            case .none: return 90.833
            case .civil: return 96.833
            case .nautical: return 102.833
            case .astronomical: return 108.833
            }
        }
        let B2 = self.location.latitude
        let T2 = sunDeclinationsDegrees()
        let a = cos(sunDegrees.degreesToRadians)
        let b = cos(B2.degreesToRadians)
        let c = cos(T2.degreesToRadians)
        let e = 1 * tan(B2.degreesToRadians) * tan(T2.degreesToRadians)
        return acos(a/(b*c) - e).radiansToDegrees
    }
    
    private func solorNoonLST() -> Double {
        let B3 = self.location.longitude
        let B4 = self.secondsFromGMT
        let V2 = eqOfTimeMinutes()
        let dayPropartion = (720 - 4 * B3 - V2 + B4 * 60) / 1440
        return dayPropartion
    }
    
    private func getTimeFrom(_ seconds: Double) -> Date? {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        calendar?.timeZone = self.timeZone
        return calendar?.startOfDay(for: self.date).addingTimeInterval(TimeInterval(seconds))
    }
    
    private func getJulianDay() -> Int? {
        let currentDate = Date()
        let calender = Calendar.current
        let currentYear = calender.component(.year, from: currentDate)
        let firstDayOfTheYear = calender.date(from: DateComponents(timeZone: TimeZone.init(identifier: "UTC")!, year: currentYear, month: 1, day: 1 , hour: 0, minute: 0, second: 0, nanosecond: 0))
        let dif = calender.dateComponents([.day], from: firstDayOfTheYear!, to: currentDate).day
        return dif
    }
    
    private func sunlightDuration(twilight: Twilight) -> Double {
        let W2 = haSunriseDegrees(twilight: twilight)
        return 8 * W2
    }
    
    private func sunTimes(dayPortion: DayPortion, twilight: Twilight) -> Date? {
        let X2 = solorNoonLST()
        let W2 = haSunriseDegrees(twilight: twilight)
        let Y1 = X2 * 1440
        let Y2 = W2 * 4
        var Y3: Double {
            switch dayPortion {
            case .dawn: return (Y1 - Y2)
            case .dusk: return (Y1 + Y2)
            }}
        let Y4 = (Y3 * 86400)/1440
        return getTimeFrom(Y4)
    }
    
}

