//
//  ContentView.swift
//  Convert-It
//
//  Created by arda on 12.03.2025.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(get: {self.wrappedValue}, set: { newValue in
            self.wrappedValue = newValue
            handler(newValue)
        })
    }
}

struct UnitConverter {
    private static let conversionRates: [String: [String: Double]] = [
        "Temp": [
                "Celcius": 1.0,
                "Fahrenheit": 1.0,
                "Kelvin": 1.0
            ],
            "Length": [
                "Meters": 1.0,
                "Kilometers": 1000.0,
                "Feet": 0.3048,
                "Yards": 0.9144,
                "Miles": 1609.34
            ],
            "Time": [
                "Seconds": 1.0,
                "Minutes": 60.0,
                "Hours": 3600.0,
                "Days": 86400.0
            ],
            "Volume": [
                "Milliliters": 1.0,
                "Liters": 1000.0,
                "Cups": 236.588,
                "Pints": 473.176,
                "Gallons": 3785.41
            ]
        ]
    
    static func convert(value: Double, from sourceUnit: String, to targetUnit: String, type: String) -> Double {
        if type == "Temp" {
            return convertTemperature(value: value, from: sourceUnit, to: targetUnit)
        }
        
        guard let conversionMap = conversionRates[type],
              let sourceRate = conversionMap[sourceUnit],
              let targetRate = conversionMap[targetUnit] else {
            return 0.0
        }
        
        let baseValue = value * sourceRate
        return baseValue / targetRate
    }
    
    private static func convertTemperature(value: Double, from sourceUnit: String, to targetUnit: String) -> Double {
        var celsiusValue: Double
               
        switch sourceUnit {
        case "Celcius":
           celsiusValue = value
        case "Fahrenheit":
           celsiusValue = (value - 32) / 1.8
        case "Kelvin":
           celsiusValue = value - 273.15
        default:
           return 0.0
        }

        switch targetUnit {
        case "Celcius":
           return celsiusValue
        case "Fahrenheit":
           return (celsiusValue * 1.8) + 32
        case "Kelvin":
           return celsiusValue + 273.15
        default:
           return 0.0
        }
    }
}
struct ContentView: View {
    @State private var conversionType = "Temp"
    
    @State private var selectedUnitFrom = "Celcius"
    @State private var selectedUnitTo = "Fahrenheit"
    
    @State private var unitValue = 0.0
    
    @FocusState private var valueIsFocused: Bool
    
    private let defaultUnits: [String: (from: String, to: String)] = [
        "Temp": (from: "Celcius", to: "Fahrenheit"),
        "Length": (from: "Meters", to: "Kilometers"),
        "Time": (from: "Minutes", to: "Hours"),
        "Volume": (from: "Milliliters", to: "Liters")
    ]
    
    var conversionTypes = ["Temp", "Length", "Time", "Volume"]
    var tempConversionUnits = ["Celcius", "Fahrenheit", "Kelvin"];
    var lengthConversionUnits = ["Meters", "Kilometers", "Feet", "Yards", "Miles"]
    var timeConversionUnits = ["Seconds", "Minutes", "Hours", "Days"]
    var volumeConversionUnits = ["Milliliters", "Liters", "Cups", "Pints", "Gallons"]
    
    var appConversionUnits: [String] {
        switch conversionType {
            case "Temp":
            return tempConversionUnits
        case "Length":
            return lengthConversionUnits
        case "Time":
            return timeConversionUnits
        case "Volume":
            return volumeConversionUnits
        default:
            return []
        }
    }
    
    private var result: String {
        if selectedUnitFrom == selectedUnitTo {
            return unitValue.formatted(.number)
        }
       
        let convertedValue = UnitConverter.convert(value: unitValue, from: selectedUnitFrom, to: selectedUnitTo, type: conversionType)
        
        return convertedValue.formatted(.number)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Conversion Type 🖕") {
                    Picker("Conversion Type", selection: $conversionType.onChange { newType in
                        if let defaults = defaultUnits[newType] {
                            selectedUnitFrom = defaults.from
                            selectedUnitTo = defaults.to
                        }
                    }) {
                        ForEach(conversionTypes, id: \.self) {
                            Text($0)
                        }
                    }.pickerStyle(.segmented)
                }.padding(EdgeInsets(top:0, leading:-20, bottom:0, trailing:-20))
                    .listRowBackground(Color.clear)
                Section("From - To 👩‍❤️‍💋‍👨") {
                    Picker("From Unit", selection: $selectedUnitFrom) {
                        ForEach(appConversionUnits, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("To Unit", selection: $selectedUnitTo) {
                        ForEach(appConversionUnits, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Section("Unit as 💋\(selectedUnitFrom)💋") {
                    TextField("Unit as \(selectedUnitFrom)", value: $unitValue, format: .number)
                        .keyboardType(.decimalPad)
                        .focused($valueIsFocused)
                }
                
                Section("Final Conversion Result 🔮") {
                    Text("\(result) 👋").font(.title).fontWeight(.black).foregroundStyle(.indigo)
                }
                
            }
                .navigationTitle("Convert It 🧑‍🚀")
                .toolbar {
                    if valueIsFocused {
                        Button("Done") {
                            valueIsFocused = false
                        }.buttonStyle(.borderedProminent)
                    }
                }
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    ContentView()
}
