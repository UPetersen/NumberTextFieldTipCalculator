//
//  NumberFieldView.swift adapted from DecimalField.swift, see https://github.com/edw/swiftui-numberfield
//
//  Created by Edwin Watkeys on 9/20/19.
//  Copyright © 2019 Edwin Watkeys.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software
// is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//
//  Adapted by Uwe Petersen on 27.11.19 from DecimalField.swift
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct NumberTextField : View {
    let label: String
    @Binding var value: NSNumber?
    let formatter: NumberFormatter
    @State var displayedText: String? = nil
    @State var lastFormattedValue: NSNumber? = nil
    
    var body: some View {
        let b = Binding<String>(
            get: { return self.displayedText ?? "" },
            set: { newValue in
                self.displayedText = newValue
                self.value = self.formatter.number(from: newValue)
        })
        
        return TextField(label, text: b, onEditingChanged: { inFocus in
            print("onEditingChanged")
            if !inFocus {
                self.lastFormattedValue = self.formatter.number(from: b.wrappedValue)
                if self.lastFormattedValue != nil {
                    DispatchQueue.main.async {
                        b.wrappedValue = self.formatter.string(for: self.lastFormattedValue!) ?? ""
                    }
                }
            }
        })
            .onAppear(){ // Otherwise textfield is empty when view appears
                print(self.value?.description ?? "no value")
                if let value = self.value, let valueString =  self.formatter.string(from: value) {
                    b.wrappedValue = valueString
                }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.trailing)
        .scaledToFit()
    }
}

struct NumberFieldView_Previews: PreviewProvider {
    
    static var previews: some View {
        TipCalculator()
    }
    
    struct TipCalculator: View {
        @State var dollarValue: NSNumber? = NSNumber(1)
        @State var tipRate: NSNumber? = NSNumber(1)
        
        var tipValue: NSNumber? {
            guard let dollarValue = self.dollarValue, let tipRate = self.tipRate else { return nil }
            return NSNumber(value: dollarValue.doubleValue * tipRate.doubleValue)
        }
        
        var totalValue: NSNumber? {
            guard let dollarValue = self.dollarValue, let tipValue = self.tipValue else { return nil }
            return NSNumber(value: dollarValue.doubleValue + tipValue.doubleValue)
        }
        
        static var currencyFormatter: NumberFormatter {
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.isLenient = true
            return nf
        }
        
        static var percentFormatter: NumberFormatter {
            let nf = NumberFormatter()
            nf.numberStyle = .percent
            nf.isLenient = true
            return nf
        }
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    VStack {
                        HStack {
                            Text("Check Amount")
                            Divider()
                            NumberTextField(label: "Amount", value: $dollarValue, formatter: Self.currencyFormatter)
                        }
                        
                        HStack {
                            Text("Tip Rate")
                            Divider()
                            NumberTextField(label: "Rate", value: $tipRate, formatter: Self.percentFormatter)
                        }
                    }
                    .padding()
                    
                    VStack {
                        HStack {
                            Text("Tip Amount")
                            Divider()
                            Text(Self.currencyFormatter.string(for: tipValue) ?? "-")
                            Spacer()
                        }
                        HStack {
                            Text("Total")
                            Divider()
                            Text(Self.currencyFormatter.string(for: totalValue) ?? "-")
                            Spacer()
                        }
                    }
                    .padding()
                    Spacer()
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding()
            }
        }
    }
}
